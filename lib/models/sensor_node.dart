import '../core/utils/severity_evaluator.dart';

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
  final double? mlxAmbient;
  final double? mlxObject;
  final DateTime lastUpdated;
  final bool fireDetected;
  final bool hasSensorError;
  final bool hasHumidityReading;
  final bool hasSmokeReading;
  final bool hasMlxAmbientReading;
  final bool hasMlxObjectReading;

  const SensorNode({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.temperature,
    required this.humidity,
    required this.smoke,
    required this.gas,
    this.mlxAmbient,
    this.mlxObject,
    required this.lastUpdated,
    this.fireDetected = false,
    this.hasSensorError = false,
    this.hasHumidityReading = true,
    this.hasSmokeReading = true,
    this.hasMlxAmbientReading = false,
    this.hasMlxObjectReading = false,
  });

  factory SensorNode.fromRealtimeDb(String id, Map<dynamic, dynamic> data) {
    final incomingMap = data.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    final map = <String, dynamic>{...incomingMap};

    // Support payloads where values are nested under a readings key.
    for (final nestedKey in const <String>[
      'readings',
      'sensorData',
      'sensors',
    ]) {
      final nested = incomingMap[nestedKey];
      if (nested is Map<dynamic, dynamic>) {
        nested.forEach((key, value) {
          map.putIfAbsent(key.toString(), () => value);
        });
      }
    }

    final temperature = _firstDouble(map, const <String>['temperature']) ?? 0;
    final hasHumidityReading = _hasAnyKey(map, const <String>['humidity']);
    final humidity = _firstDouble(map, const <String>['humidity']) ?? 0;
    final hasSmokeReading = _hasAnyKey(map, const <String>[
      'mq7',
      'smoke',
      'carbonMonoxide',
      'co',
    ]);
    final smoke =
        _firstDouble(map, const <String>[
          'mq7',
          'smoke',
          'carbonMonoxide',
          'co',
        ]) ??
        0;
    final gas =
        _firstDouble(map, const <String>['mq2', 'gasLevel', 'gas']) ?? 0;
    final hasMlxAmbientReading = _hasAnyKey(map, const <String>['mlxAmbient']);
    final hasMlxObjectReading = _hasAnyKey(map, const <String>['mlxObject']);
    final mlxAmbient = _firstDouble(map, const <String>['mlxAmbient']);
    final mlxObject = _firstDouble(map, const <String>['mlxObject']);
    final sensorError = _toBool(map['sensorError']) ?? false;
    final fireDetected = _toBool(map['fireDetected']) ?? false;

    final status =
        (map['status'] as String?) ??
        _deriveStatus(
          temperature: temperature,
          smoke: smoke,
          gas: gas,
          hasSensorError: sensorError,
          fireDetected: fireDetected,
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
      mlxAmbient: mlxAmbient,
      mlxObject: mlxObject,
      lastUpdated: _parseTimestamp(map['timestamp'] ?? map['lastUpdated']),
      fireDetected: fireDetected,
      hasSensorError: sensorError,
      hasHumidityReading: hasHumidityReading,
      hasSmokeReading: hasSmokeReading,
      hasMlxAmbientReading: hasMlxAmbientReading,
      hasMlxObjectReading: hasMlxObjectReading,
    );
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
    double? mlxAmbient,
    double? mlxObject,
    DateTime? lastUpdated,
    bool? fireDetected,
    bool? hasSensorError,
    bool? hasHumidityReading,
    bool? hasSmokeReading,
    bool? hasMlxAmbientReading,
    bool? hasMlxObjectReading,
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
      mlxAmbient: mlxAmbient ?? this.mlxAmbient,
      mlxObject: mlxObject ?? this.mlxObject,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      fireDetected: fireDetected ?? this.fireDetected,
      hasSensorError: hasSensorError ?? this.hasSensorError,
      hasHumidityReading: hasHumidityReading ?? this.hasHumidityReading,
      hasSmokeReading: hasSmokeReading ?? this.hasSmokeReading,
      hasMlxAmbientReading: hasMlxAmbientReading ?? this.hasMlxAmbientReading,
      hasMlxObjectReading: hasMlxObjectReading ?? this.hasMlxObjectReading,
    );
  }

  static bool _hasAnyKey(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        return true;
      }
    }
    return false;
  }

  static double? _firstDouble(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final parsed = _toDouble(map[key]);
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
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

  static bool? _toBool(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }

    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == '0') {
      return false;
    }

    return null;
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
    bool fireDetected = false,
  }) {
    if (fireDetected) {
      return 'danger';
    }

    return SeverityEvaluator.evaluateSeverity(
      temperature: temperature,
      smoke: smoke,
      gas: gas,
      hasSensorError: hasSensorError,
    );
  }
}
