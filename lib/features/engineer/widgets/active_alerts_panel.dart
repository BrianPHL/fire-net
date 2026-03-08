import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/alert.dart';

class ActiveAlertsPanel extends StatelessWidget {
  final List<Alert> alerts;

  const ActiveAlertsPanel({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    final criticalCount = alerts.where((a) => a.severity == 'danger').length;
    final warningCount = alerts.where((a) => a.severity == 'warning').length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: AppColors.warning,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Active System Alerts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AlertCountCard(
                    count: criticalCount,
                    label: 'Critical',
                    color: AppColors.danger,
                    backgroundColor: AppColors.dangerBackground,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AlertCountCard(
                    count: warningCount,
                    label: 'Warnings',
                    color: AppColors.warning,
                    backgroundColor: AppColors.warningBackground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Alert count card
class AlertCountCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final Color backgroundColor;

  const AlertCountCard({
    super.key,
    required this.count,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
