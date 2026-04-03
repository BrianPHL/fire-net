import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/sensor_node.dart';
import '../../../models/alert.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/layouts/app_scaffold.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../auth/auth_service.dart';
import '../user_service.dart';
import '../widgets/sensor_card.dart';
import '../widgets/hazard_indicator.dart';

/// Home screen showing sensor network overview and active alerts
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();
  final _userService = UserService();

  List<SensorNode> _lastKnownSensors = const <SensorNode>[];
  final List<Alert> _alerts = Alert.getMockAlerts();

  void _onNavigationChanged(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.alerts);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.alertHistory);
        break;
    }
  }

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
    return AppScaffold(
      title: 'User Panel',
      currentIndex: _currentIndex,
      onNavigationChanged: _onNavigationChanged,
      onLogout: _handleLogout,
      body: StreamBuilder<List<SensorNode>>(
        stream: _userService.streamSensorNodes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _lastKnownSensors = snapshot.data!;
          }

          final sensors = snapshot.data ?? _lastKnownSensors;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildEmergencyBanner(),
                  const SizedBox(height: 24),
                  _buildStatusCards(sensors),
                  const SizedBox(height: 24),
                  _buildRealtimeBanner(),
                  const SizedBox(height: 16),
                  _buildSensorNetwork(
                    sensors,
                    hasError: snapshot.hasError,
                    isWaiting:
                        snapshot.connectionState == ConnectionState.waiting,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return AppSectionHeader(
              title: Helpers.getGreeting(),
              subtitle: Helpers.formatDateTime(DateTime.now()),
              trailing: StatusPill(
                label: 'Live',
                color: ThemeColors.getSafe(context),
                backgroundColor: ThemeColors.getSafeBackground(context),
                icon: Icons.wifi,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // Text(
        //   'Welcome back! Here\'s the latest on your sensor network.',
        //   style: Theme.of(context).textTheme.bodyMedium,
        // ),
      ],
    );
  }

  Widget _buildEmergencyBanner() {
    final activeEmergency = _alerts.firstWhere(
      (alert) => alert.isActive && alert.severity == 'danger',
      orElse: () => _alerts.first,
    );

    if (activeEmergency.severity != 'danger') {
      return const SizedBox.shrink();
    }

    return Builder(
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: ThemeColors.getDangerBackground(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ThemeColors.getDanger(context), width: 1),
        ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.alertDetail,
              arguments: activeEmergency,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_fire_department,
                    color: ThemeColors.getDanger(context),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1 Active Emergency',
                        style: TextStyle(
                          color: ThemeColors.getDanger(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tap to view details',
                        style: TextStyle(
                          color: ThemeColors.getTextSecondary(context),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: ThemeColors.getDanger(context),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildStatusCards(List<SensorNode> sensors) {
    final activeAlerts = _alerts.where((a) => a.isActive).length;
    final dangerNodes = sensors.where((s) => s.status == 'danger').length;

    return Row(
      children: [
        Expanded(
          child: HazardIndicator(
            severity: 'warning',
            count: activeAlerts,
            label: 'Active Alerts',
            onTap: () => Navigator.pushNamed(context, AppRoutes.alerts),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: HazardIndicator(
            severity: 'danger',
            count: dangerNodes,
            label: 'Nodes in Danger',
            onTap: () => Navigator.pushNamed(context, AppRoutes.sensors),
          ),
        ),
      ],
    );
  }

  Widget _buildRealtimeBanner() {
    return StreamBuilder<bool>(
      stream: _userService.streamFirebaseConnection(),
      builder: (context, snapshot) {
        final connected = snapshot.data ?? false;
        final color = connected ? ThemeColors.getSafe(context) : ThemeColors.getWarning(context);
        final bg = connected
            ? ThemeColors.getSafeBackground(context)
            : ThemeColors.getWarningBackground(context);
        final text = connected
            ? 'Firebase connected: live sensor stream active'
            : 'Firebase disconnected: showing last known data';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: color.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              Icon(
                connected ? Icons.wifi : Icons.wifi_off,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSensorNetwork(
    List<SensorNode> sensors, {
    required bool hasError,
    required bool isWaiting,
  }) {
    if (hasError) {
      return Text(
        'Failed to load sensor data from Firebase.',
        style: TextStyle(
          color: ThemeColors.getDanger(context),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final activeNodes = sensors.length;

    if (sensors.isEmpty && isWaiting) {
      return const Center(child: CircularProgressIndicator());
    }

    final statusColor = hasError ? ThemeColors.getDanger(context) : ThemeColors.getSafe(context);
    final statusLabel = hasError
        ? 'Stream Error'
        : '$activeNodes Nodes Active';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            final backgroundColor = hasError
                ? ThemeColors.getDangerBackground(context)
                : ThemeColors.getSafeBackground(context);
            return AppSectionHeader(
              title: 'Sensor Network',
              subtitle: 'Real-time node status and latest telemetry',
              trailing: StatusPill(
                label: statusLabel,
                color: statusColor,
                backgroundColor: backgroundColor,
                icon: hasError ? Icons.error_outline : Icons.hub,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        if (sensors.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.sensors_off, color: ThemeColors.getTextTertiary(context)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No sensor data yet. Start ESP32 upload to Firebase.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sensors.length,
                itemBuilder: (context, index) {
                  final sensor = sensors[index];
                  return SensorCard(
                    sensor: sensor,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.sensorDetail,
                        arguments: sensor,
                      );
                    },
                  );
                },
          ),
      ],
    );
  }
}
