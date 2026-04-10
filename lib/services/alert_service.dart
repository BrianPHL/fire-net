import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../core/utils/severity_evaluator.dart';
import '../models/alert.dart';
import '../models/sensor_node.dart';
import '../models/threshold_config.dart';
import 'threshold_config_service.dart';

class AlertService {
  AlertService({
    FirebaseFirestore? firestore,
    ThresholdConfigService? thresholdConfigService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _thresholdConfigService =
           thresholdConfigService ?? ThresholdConfigService();

  static const Duration _alertCooldown = Duration(seconds: 30);
  static const int _requiredSafeStreak = 2;

  final FirebaseFirestore _firestore;
  final ThresholdConfigService _thresholdConfigService;
  StreamSubscription<List<SensorNode>>? _sensorSubscription;
  StreamSubscription<ThresholdConfig?>? _thresholdSubscription;
  ThresholdConfig _activeThresholds = ThresholdConfig.defaults();
  final Map<String, String> _lastSeverityByNode = <String, String>{};
  final Map<String, int> _safeStreakByNode = <String, int>{};
  final Map<String, DateTime> _lastAlertCreatedAtBySignature =
      <String, DateTime>{};

  CollectionReference<Map<String, dynamic>> get _alertsRef =>
      _firestore.collection(Alert.collectionName);

  Stream<List<Alert>> watchAlerts({String? status, String? severity}) {
    Query<Map<String, dynamic>> query = _alertsRef;

    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) {
      var alerts = snapshot.docs.map(Alert.fromDocument).toList();
      if (severity != null && severity.isNotEmpty) {
        alerts = alerts.where((alert) => alert.severity == severity).toList();
      }
      alerts.sort((a, b) => b.triggeredAt.compareTo(a.triggeredAt));
      return alerts;
    });
  }

  Future<void> resolveAlert({
    required String alertId,
    String? resolvedBy,
  }) async {
    try {
      await _alertsRef.doc(alertId).update(<String, dynamic>{
        'status': Alert.statusResolved,
        'resolvedAt': FieldValue.serverTimestamp(),
        'resolvedBy': resolvedBy,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      debugPrint('Resolve alert failed: $error');
      rethrow;
    }
  }

  void startAutoGeneration({
    required Stream<List<SensorNode>> sensorStream,
    String? createdBy,
  }) {
    _thresholdSubscription ??= _thresholdConfigService
        .watchThresholdConfig()
        .listen(
          (config) {
            _activeThresholds = config ?? ThresholdConfig.defaults();
          },
          onError: (Object error) {
            debugPrint('Threshold stream error: $error');
            _activeThresholds = ThresholdConfig.defaults();
          },
        );

    _sensorSubscription ??= sensorStream.listen(
      (nodes) async {
        for (final node in nodes) {
          await _processNode(node: node, createdBy: createdBy);
        }
      },
      onError: (Object error) {
        debugPrint('Sensor stream error: $error');
      },
    );
  }

  Future<void> stopAutoGeneration() async {
    await _sensorSubscription?.cancel();
    _sensorSubscription = null;
    await _thresholdSubscription?.cancel();
    _thresholdSubscription = null;
    _lastSeverityByNode.clear();
    _safeStreakByNode.clear();
    _lastAlertCreatedAtBySignature.clear();
    _activeThresholds = ThresholdConfig.defaults();
  }

  Future<void> _processNode({
    required SensorNode node,
    String? createdBy,
  }) async {
    final evaluation = SeverityEvaluator.evaluateAdvanced(
      temperature: node.temperature,
      smoke: node.smoke,
      gas: node.gas,
      fireDetected: node.fireDetected,
      hasSensorError: node.hasSensorError,
      mlxAmbient: node.mlxAmbient,
      mlxObject: node.mlxObject,
      thresholds: _activeThresholds,
    );

    final currentSeverity = evaluation.severity;
    final previousSeverity = _lastSeverityByNode[node.id];

    if (currentSeverity == Alert.severitySafe) {
      final nextSafeStreak = (_safeStreakByNode[node.id] ?? 0) + 1;
      _safeStreakByNode[node.id] = nextSafeStreak;

      if (previousSeverity == null || previousSeverity == Alert.severitySafe) {
        _lastSeverityByNode[node.id] = currentSeverity;
        return;
      }

      if (nextSafeStreak < _requiredSafeStreak) {
        return;
      }

      await _resolveActiveAlertsForNode(node.id, resolvedBy: createdBy);
      if (previousSeverity == Alert.severityWarning ||
          previousSeverity == Alert.severityDanger) {
        await _createRecoveryAlert(node: node, createdBy: createdBy);
      }

      _lastSeverityByNode[node.id] = currentSeverity;
      return;
    }

    _safeStreakByNode[node.id] = 0;

    if (previousSeverity != currentSeverity) {
      await _createAlertIfNeeded(
        node: node,
        severity: currentSeverity,
        alertCode: evaluation.alertCode,
        createdBy: createdBy,
      );
    }

    _lastSeverityByNode[node.id] = currentSeverity;
  }

  Future<void> _createAlertIfNeeded({
    required SensorNode node,
    required String severity,
    required String alertCode,
    String? createdBy,
  }) async {
    final now = DateTime.now();
    final signature = '${node.id}:$severity:$alertCode';
    final lastCreatedAt = _lastAlertCreatedAtBySignature[signature];
    if (lastCreatedAt != null &&
        now.difference(lastCreatedAt) < _alertCooldown) {
      return;
    }

    final duplicateQuery = await _alertsRef
        .where('nodeId', isEqualTo: node.id)
        .where('status', isEqualTo: Alert.statusActive)
        .where('severity', isEqualTo: severity)
        .limit(1)
        .get();

    if (duplicateQuery.docs.isNotEmpty) {
      return;
    }

    final documentRef = _alertsRef.doc();
    final alert = Alert(
      id: documentRef.id,
      title: _titleForAlert(severity: severity, alertCode: alertCode),
      description: _descriptionForSeverity(
        node: node,
        severity: severity,
        alertCode: alertCode,
      ),
      severity: severity,
      nodeId: node.id,
      nodeName: node.name,
      location: node.location,
      triggeredAt: now,
      status: Alert.statusActive,
      explanation: _buildExplanation(
        node: node,
        severity: severity,
        alertCode: alertCode,
      ),
      createdBy: createdBy,
    );

    try {
      await documentRef.set(alert.toCreateMap());
      _lastAlertCreatedAtBySignature[signature] = now;
    } on FirebaseException catch (error) {
      debugPrint('Create alert failed: $error');
      rethrow;
    }
  }

  Future<void> _createRecoveryAlert({
    required SensorNode node,
    String? createdBy,
  }) async {
    final documentRef = _alertsRef.doc();
    final now = DateTime.now();
    final alert = Alert(
      id: documentRef.id,
      title: 'Conditions Normalized',
      description:
          '${node.name} readings returned to safe levels after $_requiredSafeStreak stable checks.',
      severity: Alert.severitySafe,
      nodeId: node.id,
      nodeName: node.name,
      location: node.location,
      triggeredAt: now,
      status: Alert.statusResolved,
      resolvedAt: now,
      explanation:
          'Temperature ${node.temperature.toStringAsFixed(1)} C, carbon monoxide ${node.smoke.toStringAsFixed(1)}, gas ${node.gas.toStringAsFixed(1)}, IR object ${_formatOptional(node.mlxObject)} C, IR ambient ${_formatOptional(node.mlxAmbient)} C. All metrics are within safe range.',
      createdBy: createdBy,
      resolvedBy: createdBy,
    );

    try {
      await documentRef.set(alert.toCreateMap());
    } on FirebaseException catch (error) {
      debugPrint('Create recovery alert failed: $error');
      rethrow;
    }
  }

  Future<void> _resolveActiveAlertsForNode(
    String nodeId, {
    String? resolvedBy,
  }) async {
    final snapshot = await _alertsRef
        .where('nodeId', isEqualTo: nodeId)
        .where('status', isEqualTo: Alert.statusActive)
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, <String, dynamic>{
        'status': Alert.statusResolved,
        'resolvedAt': FieldValue.serverTimestamp(),
        'resolvedBy': resolvedBy,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  String _titleForAlert({required String severity, required String alertCode}) {
    switch (alertCode) {
      case 'fire_confirmed_multisensor':
        return 'Confirmed Fire Risk';
      case 'toxic_combustion_high':
        return 'Toxic Combustion Risk';
      case 'heat_combustion_critical':
        return 'Critical Heat + Combustion';
      case 'thermal_combustion_critical':
        return 'Critical Thermal Combustion';
      case 'temperature_critical':
        return 'Critical Temperature Rise';
      case 'gas_critical':
        return 'Critical Gas Concentration';
      case 'co_critical':
        return 'Critical Carbon Monoxide';
      case 'infrared_object_critical':
        return 'Critical Infrared Heat';
      case 'thermal_delta_critical':
        return 'Critical Thermal Delta';
      case 'sensor_fault':
        return 'Sensor Fault Detected';
      case 'gas_co_correlation_warning':
        return 'Gas + CO Correlation Warning';
      case 'thermal_combustion_warning':
        return 'Thermal Combustion Warning';
      case 'heat_combustion_warning':
        return 'Heat Combustion Warning';
      case 'temperature_warning':
        return 'Temperature Warning';
      case 'gas_warning':
        return 'Gas Warning';
      case 'co_warning':
        return 'Carbon Monoxide Warning';
      case 'infrared_object_warning':
        return 'Infrared Heat Warning';
      case 'thermal_delta_warning':
        return 'Thermal Delta Warning';
      default:
        if (severity == Alert.severityDanger) {
          return 'Danger Alert';
        }
        return 'Warning Alert';
    }
  }

  String _descriptionForSeverity({
    required SensorNode node,
    required String severity,
    required String alertCode,
  }) {
    final reason = _plainReasonForAlertCode(alertCode);
    if (severity == Alert.severityDanger) {
      return '$reason Immediate inspection is recommended.';
    }
    return '$reason Please check the area and monitor closely.';
  }

  String _buildExplanation({
    required SensorNode node,
    required String severity,
    required String alertCode,
  }) {
    final reason = _plainReasonForAlertCode(alertCode);
    final action = _recommendedActionForAlertCode(alertCode, severity);
    final readings = _readingsSummary(node);

    return '${node.name} at ${node.location} reported a ${_severityLabel(severity)} condition. '
        '$reason $action Current readings: $readings.';
  }

  String _formatOptional(double? value) {
    if (value == null) {
      return 'N/A';
    }
    return value.toStringAsFixed(1);
  }

  String _severityLabel(String severity) {
    if (severity == Alert.severityDanger) {
      return 'critical';
    }
    if (severity == Alert.severityWarning) {
      return 'warning';
    }
    return 'safe';
  }

  String _plainReasonForAlertCode(String alertCode) {
    switch (alertCode) {
      case 'fire_confirmed_multisensor':
        return 'Multiple sensors indicate a possible fire risk.';
      case 'toxic_combustion_high':
        return 'Gas and carbon monoxide levels are both critically high.';
      case 'heat_combustion_critical':
      case 'thermal_combustion_critical':
        return 'Heat and combustion-related readings are elevated at the same time.';
      case 'temperature_critical':
      case 'temperature_warning':
        return 'Temperature is above the expected safe range.';
      case 'gas_critical':
      case 'gas_warning':
        return 'Gas level is above the expected safe range.';
      case 'co_critical':
      case 'co_warning':
        return 'Carbon monoxide level is above the expected safe range.';
      case 'infrared_object_critical':
      case 'infrared_object_warning':
      case 'thermal_delta_critical':
      case 'thermal_delta_warning':
        return 'Infrared heat readings suggest abnormal thermal activity.';
      case 'sensor_fault':
        return 'A sensor issue was detected and readings may be unreliable.';
      case 'gas_co_correlation_warning':
        return 'Gas and carbon monoxide are rising together.';
      case 'thermal_combustion_warning':
      case 'heat_combustion_warning':
        return 'Heat and combustion-related signs are both increasing.';
      default:
        return 'Sensor readings are outside normal levels.';
    }
  }

  String _recommendedActionForAlertCode(String alertCode, String severity) {
    if (alertCode == 'sensor_fault') {
      return 'Please inspect the device and verify sensor connections.';
    }

    if (severity == Alert.severityDanger) {
      return 'Move people to safety, improve ventilation, and inspect for smoke or heat sources immediately.';
    }

    return 'Inspect the area, improve ventilation if needed, and continue monitoring.';
  }

  String _readingsSummary(SensorNode node) {
    final parts = <String>[
      'temperature ${node.temperature.toStringAsFixed(1)} C',
      'carbon monoxide ${node.smoke.toStringAsFixed(1)} ppm',
      'gas ${node.gas.toStringAsFixed(1)} ppm',
    ];

    if (node.mlxObject != null) {
      parts.add('IR object ${node.mlxObject!.toStringAsFixed(1)} C');
    }
    if (node.mlxAmbient != null) {
      parts.add('IR ambient ${node.mlxAmbient!.toStringAsFixed(1)} C');
    }

    return parts.join(', ');
  }
}
