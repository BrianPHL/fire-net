import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/layouts/engineer_scaffold.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../../models/sensor_node.dart';
import '../../../models/alert.dart';
import '../../../routes/app_routes.dart';
import '../../../services/alert_service.dart';
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
  static final AlertService _alertService = AlertService();

  @override
  Widget build(BuildContext context) {
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
                  .where(
                    (node) =>
                        node.status == Alert.severityWarning ||
                        node.status == Alert.severityDanger,
                  )
                  .length;

              return StreamBuilder<List<Alert>>(
                stream: _alertService.watchAlerts(status: Alert.statusActive),
                builder: (context, alertSnapshot) {
                  if (alertSnapshot.hasError) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Failed to load live alerts.'),
                      ),
                    );
                  }

                  final activeAlerts = alertSnapshot.data ?? <Alert>[];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, _) {
                            return AppSectionHeader(
                              title: 'System Overview',
                              subtitle: 'Engineer telemetry and node health at a glance',
                              trailing: StatusPill(
                                label: warningOrDangerNodes == 0
                                    ? 'All Stable'
                                    : '$warningOrDangerNodes Need Attention',
                                color: warningOrDangerNodes == 0
                                    ? ThemeColors.getSafe(context)
                                    : ThemeColors.getWarning(context),
                                backgroundColor: warningOrDangerNodes == 0
                                    ? ThemeColors.getSafeBackground(context)
                                    : ThemeColors.getWarningBackground(context),
                                icon: warningOrDangerNodes == 0
                                    ? Icons.check_circle
                                    : Icons.priority_high,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

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
                                  icon: Icons.notification_important,
                                  value: '${activeAlerts.length}',
                                  label: 'Active Alerts',
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
                                  icon: Icons.notification_important,
                                  value: '${activeAlerts.length}',
                                  label: 'Active Alerts',
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 24),

                        ActiveAlertsPanel(alerts: activeAlerts),

                        const SizedBox(height: 24),

                        NodeStatusSection(nodes: nodes),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

}