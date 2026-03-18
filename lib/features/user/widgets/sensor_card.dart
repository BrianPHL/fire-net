import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/sensor_node.dart';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildReadings(),
              const SizedBox(height: 12),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Status indicator
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusBackgroundColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              sensor.name[0].toUpperCase(),
              style: TextStyle(
                color: _getStatusColor(),
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
              Text(
                sensor.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sensor.location,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusBackgroundColor(),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(),
            style: TextStyle(
              color: _getStatusColor(),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadings() {
    return Column(
      children: [
        Row(
          children: [
            _buildReadingItem(
              Icons.thermostat,
              AppColors.temperatureColor,
              '${sensor.temperature.toStringAsFixed(1)}°',
            ),
            const SizedBox(width: 16),
            _buildReadingItem(
              Icons.water_drop,
              AppColors.primary,
              '${sensor.humidity.toStringAsFixed(1)}%',
              isUnavailable: !sensor.hasHumidityReading,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildReadingItem(
              Icons.smoke_free,
              AppColors.smokeColor,
              sensor.hasSmokeReading ? sensor.smoke.toStringAsFixed(1) : 'N/A',
              isUnavailable: !sensor.hasSmokeReading,
            ),
            const SizedBox(width: 16),
            _buildReadingItem(
              Icons.local_fire_department,
              AppColors.gasColor,
              sensor.gas.toStringAsFixed(1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadingItem(
    IconData icon,
    Color color,
    String value,
    {bool isUnavailable = false}
  ) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: isUnavailable
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.6),
                        ),
                      ),
                      child: const Text(
                        'Unavailable',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          'Updated ${Helpers.getRelativeTime(sensor.lastUpdated)}',
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
        ),
        const Spacer(),
        const Text(
          'View Details',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
      ],
    );
  }

  Color _getStatusColor() {
    switch (sensor.status) {
      case 'danger':
        return AppColors.danger;
      case 'warning':
        return AppColors.warning;
      case 'safe':
        return AppColors.safe;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusBackgroundColor() {
    switch (sensor.status) {
      case 'danger':
        return AppColors.dangerBackground;
      case 'warning':
        return AppColors.warningBackground;
      case 'safe':
        return AppColors.safeBackground;
      default:
        return AppColors.cardBackgroundLight;
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
}
