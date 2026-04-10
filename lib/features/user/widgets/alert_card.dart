import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/alert.dart';
import '../../../shared/widgets/status_pill.dart';

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
                          _previewDescription(),
                          style: TextStyle(
                            color: ThemeColors.getTextSecondary(context),
                          ),
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
                        color: ThemeColors.getTextSecondary(context),
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
      child: Icon(_getIcon(), color: _getIconColor(context), size: 24),
    );
  }

  Widget _buildResolvedBadge(BuildContext context) {
    return StatusPill(
      label: 'Resolved • ${Helpers.formatDate(alert.resolvedAt!)}',
      color: ThemeColors.getSafe(context),
      backgroundColor: ThemeColors.getSafeBackground(context),
      icon: Icons.check_circle,
    );
  }

  IconData _getIcon() {
    if (alert.severity == 'danger') {
      return Icons.local_fire_department;
    } else {
      return Icons.warning_amber;
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (alert.severity) {
      case 'danger':
        return ThemeColors.getDanger(context);
      case 'warning':
        return ThemeColors.getWarning(context);
      default:
        return ThemeColors.getPrimary(context);
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

  String _previewDescription() {
    final text = alert.description.trim();
    if (text.isEmpty || _looksTechnical(text)) {
      if (alert.severity == Alert.severityDanger) {
        return 'Critical condition detected. Tap to view safety guidance.';
      }
      if (alert.severity == Alert.severityWarning) {
        return 'Warning condition detected. Tap to view what to do next.';
      }
      return 'Conditions have returned to safe levels.';
    }
    return text;
  }

  bool _looksTechnical(String text) {
    final value = text.toLowerCase();
    return value.contains('[code:') ||
        value.contains('alert code:') ||
        value.contains('risk score:') ||
        value.contains('confidence:') ||
        value.contains('triggered rules:') ||
        value.contains('exceeded metrics:');
  }
}
