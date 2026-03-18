import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/layouts/engineer_scaffold.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/sensor_node.dart';
import '../../../models/alert.dart';
import '../../../routes/app_routes.dart';
import '../../auth/auth_service.dart';
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
  final _authService = AuthService();

  Future<void> _handleLogout() async {
    final confirmed = await ErrorDialogHelper.showConfirmationDialog(
      context,
      title: 'Confirm Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      isDangerous: true,
    );

    if (!confirmed) {
      return;
    }

    try {
      await _authService.signOut();

      if (!mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      ErrorDialogHelper.showSnackbarError(
        context,
        AuthService.getLogoutErrorMessage(error),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ErrorDialogHelper.showSnackbarError(
        context,
        'Unable to logout. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final alerts = Alert.getMockAlerts();
    final activeAlerts = alerts.where((a) => a.isActive).toList();

    return EngineerScaffold(
      title: 'Engineer Panel',
      currentIndex: 0,
      onLogout: _handleLogout,
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

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Overview',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),

                    // System stats cards
                    if (isWideScreen)
                      Row(
                        children: [
                          Expanded(child: SystemStatCard(
                            icon: Icons.router,
                            value: '${nodes.length}/${nodes.length}',
                            label: 'Nodes Online',
                          )),
                          const SizedBox(width: 16),
                          Expanded(child: SystemStatCard(
                            icon: Icons.battery_charging_full,
                            value: _calculateAvgBattery(nodes),
                            label: 'Avg Battery',
                          )),
                          const SizedBox(width: 16),
                          Expanded(child: SystemStatCard(
                            icon: Icons.signal_cellular_alt,
                            value: _calculateAvgSignal(nodes),
                            label: 'Avg Signal',
                          )),
                        ],
                      )
                    else
                      Column(
                        children: [
                          SystemStatCard(
                            icon: Icons.router,
                            value: '${nodes.length}/${nodes.length}',
                            label: 'Nodes Online',
                          ),
                          const SizedBox(height: 12),
                          SystemStatCard(
                            icon: Icons.battery_charging_full,
                            value: _calculateAvgBattery(nodes),
                            label: 'Avg Battery',
                          ),
                          const SizedBox(height: 12),
                          SystemStatCard(
                            icon: Icons.signal_cellular_alt,
                            value: _calculateAvgSignal(nodes),
                            label: 'Avg Signal',
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