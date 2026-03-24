import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/layouts/engineer_scaffold.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../../models/sensor_node.dart';
import '../../../models/alert.dart';
import '../../../routes/app_routes.dart';
import '../engineer_service.dart';
import '../widgets/system_stat_card.dart';
import '../widgets/active_alerts_panel.dart';
import '../widgets/node_status_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static final EngineerService _engineerService = EngineerService();

  @override
  Widget build(BuildContext context) {
    final alerts = Alert.getMockAlerts();
    final activeAlerts = alerts.where((a) => a.isActive).toList();

    return EngineerScaffold(
      title: 'Engineer Panel',
      currentIndex: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'System Configuration',
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.systemConfig);
          },
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 900;

          return StreamBuilder<List<SensorNode>>(
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
              final warningOrDangerNodes = nodes
                  .where((node) => node.status == 'warning' || node.status == 'danger')
                  .length;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSectionHeader(
                      title: 'System Overview',
                      subtitle: 'Engineer telemetry and node health at a glance',
                      trailing: StatusPill(
                        label: warningOrDangerNodes == 0
                            ? 'All Stable'
                            : '$warningOrDangerNodes Need Attention',
                        color: warningOrDangerNodes == 0
                            ? AppColors.safe
                            : AppColors.warning,
                        backgroundColor: warningOrDangerNodes == 0
                            ? AppColors.safeBackground
                            : AppColors.warningBackground,
                        icon: warningOrDangerNodes == 0
                            ? Icons.check_circle
                            : Icons.priority_high,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // System stats cards
                    if (isWideScreen)
                      Row(
                        children: [
                          Expanded(
                            child: SystemStatCard(
                              icon: Icons.router,
                              value: '${nodes.length}/${nodes.length}',
                              label: 'Nodes Online',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SystemStatCard(
                              icon: Icons.battery_charging_full,
                              value: _calculateAvgBattery(nodes),
                              label: 'Avg Battery',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SystemStatCard(
                              icon: Icons.signal_cellular_alt,
                              value: _calculateAvgSignal(nodes),
                              label: 'Avg Signal',
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: SystemStatCard(
                              icon: Icons.router,
                              value: '${nodes.length}/${nodes.length}',
                              label: 'Nodes Online',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SystemStatCard(
                              icon: Icons.battery_charging_full,
                              value: _calculateAvgBattery(nodes),
                              label: 'Avg Battery',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SystemStatCard(
                              icon: Icons.signal_cellular_alt,
                              value: _calculateAvgSignal(nodes),
                              label: 'Avg Signal',
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 24),

                    // Active System Alerts
                    ActiveAlertsPanel(alerts: activeAlerts),

                    const SizedBox(height: 24),

                    // Node Status
                    NodeStatusSection(nodes: nodes),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _calculateAvgBattery(List<SensorNode> nodes) {
    // Mock calculation lang
    return '68%';
  }

  String _calculateAvgSignal(List<SensorNode> nodes) {
    // Mock calculation lang
    return '83%';
  }
}