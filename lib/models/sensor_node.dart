/// Sensor node model representing a physical sensor device
class SensorNode {
  final String id;
  final String name;
  final String location;
  final String status; 
  final double temperature;
  final double smoke;
  final double gas;
  final DateTime lastUpdated;

  const SensorNode({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.temperature,
    required this.smoke,
    required this.gas,
    required this.lastUpdated,
  });

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
        smoke: 245.0,
        gas: 95.0,
        lastUpdated: now,
      ),
      SensorNode(
        id: '2',
        name: 'Garage Sensor',
        location: 'Garage',
        status: 'warning',
        temperature: 28.2,
        smoke: 25.0,
        gas: 180.0,
        lastUpdated: now.subtract(const Duration(seconds: 30)),
      ),
      SensorNode(
        id: '3',
        name: 'Kitchen Sensor',
        location: 'Kitchen',
        status: 'safe',
        temperature: 24.5,
        smoke: 12.0,
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
    double? smoke,
    double? gas,
    DateTime? lastUpdated,
  }) {
    return SensorNode(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      status: status ?? this.status,
      temperature: temperature ?? this.temperature,
      smoke: smoke ?? this.smoke,
      gas: gas ?? this.gas,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
