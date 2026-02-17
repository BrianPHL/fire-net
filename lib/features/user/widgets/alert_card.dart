import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (showLocation)
                      Text(
                        alert.location,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      alert.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (alert.isResolved) ...[
                      const SizedBox(height: 8),
                      _buildResolvedBadge(),
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
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getIconBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getIcon(),
        color: _getIconColor(),
        size: 24,
      ),
    );
  }

  Widget _buildResolvedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.safeBackground,
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
        return AppColors.textSecondary;
    }
  }

  Color _getIconBackgroundColor() {
    switch (alert.severity) {
      case 'danger':
        return AppColors.dangerBackground;
      case 'warning':
        return AppColors.warningBackground;
      default:
        return AppColors.cardBackgroundLight;
    }
  }
}
