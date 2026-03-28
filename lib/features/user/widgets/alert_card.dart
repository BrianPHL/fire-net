import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/alert.dart';

/// Alert card widget for displaying alert information
class AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback? onTap;
  final bool showLocation;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.showLocation = true,
  });

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
              return Row(
                children: [
                  _buildIcon(context),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        if (showLocation)
                          Text(
                            alert.location,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          alert.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (alert.isResolved) ...[
                          const SizedBox(height: 8),
                          _buildResolvedBadge(context),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Helpers.getRelativeTime(alert.triggeredAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ],
              ),
              ],
            );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getIconBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getIcon(),
        color: _getIconColor(),
        size: 24,
      ),
    );
  }

  Widget _buildResolvedBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ThemeColors.getSafeBackground(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Resolved • ${Helpers.formatDate(alert.resolvedAt!)}',
        style: const TextStyle(
          color: AppColors.safe,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _getIcon() {
    if (alert.severity == 'danger') {
      return Icons.local_fire_department;
    } else {
      return Icons.warning_amber;
    }
  }

  Color _getIconColor() {
    switch (alert.severity) {
      case 'danger':
        return AppColors.danger;
      case 'warning':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  Color _getIconBackgroundColor(BuildContext context) {
    switch (alert.severity) {
      case 'danger':
        return ThemeColors.getDangerBackground(context);
      case 'warning':
        return ThemeColors.getWarningBackground(context);
      default:
        return ThemeColors.getCardBackgroundLight(context);
    }
  }
}
