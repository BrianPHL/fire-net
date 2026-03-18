import 'package:flutter/material.dart';
import '../../../shared/layouts/engineer_scaffold.dart';
import '../../../models/sensor_node.dart';
import '../engineer_service.dart';
import '../widgets/system_status_card.dart';
import '../widgets/info_card.dart';
import '../widgets/node_health_card.dart';

class SystemDiagnosticsScreen extends StatelessWidget {
  const SystemDiagnosticsScreen({super.key});

  static final EngineerService _engineerService = EngineerService();

  @override
  Widget build(BuildContext context) {
    final uptime = 99.9; // Mock data

    return EngineerScaffold(
      title: 'System Diagnostics',
      currentIndex: 3,
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
          final onlineNodes = nodes.length;
          final totalNodes = nodes.length;

          return SingleChildScrollView(
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

                if (nodes.isEmpty)
                  const Text('No live sensor nodes found.')
                else
                  ...nodes.map((node) => NodeHealthCard(node: node)),
              ],
            ),
          );
        },
      ),
    );
  }
}