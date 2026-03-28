import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../models/sensor_node.dart';
import '../../../shared/widgets/status_pill.dart';

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
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return Column(
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
                StatusPill(
                  label: 'Online',
                  color: ThemeColors.getSafe(context),
                  backgroundColor: ThemeColors.getSafeBackground(context),
                  icon: Icons.check_circle,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Battery indicator
            Row(
              children: [
                Icon(
                  Icons.battery_charging_full,
                  size: 20,
                  color: Theme.of(context).textTheme.bodySmall?.color,
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
                                ? ThemeColors.getSafe(context)
                                : ThemeColors.getCardBackgroundLight(context),
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
                Icon(
                  Icons.signal_cellular_alt,
                  size: 20,
                  color: Theme.of(context).textTheme.bodySmall?.color,
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
                                ? ThemeColors.getSafe(context)
                                : ThemeColors.getCardBackgroundLight(context),
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
            );
          },
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
