import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';
import '../models/alert.dart';
import '../routes/app_routes.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Background FCM message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String alertsTopic = 'alerts';
  static const String _channelId = 'alerts_channel';
  static const String _channelName = 'Alert notifications';
  static const String _channelDescription = 'Notifications for warning and danger alerts';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _initialized = false;
  Map<String, dynamic>? _pendingPayload;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    if (!kIsWeb) {
      await _configureLocalNotifications();
    }
    await _requestPermissions();
    // Topic subscriptions are only supported on mobile platforms (iOS/Android)
    if (!kIsWeb) {
      await _subscribeToAlertsTopic();
    }

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTapMessage);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _pendingPayload = Map<String, dynamic>.from(initialMessage.data);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _flushPendingMessage();
    });

    _messaging.onTokenRefresh.listen((token) {
      debugPrint('FCM token refreshed: $token');
    });

    final token = await _messaging.getToken();
    debugPrint('FCM token: $token');
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    if (!kIsWeb) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _configureLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) {
          _navigateToAlerts();
          return;
        }

        final data = _decodePayload(payload);
        _navigateFromPayload(data);
      },
    );

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);
  }

  Future<void> _subscribeToAlertsTopic() async {
    try {
      await _messaging.subscribeToTopic(alertsTopic);
    } on FirebaseException catch (error) {
      debugPrint('Failed to subscribe to alerts topic: $error');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kIsWeb) {
      _handleNotificationData(Map<String, dynamic>.from(message.data));
      return;
    }

    _showLocalNotification(message);
  }

  void _handleTapMessage(RemoteMessage message) {
    _handleNotificationData(message.data);
  }

  void _flushPendingMessage() {
    final payload = _pendingPayload;
    if (payload == null) {
      return;
    }

    _pendingPayload = null;
    _handleNotificationData(payload);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (kIsWeb) {
      return;
    }

    final title = message.notification?.title ?? _titleForData(message.data);
    final body = message.notification?.body ?? _bodyForData(message.data);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingPayload = Map<String, dynamic>.from(data);
      return;
    }

    _navigateFromPayload(data);
  }

  void _navigateFromPayload(Map<String, dynamic> data) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      return;
    }

    final alert = _alertFromPayload(data);
    if (alert != null) {
      navigator.pushNamedAndRemoveUntil(
        AppRoutes.alertDetail,
        (route) => route.isFirst,
        arguments: alert,
      );
      return;
    }

    navigator.pushNamedAndRemoveUntil(
      AppRoutes.alerts,
      (route) => route.isFirst,
    );
  }

  Alert? _alertFromPayload(Map<String, dynamic> data) {
    final alertId = data['alertId']?.toString();
    if (alertId == null || alertId.isEmpty) {
      return null;
    }

    return Alert(
      id: alertId,
      title: data['title']?.toString() ?? 'Alert',
      description: data['description']?.toString() ?? 'Sensor reading exceeded threshold.',
      severity: data['severity']?.toString() ?? Alert.severityWarning,
      nodeId: data['nodeId']?.toString() ?? '',
      nodeName: data['nodeName']?.toString() ?? 'Unknown Node',
      location: data['location']?.toString() ?? 'Unknown',
      triggeredAt: _parseDateTime(data['triggeredAt']) ?? DateTime.now(),
      status: data['status']?.toString() ?? Alert.statusActive,
      resolvedAt: _parseDateTime(data['resolvedAt']),
      explanation: data['explanation']?.toString(),
      createdBy: data['createdBy']?.toString(),
      resolvedBy: data['resolvedBy']?.toString(),
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> _decodePayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      // Ignore malformed payloads and fall back to alerts list.
    }

    return <String, dynamic>{};
  }

  void _navigateToAlerts() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      return;
    }

    navigator.pushNamedAndRemoveUntil(
      AppRoutes.alerts,
      (route) => route.isFirst,
    );
  }

  String _titleForData(Map<String, dynamic> data) {
    final severity = data['severity']?.toString();
    return severity == Alert.severityDanger ? 'Danger Alert' : 'Warning Alert';
  }

  String _bodyForData(Map<String, dynamic> data) {
    final nodeName = data['nodeName']?.toString() ?? 'Sensor';
    final location = data['location']?.toString() ?? 'Unknown location';
    return '$nodeName at $location needs attention.';
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }

      final millis = int.tryParse(value);
      if (millis != null) {
        return DateTime.fromMillisecondsSinceEpoch(millis);
      }
    }

    return null;
  }
}
