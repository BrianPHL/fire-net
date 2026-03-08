import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/sensor_node.dart';

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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.safe.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.safe,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Online',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.safe,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
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
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.borderColor),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
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
                          icon: Icons.smoke_free,
                          value: node.smoke.toStringAsFixed(0),
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
                      color: statusColor == AppColors.safe
                          ? AppColors.safeBackground
                          : statusColor == AppColors.warning
                              ? AppColors.warningBackground
                              : AppColors.dangerBackground,
                      borderRadius: BorderRadius.circular(8),
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
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: statusColor,
                            ),
                          ),
                        ),
                        Text(
                          _getStatusLabel(node.status),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.textSecondary,
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
            backgroundColor: AppColors.cardBackgroundLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              value >= 70 ? AppColors.safe : value >= 40 ? AppColors.warning : AppColors.danger,
            ),
          ),
        ),
      ],
    );
  }
}
