import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/sensor_thresholds.dart';

class ThresholdConfig {
  static const String collectionName = 'thresholds';
  static const String documentId = 'current';

  const ThresholdConfig({
    required this.temperatureWarning,
    required this.temperatureDanger,
    required this.smokeWarning,
    required this.smokeDanger,
    required this.gasWarning,
    required this.gasDanger,
    this.createdAt,
    this.updatedAt,
  });

  final double temperatureWarning;
  final double temperatureDanger;
  final double smokeWarning;
  final double smokeDanger;
  final double gasWarning;
  final double gasDanger;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ThresholdConfig.defaults() {
    return const ThresholdConfig(
      temperatureWarning: SensorThresholds.tempWarning,
      temperatureDanger: SensorThresholds.tempDanger,
      smokeWarning: SensorThresholds.smokeWarning,
      smokeDanger: SensorThresholds.smokeDanger,
      gasWarning: SensorThresholds.gasWarning,
      gasDanger: SensorThresholds.gasDanger,
    );
  }

  factory ThresholdConfig.fromFirestore(
    Map<String, dynamic> data, {
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ThresholdConfig(
      temperatureWarning:
          _toDouble(data['temperatureWarning']) ?? SensorThresholds.tempWarning,
      temperatureDanger:
          _toDouble(data['temperatureDanger']) ?? SensorThresholds.tempDanger,
      smokeWarning:
          _toDouble(data['smokeWarning']) ?? SensorThresholds.smokeWarning,
      smokeDanger:
          _toDouble(data['smokeDanger']) ?? SensorThresholds.smokeDanger,
      gasWarning: _toDouble(data['gasWarning']) ?? SensorThresholds.gasWarning,
      gasDanger: _toDouble(data['gasDanger']) ?? SensorThresholds.gasDanger,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ThresholdConfig.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      return ThresholdConfig.defaults();
    }

    return ThresholdConfig.fromFirestore(
      data,
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  ThresholdConfig copyWith({
    double? temperatureWarning,
    double? temperatureDanger,
    double? smokeWarning,
    double? smokeDanger,
    double? gasWarning,
    double? gasDanger,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ThresholdConfig(
      temperatureWarning: temperatureWarning ?? this.temperatureWarning,
      temperatureDanger: temperatureDanger ?? this.temperatureDanger,
      smokeWarning: smokeWarning ?? this.smokeWarning,
      smokeDanger: smokeDanger ?? this.smokeDanger,
      gasWarning: gasWarning ?? this.gasWarning,
      gasDanger: gasDanger ?? this.gasDanger,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String? validate() {
    if (temperatureDanger <= temperatureWarning) {
      return 'Temperature danger must be higher than warning.';
    }
    if (smokeDanger <= smokeWarning) {
      return 'Smoke danger must be higher than warning.';
    }
    if (gasDanger <= gasWarning) {
      return 'Gas danger must be higher than warning.';
    }
    return null;
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'temperatureWarning': temperatureWarning,
      'temperatureDanger': temperatureDanger,
      'smokeWarning': smokeWarning,
      'smokeDanger': smokeDanger,
      'gasWarning': gasWarning,
      'gasDanger': gasDanger,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'temperatureWarning': temperatureWarning,
      'temperatureDanger': temperatureDanger,
      'smokeWarning': smokeWarning,
      'smokeDanger': smokeDanger,
      'gasWarning': gasWarning,
      'gasDanger': gasDanger,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
