import 'package:flutter/material.dart';
import '../../../shared/layouts/engineer_scaffold.dart';
import '../../../models/sensor_node.dart';
import '../engineer_service.dart';
import '../widgets/node_management_card.dart';

class SensorManagementScreen extends StatefulWidget {
  const SensorManagementScreen({super.key});

  @override
  State<SensorManagementScreen> createState() => _SensorManagementScreenState();
}

class _SensorManagementScreenState extends State<SensorManagementScreen> {
  String? expandedNodeId;
  final _engineerService = EngineerService();

  @override
  Widget build(BuildContext context) {
    return EngineerScaffold(
      title: 'Node Management',
      currentIndex: 1,
      body: StreamBuilder<List<SensorNode>>(
        stream: _engineerService.streamSensorNodes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Failed to load live sensor data.'),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final nodes = snapshot.data ?? <SensorNode>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Network configuration & status',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (nodes.isEmpty)
                  const Text('No live sensor nodes found.')
                else
                  ...nodes.map((node) => NodeManagementCard(
                    node: node,
                    isExpanded: expandedNodeId == node.id,
                    onToggle: () {
                      setState(() {
                        expandedNodeId = expandedNodeId == node.id
                            ? null
                            : node.id;
                      });
                    },
                  )),
              ],
            ),
          );
        },
      ),
    );
  }
}