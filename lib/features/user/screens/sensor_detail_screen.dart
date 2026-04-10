import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/sensor_node.dart';
import '../../../models/alert.dart';
import '../../../services/alert_service.dart';
import '../../../shared/widgets/status_pill.dart';

/// Sensor detail screen showing comprehensive sensor readings and trends
class SensorDetailScreen extends StatelessWidget {
  final SensorNode sensor;
  final AlertService _alertService = AlertService();

  SensorDetailScreen({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(sensor.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Builder(
                builder: (context) => StatusPill(
                  label: _getStatusText(),
                  color: _getStatusColor(context),
                  backgroundColor: _getStatusBackgroundColor(context),
                  icon: _getStatusIcon(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Alert>>(
        stream: _alertService.watchAlerts(),
        builder: (context, snapshot) {
          final relatedAlerts = (snapshot.data ?? <Alert>[])
              .where((alert) => alert.nodeId == sensor.id)
              .toList();

          Alert? activeDangerAlert;
          for (final alert in relatedAlerts) {
            if (alert.isActive && alert.severity == 'danger') {
              activeDangerAlert = alert;
              break;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationHeader(),
                const SizedBox(height: 24),
                _buildReadingsGrid(context),
                const SizedBox(height: 24),
                _buildTrendUnavailable(context),
                const SizedBox(height: 24),
                if (activeDangerAlert != null)
                  _buildAlertExplanation(context, activeDangerAlert),
                const SizedBox(height: 16),
                _buildRecentAlerts(context, relatedAlerts),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Builder(
      builder: (context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getStatusBackgroundColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on,
                  color: _getStatusColor(context),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sensor.location,
                      style: TextStyle(
                        color: ThemeColors.getTextPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Updated ${Helpers.getRelativeTime(sensor.lastUpdated)}',
                      style: TextStyle(
                        color: ThemeColors.getTextSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingsGrid(BuildContext context) {
    return Column(
      children: [
        _buildReadingCard(
          context,
          'Temperature',
          sensor.temperature,
          '°C',
          Icons.thermostat,
          ThemeColors.getTemperatureColor(context),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildReadingCard(
                context,
                'Humidity',
                sensor.humidity,
                '%',
                Icons.water_drop,
                ThemeColors.getPrimary(context),
                isAvailable: sensor.hasHumidityReading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildReadingCard(
                context,
                'Carbon Monoxide',
                sensor.smoke,
                'ppm',
                Icons.smoke_free,
                ThemeColors.getSmokeColor(context),
                isAvailable: sensor.hasSmokeReading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildReadingCard(
                context,
                'Gas',
                sensor.gas,
                'ppm',
                Icons.local_fire_department,
                ThemeColors.getPrimary(context),
              ),
            ),
          ],
        ),
        if (sensor.hasMlxAmbientReading || sensor.hasMlxObjectReading) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildReadingCard(
                  context,
                  'IR Ambient',
                  sensor.mlxAmbient ?? 0,
                  '°C',
                  Icons.thermostat,
                  ThemeColors.getTemperatureColor(context),
                  isAvailable: sensor.hasMlxAmbientReading,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReadingCard(
                  context,
                  'IR Object',
                  sensor.mlxObject ?? 0,
                  '°C',
                  Icons.center_focus_strong,
                  ThemeColors.getTemperatureColor(context),
                  isAvailable: sensor.hasMlxObjectReading,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildReadingCard(
    BuildContext context,
    String label,
    double value,
    String unit,
    IconData icon,
    Color color, {
    bool isAvailable = true,
  }) {
    return Card(
      color: ThemeColors.getCardBackgroundLight(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: ThemeColors.getTextSecondary(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isAvailable)
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value.toStringAsFixed(1),
                      style: TextStyle(
                        color: color,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' $unit',
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Builder(
                  builder: (context) => StatusPill(
                    label: 'Sensor Unavailable',
                    color: ThemeColors.getWarning(context),
                    backgroundColor: ThemeColors.getWarningBackground(context),
                    icon: Icons.warning_amber,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendUnavailable(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '24h Temperature Trend',
              style: TextStyle(
                color: ThemeColors.getTextPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Historical trend data unavailable',
                  style: TextStyle(
                    color: ThemeColors.getTextSecondary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertExplanation(BuildContext context, Alert alert) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: ThemeColors.getDangerBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb_outline, color: AppColors.danger, size: 20),
              SizedBox(width: 8),
              Text(
                'Alert Explanation',
                style: TextStyle(
                  color: AppColors.danger,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            alert.explanation ?? alert.description,
            style: TextStyle(
              color: ThemeColors.getTextPrimary(context),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAlerts(BuildContext context, List<Alert> relatedAlerts) {
    final alerts = relatedAlerts.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Alerts',
          style: TextStyle(
            color: ThemeColors.getTextPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (alerts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: ThemeColors.getSafe(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No recent alerts',
                      style: TextStyle(
                        color: ThemeColors.getTextSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...alerts.map((alert) => _buildAlertItem(context, alert)),
      ],
    );
  }

  Widget _buildAlertItem(BuildContext context, Alert alert) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: alert.severity == 'danger'
                    ? ThemeColors.getDangerBackground(context)
                    : ThemeColors.getWarningBackground(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                alert.severity == 'danger'
                    ? Icons.local_fire_department
                    : Icons.warning_amber,
                color: alert.severity == 'danger'
                    ? AppColors.danger
                    : AppColors.warning,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: TextStyle(
                      color: ThemeColors.getTextPrimary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Helpers.getRelativeTime(alert.triggeredAt),
                    style: TextStyle(
                      color: ThemeColors.getTextSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    switch (sensor.status) {
      case 'danger':
        return ThemeColors.getDanger(context);
      case 'warning':
        return ThemeColors.getWarning(context);
      case 'safe':
        return ThemeColors.getSafe(context);
      default:
        return ThemeColors.getTextSecondary(context);
    }
  }

  Color _getStatusBackgroundColor(BuildContext context) {
    switch (sensor.status) {
      case 'danger':
        return ThemeColors.getDangerBackground(context);
      case 'warning':
        return ThemeColors.getWarningBackground(context);
      case 'safe':
        return ThemeColors.getSafeBackground(context);
      default:
        return ThemeColors.getCardBackgroundLight(context);
    }
  }

  String _getStatusText() {
    switch (sensor.status) {
      case 'danger':
        return 'Danger';
      case 'warning':
        return 'Warning';
      case 'safe':
        return 'Safe';
      default:
        return 'Offline';
    }
  }

  IconData _getStatusIcon() {
    switch (sensor.status) {
      case 'danger':
        return Icons.error;
      case 'warning':
        return Icons.warning_amber;
      case 'safe':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }
}
