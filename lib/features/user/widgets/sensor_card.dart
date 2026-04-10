import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/sensor_node.dart';
import '../../../shared/widgets/status_pill.dart';

/// Sensor card widget for displaying sensor node information
class SensorCard extends StatelessWidget {
  final SensorNode sensor;
  final VoidCallback? onTap;

  const SensorCard({super.key, required this.sensor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildReadings(context),
                  const SizedBox(height: 12),
                  _buildFooter(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Status indicator
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusBackgroundColor(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              sensor.name[0].toUpperCase(),
              style: TextStyle(
                color: _getStatusColor(context),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Name and location
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sensor.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                sensor.location,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        // Status badge
        StatusPill(
          label: _getStatusText(),
          color: _getStatusColor(context),
          backgroundColor: _getStatusBackgroundColor(context),
          icon: _getStatusIcon(),
        ),
      ],
    );
  }

  Widget _buildReadings(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildReadingItem(
              context,
              Icons.thermostat,
              ThemeColors.getTemperatureColor(context),
              '${sensor.temperature.toStringAsFixed(1)}°',
              label: 'Temp',
            ),
            const SizedBox(width: 16),
            _buildReadingItem(
              context,
              Icons.water_drop,
              ThemeColors.getPrimary(context),
              '${sensor.humidity.toStringAsFixed(1)}%',
              label: 'Humidity',
              isUnavailable: !sensor.hasHumidityReading,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildReadingItem(
              context,
              Icons.smoke_free,
              ThemeColors.getSmokeColor(context),
              sensor.hasSmokeReading ? sensor.smoke.toStringAsFixed(1) : 'N/A',
              label: 'CO',
              isUnavailable: !sensor.hasSmokeReading,
            ),
            const SizedBox(width: 16),
            _buildReadingItem(
              context,
              Icons.local_fire_department,
              ThemeColors.getGasColor(context),
              sensor.gas.toStringAsFixed(1),
              label: 'Gas',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadingItem(
    BuildContext context,
    IconData icon,
    Color color,
    String value, {
    String? label,
    bool isUnavailable = false,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null)
                  Text(
                    label,
                    style: TextStyle(
                      color: ThemeColors.getTextSecondary(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (label != null) const SizedBox(height: 2),
                isUnavailable
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: StatusPill(
                            label: 'Unavailable',
                            color: ThemeColors.getWarning(context),
                            backgroundColor: ThemeColors.getWarningBackground(
                              context,
                            ),
                            icon: Icons.warning_amber,
                          ),
                        ),
                      )
                    : Text(
                        value,
                        style: TextStyle(
                          color: ThemeColors.getTextPrimary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 14,
          color: ThemeColors.getTextSecondary(context),
        ),
        const SizedBox(width: 4),
        Text(
          'Updated ${Helpers.getRelativeTime(sensor.lastUpdated)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Spacer(),
        Text(
          'View Details',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: ThemeColors.getPrimary(context),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: ThemeColors.getPrimary(context),
        ),
      ],
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
        return ThemeColors.getPrimary(context);
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
