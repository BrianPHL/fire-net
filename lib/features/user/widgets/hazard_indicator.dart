import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Hazard indicator widget showing severity status
class HazardIndicator extends StatelessWidget {
  final String severity;
  final int count;
  final String label;
  final VoidCallback? onTap;

  const HazardIndicator({
    super.key,
    required this.severity,
    required this.count,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackgroundLight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(),
                  color: _getColor(),
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                count.toString(),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (severity) {
      case 'danger':
        return Icons.local_fire_department;
      case 'warning':
        return Icons.warning_amber;
      case 'activity':
        return Icons.timeline;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColor() {
    switch (severity) {
      case 'danger':
        return AppColors.danger;
      case 'warning':
        return AppColors.warning;
      case 'activity':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getBackgroundColor() {
    switch (severity) {
      case 'danger':
        return AppColors.dangerBackground;
      case 'warning':
        return AppColors.warningBackground;
      case 'activity':
        return const Color(0xFF1F2D2D);
      default:
        return AppColors.cardBackground;
    }
  }
}
