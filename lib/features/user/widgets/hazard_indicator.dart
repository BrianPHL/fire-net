import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_provider.dart';

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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Card(
          color: ThemeColors.getCardBackground(context),
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
                      color: _getBackgroundColor(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIcon(),
                      color: _getColor(context),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      color: ThemeColors.getTextPrimary(context),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: ThemeColors.getTextSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  Color _getColor(BuildContext context) {
    switch (severity) {
      case 'danger':
        return ThemeColors.getDanger(context);
      case 'warning':
        return ThemeColors.getWarning(context);
      case 'activity':
        return ThemeColors.getPrimary(context);
      default:
        return ThemeColors.getTextSecondary(context);
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (severity) {
      case 'danger':
        return ThemeColors.getDangerBackground(context);
      case 'warning':
        return ThemeColors.getWarningBackground(context);
      case 'activity':
        return ThemeColors.getActivityIndicator(context);
      default:
        return ThemeColors.getCardBackground(context);
    }
  }
}

