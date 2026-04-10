import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../core/utils/severity_evaluator.dart';
import '../models/alert.dart';
import '../models/sensor_node.dart';

class AlertService {
  AlertService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  StreamSubscription<List<SensorNode>>? _sensorSubscription;
  final Map<String, String> _lastSeverityByNode = <String, String>{};

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
    _sensorSubscription ??= sensorStream.listen((nodes) async {
      for (final node in nodes) {
        await _processNode(node: node, createdBy: createdBy);
      }
    });
  }

  Future<void> stopAutoGeneration() async {
    await _sensorSubscription?.cancel();
    _sensorSubscription = null;
    _lastSeverityByNode.clear();
  }

  Future<void> _processNode({
    required SensorNode node,
    String? createdBy,
  }) async {
    final evaluation = SeverityEvaluator.evaluate(
      temperature: node.temperature,
      smoke: node.smoke,
      gas: node.gas,
      hasSensorError: node.hasSensorError,
    );

    final currentSeverity = evaluation.severity;
    final previousSeverity = _lastSeverityByNode[node.id];

    if (currentSeverity == Alert.severitySafe) {
      if (previousSeverity != Alert.severitySafe) {
        await _resolveActiveAlertsForNode(node.id, resolvedBy: createdBy);
        if (previousSeverity == Alert.severityWarning ||
            previousSeverity == Alert.severityDanger) {
          await _createRecoveryAlert(node: node, createdBy: createdBy);
        }
      }
      _lastSeverityByNode[node.id] = currentSeverity;
      return;
    }

    if (previousSeverity != currentSeverity) {
      await _createAlertIfNeeded(
        node: node,
        severity: currentSeverity,
        exceededMetrics: evaluation.exceededMetrics,
        createdBy: createdBy,
      );
    }

    _lastSeverityByNode[node.id] = currentSeverity;
  }

  Future<void> _createAlertIfNeeded({
    required SensorNode node,
    required String severity,
    required List<String> exceededMetrics,
    String? createdBy,
  }) async {
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
      title: _titleForSeverity(severity),
      description: _descriptionForSeverity(node: node, severity: severity),
      severity: severity,
      nodeId: node.id,
      nodeName: node.name,
      location: node.location,
      triggeredAt: DateTime.now(),
      status: Alert.statusActive,
      explanation: _buildExplanation(
        node: node,
        severity: severity,
        exceededMetrics: exceededMetrics,
      ),
      createdBy: createdBy,
    );

    try {
      await documentRef.set(alert.toCreateMap());
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
      description: '${node.name} readings returned to safe levels.',
      severity: Alert.severitySafe,
      nodeId: node.id,
      nodeName: node.name,
      location: node.location,
      triggeredAt: now,
      status: Alert.statusResolved,
      resolvedAt: now,
      explanation:
          'Temperature ${node.temperature.toStringAsFixed(1)} C, carbon monoxide ${node.smoke.toStringAsFixed(1)}, gas ${node.gas.toStringAsFixed(1)}. All metrics are within safe range.',
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

  String _titleForSeverity(String severity) {
    if (severity == Alert.severityDanger) {
      return 'Danger Alert';
    }
    return 'Warning Alert';
  }

  String _descriptionForSeverity({
    required SensorNode node,
    required String severity,
  }) {
    if (severity == Alert.severityDanger) {
      return '${node.name} reached critical sensor levels.';
    }
    return '${node.name} exceeded warning thresholds.';
  }

  String _buildExplanation({
    required SensorNode node,
    required String severity,
    required List<String> exceededMetrics,
  }) {
    final metrics = exceededMetrics.isEmpty
        ? 'temperature, carbon monoxide, or gas'
        : exceededMetrics.join(', ');

    final label = severity == Alert.severityDanger ? 'critical' : 'warning';

    return '${node.name} at ${node.location} triggered a $label event. '
        'Exceeded metrics: $metrics. '
        'Current readings: ${node.temperature.toStringAsFixed(1)} C, '
        'carbon monoxide ${node.smoke.toStringAsFixed(1)}, gas ${node.gas.toStringAsFixed(1)}.';
  }
}
