import 'package:flutter/material.dart';
import '../../../shared/layouts/engineer_scaffold.dart';
import '../../../models/sensor_node.dart';
import '../widgets/system_status_card.dart';
import '../widgets/info_card.dart';
import '../widgets/node_health_card.dart';

class SystemDiagnosticsScreen extends StatelessWidget {
  const SystemDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nodes = SensorNode.getMockNodes();
    final onlineNodes = nodes.length; // Mock data
    final totalNodes = nodes.length;
    final uptime = 99.9; // Mock data

    return EngineerScaffold(
      title: 'System Diagnostics',
      currentIndex: 3,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health & Logs',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            const SystemStatusCard(),

            const SizedBox(height: 24),

            // Network and Uptime cards
            Row(
              children: [
                Expanded(
                  child: InfoCard(
                    icon: Icons.wifi,
                    label: 'Network',
                    value: '$onlineNodes/$totalNodes Online',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InfoCard(
                    icon: Icons.schedule,
                    label: 'Uptime',
                    value: '$uptime%',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Node Health Section
            Text(
              'Node Health',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            ...nodes.map((node) => NodeHealthCard(node: node)),
          ],
        ),
      ),
    );
  }
}