import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  static const String collectionName = 'alerts';

  static const String severitySafe = 'safe';
  static const String severityWarning = 'warning';
  static const String severityDanger = 'danger';

  static const String statusActive = 'active';
  static const String statusResolved = 'resolved';

  final String id;
  final String title;
  final String description;
  final String severity;
  final String nodeId;
  final String nodeName;
  final String location;
  final DateTime triggeredAt;
  final String status;
  final DateTime? resolvedAt;
  final String? explanation;
  final String? createdBy;
  final String? resolvedBy;
  final DateTime? updatedAt;

  const Alert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.nodeId,
    required this.nodeName,
    required this.location,
    required this.triggeredAt,
    required this.status,
    this.resolvedAt,
    this.explanation,
    this.createdBy,
    this.resolvedBy,
    this.updatedAt,
  });

  bool get isActive => status == statusActive;

  bool get isResolved => status == statusResolved;

  factory Alert.fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? <String, dynamic>{};

    return Alert(
      id: document.id,
      title: data['title'] as String? ?? 'Alert',
      description: data['description'] as String? ?? 'Sensor reading exceeded threshold.',
      severity: data['severity'] as String? ?? severityWarning,
      nodeId: data['nodeId'] as String? ?? '',
      nodeName: data['nodeName'] as String? ?? 'Unknown Node',
      location: data['location'] as String? ?? 'Unknown',
      triggeredAt: _parseDateTime(data['triggeredAt']) ?? DateTime.now(),
      status: data['status'] as String? ?? statusActive,
      resolvedAt: _parseDateTime(data['resolvedAt']),
      explanation: data['explanation'] as String?,
      createdBy: data['createdBy'] as String?,
      resolvedBy: data['resolvedBy'] as String?,
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'severity': severity,
      'nodeId': nodeId,
      'nodeName': nodeName,
      'location': location,
      'triggeredAt': Timestamp.fromDate(triggeredAt),
      'status': status,
      'resolvedAt': resolvedAt == null ? null : Timestamp.fromDate(resolvedAt!),
      'explanation': explanation,
      'createdBy': createdBy,
      'resolvedBy': resolvedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Mock data for UI development
  static List<Alert> getMockAlerts() {
    final now = DateTime.now();
    return [
      Alert(
        id: '1',
        title: 'Fire Hazard Detected',
        description: 'Temperature exceeded 50°C threshold.',
        severity: 'danger',
        nodeId: '1',
        nodeName: 'Bedroom Sensor',
        location: 'Bedroom',
        triggeredAt: now.subtract(const Duration(minutes: 8)),
        status: 'active',
        explanation:
            'Temperature exceeded 50°C threshold at 10:52 PM. Smoke levels at 245 ppm (critical threshold: 100 ppm). Immediate evacuation recommended.',
      ),
      Alert(
        id: '2',
        title: 'Elevated Gas Levels',
        description: 'Gas concentration above normal.',
        severity: 'warning',
        nodeId: '2',
        nodeName: 'Garage Sensor',
        location: 'Garage',
        triggeredAt: now.subtract(const Duration(minutes: 25)),
        status: 'active',
        explanation: 'Gas concentration above normal.',
      ),
      Alert(
        id: '3',
        title: 'Smoke Detected While Cooking',
        description: 'Elevated smoke levels detected during cooking.',
        severity: 'warning',
        nodeId: '3',
        nodeName: 'Kitchen Sensor',
        location: 'Kitchen',
        triggeredAt: DateTime(2026, 2, 9, 18, 30),
        status: 'resolved',
        resolvedAt: DateTime(2026, 2, 9, 19, 15),
        explanation: 'Elevated smoke levels detected during cooking.',
      ),
      Alert(
        id: '4',
        title: 'Gas Leak Warning',
        description: 'Elevated gas levels detected.',
        severity: 'warning',
        nodeId: '2',
        nodeName: 'Garage Sensor',
        location: 'Garage',
        triggeredAt: DateTime(2026, 2, 4, 14, 20),
        status: 'resolved',
        resolvedAt: DateTime(2026, 2, 5, 9, 10),
        explanation: 'Elevated gas levels detected.',
      ),
      Alert(
        id: '5',
        title: 'Smoke Alarm Triggered',
        description: 'High smoke concentration detected.',
        severity: 'danger',
        nodeId: '3',
        nodeName: 'Kitchen Sensor',
        location: 'Kitchen',
        triggeredAt: DateTime(2026, 1, 21, 7, 45),
        status: 'resolved',
        resolvedAt: DateTime(2026, 1, 21, 8, 30),
        explanation: 'High smoke concentration detected.',
      ),
    ];
  }

  Alert copyWith({
    String? id,
    String? title,
    String? description,
    String? severity,
    String? nodeId,
    String? nodeName,
    String? location,
    DateTime? triggeredAt,
    String? status,
    DateTime? resolvedAt,
    String? explanation,
    String? createdBy,
    String? resolvedBy,
    DateTime? updatedAt,
  }) {
    return Alert(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      nodeId: nodeId ?? this.nodeId,
      nodeName: nodeName ?? this.nodeName,
      location: location ?? this.location,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      status: status ?? this.status,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      explanation: explanation ?? this.explanation,
      createdBy: createdBy ?? this.createdBy,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
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
      return DateTime.tryParse(value);
    }

    return null;
  }
}
