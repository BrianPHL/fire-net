import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../models/sensor_node.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/status_pill.dart';

class NodeStatusSection extends StatelessWidget {
  final List<SensorNode> nodes;

  const NodeStatusSection({super.key, required this.nodes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Node Status',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...nodes.map((node) => NodeStatusCard(node: node)),
      ],
    );
  }
}

/// Node status card
class NodeStatusCard extends StatelessWidget {
  final SensorNode node;

  const NodeStatusCard({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(node.status, context);
    final statusLabel = _getStatusLabel(node.status);

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.sensorManagement);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
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
                      '${node.location} • ID: ${node.id}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last check: ${_formatTime(node.lastUpdated)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusPill(
                    label: statusLabel,
                    color: statusColor,
                    backgroundColor: statusColor == ThemeColors.getSafe(context)
                        ? ThemeColors.getSafeBackground(context)
                        : statusColor == AppColors.warning
                            ? ThemeColors.getWarningBackground(context)
                            : ThemeColors.getDangerBackground(context),
                    icon: statusColor == ThemeColors.getSafe(context)
                        ? Icons.check_circle
                        : statusColor == AppColors.warning
                            ? Icons.warning_amber
                            : Icons.error,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status, BuildContext context) {
    switch (status) {
      case 'safe':
        return ThemeColors.getSafe(context);
      case 'warning':
        return ThemeColors.getWarning(context);
      case 'danger':
        return ThemeColors.getDanger(context);
      default:
        return ThemeColors.getTextSecondary(context);
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'safe':
        return 'Safe';
      case 'warning':
        return 'Warning';
      case 'danger':
        return 'Danger';
      default:
        return 'Unknown';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
    }
  }
}
