import 'package:flutter/material.dart';
import '../../../shared/layouts/engineer_scaffold.dart';
import '../../../models/sensor_node.dart';
import '../widgets/node_management_card.dart';

class SensorManagementScreen extends StatefulWidget {
  const SensorManagementScreen({super.key});

  @override
  State<SensorManagementScreen> createState() => _SensorManagementScreenState();
}

class _SensorManagementScreenState extends State<SensorManagementScreen> {
  String? expandedNodeId;

  @override
  Widget build(BuildContext context) {
    final nodes = SensorNode.getMockNodes();

    return EngineerScaffold(
      title: 'Node Management',
      currentIndex: 1,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Network configuration & status',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            
            // Node list
            ...nodes.map((node) => NodeManagementCard(
              node: node,
              isExpanded: expandedNodeId == node.id,
              onToggle: () {
                setState(() {
                  expandedNodeId = expandedNodeId == node.id ? null : node.id;
                });
              },
            )),
          ],
        ),
      ),
    );
  }
}