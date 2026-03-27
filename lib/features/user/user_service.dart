import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../models/sensor_node.dart';

class UserService {
  UserService({FirebaseDatabase? database})
    : _database = database ?? _buildDatabase();

  final FirebaseDatabase _database;

  DatabaseReference get _sensorNodesRef => _database.ref('sensor_nodes');

  Stream<List<SensorNode>> streamSensorNodes() {
    return _sensorNodesRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) {
        return <SensorNode>[];
      }

      if (value is Map<dynamic, dynamic>) {
        if (_isSingleNodePayload(value)) {
          return <SensorNode>[SensorNode.fromRealtimeDb('esp32-node-1', value)];
        }

        final sensors = <SensorNode>[];
        value.forEach((key, nodeValue) {
          if (nodeValue is Map<dynamic, dynamic>) {
            sensors.add(SensorNode.fromRealtimeDb(key.toString(), nodeValue));
          }
        });

        sensors.sort((a, b) => a.name.compareTo(b.name));
        return sensors;
      }

      return <SensorNode>[];
    });
  }

  Stream<bool> streamFirebaseConnection() {
    return _database
        .ref('.info/connected')
        .onValue
        .map((event) => event.snapshot.value == true);
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

  bool _isSingleNodePayload(Map<dynamic, dynamic> value) {
    return value.containsKey('temperature') ||
        value.containsKey('smoke') ||
        value.containsKey('humidity') ||
        value.containsKey('gasLevel') ||
        value.containsKey('gas');
  }
}
