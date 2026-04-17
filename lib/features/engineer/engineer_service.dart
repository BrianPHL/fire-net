import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../models/sensor_node.dart';
import '../../models/threshold_config.dart';
import '../../services/threshold_config_service.dart';

class EngineerService {
  EngineerService({
    FirebaseDatabase? database,
    ThresholdConfigService? thresholdConfigService,
  }) : _database = database ?? _buildDatabase(),
       _thresholdConfigService =
           thresholdConfigService ?? ThresholdConfigService();

  final FirebaseDatabase _database;
  final ThresholdConfigService _thresholdConfigService;

  DatabaseReference get _sensorNodesRef => _database.ref('sensor_nodes');

  Stream<List<SensorNode>> streamSensorNodes() {
    late StreamController<List<SensorNode>> controller;
    StreamSubscription<DatabaseEvent>? sensorSubscription;
    StreamSubscription<ThresholdConfig?>? thresholdSubscription;
    ThresholdConfig activeThresholds = ThresholdConfig.defaults();
    dynamic lastPayload;

    void emitFromPayload(dynamic payload) {
      if (controller.isClosed) {
        return;
      }
      controller.add(_buildSensorNodesFromValue(payload, activeThresholds));
    }

    void emitLastPayload() {
      if (lastPayload != null) {
        emitFromPayload(lastPayload);
      }
    }

    controller = StreamController<List<SensorNode>>.broadcast(
      onListen: () {
        thresholdSubscription = _thresholdConfigService
            .watchThresholdConfig()
            .listen(
          (config) {
            activeThresholds = config ?? ThresholdConfig.defaults();
            emitLastPayload();
          },
          onError: (Object error) {
            activeThresholds = ThresholdConfig.defaults();
            emitLastPayload();
          },
        );

        sensorSubscription = _sensorNodesRef.onValue.listen(
          (event) {
            lastPayload = event.snapshot.value;
            emitFromPayload(lastPayload);
          },
          onError: (Object error) {
            if (!controller.isClosed) {
              controller.addError(error);
            }
          },
        );
      },
      onCancel: () {
        sensorSubscription?.cancel();
        thresholdSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  bool _isSingleNodePayload(Map<dynamic, dynamic> value) {
    return value.containsKey('temperature') ||
        value.containsKey('mq2') ||
        value.containsKey('mq7') ||
        value.containsKey('humidity') ||
        value.containsKey('smoke') ||
        value.containsKey('gasLevel') ||
        value.containsKey('gas') ||
        value.containsKey('mlxAmbient') ||
        value.containsKey('mlxObject') ||
        value.containsKey('fireDetected') ||
        value.containsKey('readings') ||
        value.containsKey('sensorData') ||
        value.containsKey('sensors');
  }

  List<SensorNode> _buildSensorNodesFromValue(
    dynamic value,
    ThresholdConfig thresholds,
  ) {
    if (value == null) {
      return <SensorNode>[];
    }

    if (value is Map<dynamic, dynamic>) {
      if (_isSingleNodePayload(value)) {
        return <SensorNode>[
          SensorNode.fromRealtimeDb(
            'esp32-node-1',
            value,
            thresholds: thresholds,
          ),
        ];
      }

      final sensors = <SensorNode>[];
      value.forEach((key, nodeValue) {
        if (nodeValue is Map<dynamic, dynamic>) {
          sensors.add(
            SensorNode.fromRealtimeDb(
              key.toString(),
              nodeValue,
              thresholds: thresholds,
            ),
          );
        }
      });

      sensors.sort((a, b) => a.name.compareTo(b.name));
      return sensors;
    }

    return <SensorNode>[];
  }

  static FirebaseDatabase _buildDatabase() {
    final databaseUrl = (dotenv.env['FIREBASE_DATABASE_URL'] ?? '').trim();
    if (databaseUrl.isEmpty) {
      return FirebaseDatabase.instance;
    }

    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    );
  }
}
