import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/sensor_node.dart';

class NodeHealthCard extends StatelessWidget {
  final SensorNode node;

  const NodeHealthCard({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    // Mock health data
    final batteryLevel = _getBatteryLevel(node.id);
    final signalLevel = _getSignalLevel(node.id);
    final lastCheckIn = _getLastCheckIn(node.lastUpdated);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status badge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        node.location,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.safe.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
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
                      const SizedBox(width: 6),
                      Text(
                        'Online',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.safe,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Battery indicator
            Row(
              children: [
                const Icon(
                  Icons.battery_charging_full,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      // Battery bars
                      ...List.generate(5, (index) {
                        final isActive = index < (batteryLevel / 20).floor();
                        return Container(
                          width: 12,
                          height: 20,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.safe
                                : AppColors.cardBackgroundLight,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                Text(
                  '$batteryLevel %',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Signal indicator
            Row(
              children: [
                const Icon(
                  Icons.signal_cellular_alt,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      // Signal bars
                      ...List.generate(5, (index) {
                        final isActive = index < (signalLevel / 20).floor();
                        final height = 12.0 + (index * 4.0);
                        return Container(
                          width: 8,
                          height: height,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.safe
                                : AppColors.cardBackgroundLight,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                Text(
                  '$signalLevel %',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Last check-in
            Text(
              'Last check-in: $lastCheckIn',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  int _getBatteryLevel(String nodeId) {
    // Mock data based on node ID
    switch (nodeId) {
      case '1':
        return 87;
      case '2':
        return 62;
      case '3':
        return 54;
      default:
        return 75;
    }
  }

  int _getSignalLevel(String nodeId) {
    // Mock data based on node ID
    switch (nodeId) {
      case '1':
        return 92;
      case '2':
        return 75;
      case '3':
        return 82;
      default:
        return 80;
    }
  }

  String _getLastCheckIn(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
