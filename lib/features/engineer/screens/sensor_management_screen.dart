import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/layouts/engineer_scaffold.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/status_pill.dart';
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
          final dangerCount = nodes.where((node) => node.status == 'danger').length;
          final warningCount = nodes.where((node) => node.status == 'warning').length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionHeader(
                  title: 'Network Configuration',
                  subtitle: 'Inspect sensor nodes and expand for live diagnostics',
                  trailing: StatusPill(
                    label: '${nodes.length} Nodes',
                    color: AppColors.primary,
                    backgroundColor: AppColors.cardBackgroundLight,
                    icon: Icons.hub,
                  ),
                ),
                const SizedBox(height: 12),
                if (nodes.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      StatusPill(
                        label: '$dangerCount danger',
                        color: AppColors.danger,
                        backgroundColor: AppColors.dangerBackground,
                        icon: Icons.local_fire_department,
                      ),
                      StatusPill(
                        label: '$warningCount warning',
                        color: AppColors.warning,
                        backgroundColor: AppColors.warningBackground,
                        icon: Icons.warning_amber,
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                if (nodes.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Icon(Icons.sensors_off, color: AppColors.textTertiary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No live sensor nodes found. Ensure the devices are online and streaming telemetry.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
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