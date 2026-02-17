import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/sensor_node.dart';
import '../../../models/alert.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/layouts/app_scaffold.dart';
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

  // Mock data - in real app, this would come from state management
  final List<SensorNode> _sensors = SensorNode.getMockNodes();
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: _currentIndex,
      onNavigationChanged: _onNavigationChanged,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildEmergencyBanner(),
              const SizedBox(height: 24),
              _buildStatusCards(),
              const SizedBox(height: 24),
              _buildSensorNetwork(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Helpers.getGreeting(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              Helpers.formatTime(DateTime.now()),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'FireNet Active',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.dangerBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger, width: 1),
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
                    color: AppColors.danger.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: AppColors.danger,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1 Active Emergency',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tap to view details',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.danger,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCards() {
    final activeAlerts = _alerts.where((a) => a.isActive).length;
    final dangerNodes = _sensors.where((s) => s.status == 'danger').length;

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

  Widget _buildSensorNetwork() {
    final activeNodes = _sensors.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Sensor Network',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.safeBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$activeNodes Nodes Active',
                style: const TextStyle(
                  color: AppColors.safe,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _sensors.length,
          itemBuilder: (context, index) {
            final sensor = _sensors[index];
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
