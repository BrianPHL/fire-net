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

            // Battery indicator (telemetry not currently provided by node payload)
            Row(
              children: [
                Icon(
                  Icons.battery_unknown,
                  size: 20,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Battery telemetry unavailable',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Signal indicator (telemetry not currently provided by node payload)
            Row(
              children: [
                Icon(
                  Icons.signal_cellular_alt,
                  size: 20,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Signal telemetry unavailable',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
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
