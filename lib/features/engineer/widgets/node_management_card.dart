import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../models/sensor_node.dart';
import '../../../shared/widgets/status_pill.dart';

class NodeManagementCard extends StatelessWidget {
  final SensorNode node;
  final bool isExpanded;
  final VoidCallback onToggle;

  const NodeManagementCard({
    super.key,
    required this.node,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(node.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              node.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 8),
                            StatusPill(
                              label: 'Online',
                              color: AppColors.safe,
                              backgroundColor: ThemeColors.getSafeBackground(context),
                              icon: Icons.check_circle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${node.location} • ID: node-${node.id}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded) ...[
            Divider(height: 1, color: ThemeColors.getBorderColor(context)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Readings
                      Text(
                        'Current Readings',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ReadingCard(
                              icon: Icons.thermostat,
                              value: '${node.temperature.toStringAsFixed(1)}°',
                              label: 'Temp',
                              color: AppColors.temperatureColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ReadingCard(
                              icon: Icons.water_drop,
                              value: node.hasHumidityReading
                                  ? node.humidity.toStringAsFixed(0)
                                  : 'N/A',
                              label: 'Humidity',
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ReadingCard(
                              icon: Icons.smoke_free,
                              value: node.hasSmokeReading
                                  ? node.smoke.toStringAsFixed(0)
                                  : 'N/A',
                              label: 'Smoke',
                              color: AppColors.smokeColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ReadingCard(
                              icon: Icons.science,
                              value: node.gas.toStringAsFixed(0),
                              label: 'Gas',
                              color: AppColors.gasColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Device Health
                      Text(
                        'Device Health',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      const DeviceHealthIndicator(
                        icon: Icons.battery_charging_full,
                        label: 'Battery Level',
                        value: 87,
                      ),
                      const SizedBox(height: 12),
                      const DeviceHealthIndicator(
                        icon: Icons.signal_cellular_alt,
                        label: 'Signal Strength',
                        value: 92,
                      ),
                      const SizedBox(height: 20),

                      // Status info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ThemeColors.getBorderColor(context), width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Last updated: ${_formatDateTime(node.lastUpdated)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            StatusPill(
                              label: _getStatusLabel(node.status),
                              color: statusColor,
                              backgroundColor: ThemeColors.getSafeBackground(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'safe':
        return AppColors.safe;
      case 'warning':
        return AppColors.warning;
      case 'danger':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
  }
}

/// Reading card for sensor values
class ReadingCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const ReadingCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isUnavailable = value == 'N/A';

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ThemeColors.getCardBackgroundLight(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 28,
              ),
              const SizedBox(height: 8),
              if (isUnavailable)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ThemeColors.getWarningBackground(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.6)),
                  ),
                  child: const Text(
                    'Unavailable',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Device health indicator with progress bar
class DeviceHealthIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const DeviceHealthIndicator({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: ThemeColors.getTextSecondary(context),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  '$value %',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 8,
                backgroundColor: ThemeColors.getCardBackgroundLight(context),
                valueColor: AlwaysStoppedAnimation<Color>(
                  value >= 70 ? AppColors.safe : value >= 40 ? AppColors.warning : AppColors.danger,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
