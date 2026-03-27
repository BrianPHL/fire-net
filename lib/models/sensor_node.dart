import '../core/constants/sensor_thresholds.dart';

/// Sensor node model representing a physical sensor device
class SensorNode {
  final String id;
  final String name;
  final String location;
  final String status;
  final double temperature;
  final double humidity;
  final double smoke;
  final double gas;
  final DateTime lastUpdated;
  final bool hasSensorError;
  final bool hasHumidityReading;
  final bool hasSmokeReading;

  const SensorNode({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.temperature,
    required this.humidity,
    required this.smoke,
    required this.gas,
    required this.lastUpdated,
    this.hasSensorError = false,
    this.hasHumidityReading = true,
    this.hasSmokeReading = true,
  });

  factory SensorNode.fromRealtimeDb(String id, Map<dynamic, dynamic> data) {
    final map = data.map((key, value) => MapEntry(key.toString(), value));

    final temperature = _toDouble(map['temperature']) ?? 0;
    final hasHumidityReading = map.containsKey('humidity');
    final humidity = _toDouble(map['humidity']) ?? 0;
    final hasSmokeReading = map.containsKey('smoke');
    final smoke = _toDouble(map['smoke']) ?? 0;
    final gas = _toDouble(map['gasLevel']) ?? _toDouble(map['gas']) ?? 0;
    final sensorError = map['sensorError'] == true;

    final status =
        (map['status'] as String?) ??
        _deriveStatus(
          temperature: temperature,
          smoke: smoke,
          gas: gas,
          hasSensorError: sensorError,
        );

    return SensorNode(
      id: id,
      name: (map['name'] as String?) ?? 'ESP32 Sensor',
      location: (map['location'] as String?) ?? 'Unknown',
      status: status,
      temperature: temperature,
      humidity: humidity,
      smoke: smoke,
      gas: gas,
      lastUpdated: _parseTimestamp(map['timestamp'] ?? map['lastUpdated']),
      hasSensorError: sensorError,
      hasHumidityReading: hasHumidityReading,
      hasSmokeReading: hasSmokeReading,
    );
  }

  /// Mock data for UI development
  static List<SensorNode> getMockNodes() {
    final now = DateTime.now();
    return [
      SensorNode(
        id: '1',
        name: 'Bedroom Sensor',
        location: 'Bedroom',
        status: 'danger',
        temperature: 52.3,
        humidity: 71.0,
        smoke: 86.0,
        gas: 95.0,
        lastUpdated: now,
      ),
      SensorNode(
        id: '2',
        name: 'Garage Sensor',
        location: 'Garage',
        status: 'warning',
        temperature: 28.2,
        humidity: 63.0,
        smoke: 62.0,
        gas: 180.0,
        lastUpdated: now.subtract(const Duration(seconds: 30)),
      ),
      SensorNode(
        id: '3',
        name: 'Kitchen Sensor',
        location: 'Kitchen',
        status: 'safe',
        temperature: 24.5,
        humidity: 49.0,
        smoke: 48.0,
        gas: 45.0,
        lastUpdated: now.subtract(const Duration(minutes: 2)),
      ),
    ];
  }

  SensorNode copyWith({
    String? id,
    String? name,
    String? location,
    String? status,
    double? temperature,
    double? humidity,
    double? smoke,
    double? gas,
    DateTime? lastUpdated,
    bool? hasSensorError,
    bool? hasHumidityReading,
    bool? hasSmokeReading,
  }) {
    return SensorNode(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      status: status ?? this.status,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      smoke: smoke ?? this.smoke,
      gas: gas ?? this.gas,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      hasSensorError: hasSensorError ?? this.hasSensorError,
      hasHumidityReading: hasHumidityReading ?? this.hasHumidityReading,
      hasSmokeReading: hasSmokeReading ?? this.hasSmokeReading,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is int) {
      if (value < 1000000000000) {
        return DateTime.now();
      }
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is String) {
      final millis = int.tryParse(value);
      if (millis != null) {
        if (millis < 1000000000000) {
          return DateTime.now();
        }
        return DateTime.fromMillisecondsSinceEpoch(millis);
      }

      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }

    return DateTime.now();
  }

  static String _deriveStatus({
    required double temperature,
    required double smoke,
    required double gas,
    required bool hasSensorError,
  }) {
    if (hasSensorError ||
        temperature >= SensorThresholds.tempDanger ||
        smoke >= SensorThresholds.smokeDanger ||
        gas >= SensorThresholds.gasDanger) {
      return SensorThresholds.severityDanger;
    }

    if (temperature >= SensorThresholds.tempWarning ||
        smoke >= SensorThresholds.smokeWarning ||
        gas >= SensorThresholds.gasWarning) {
      return SensorThresholds.severityWarning;
    }

    return SensorThresholds.severitySafe;
  }
}
