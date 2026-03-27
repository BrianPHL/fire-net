import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SystemStatusCard extends StatelessWidget {
  const SystemStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing based on available width
        final isCompact = constraints.maxWidth < 400;
        final iconSize = isCompact ? 60.0 : 80.0;
        final iconInnerSize = isCompact ? 36.0 : 48.0;
        final padding = isCompact ? 20.0 : 32.0;
        final spacing = isCompact ? 12.0 : 20.0;

        return Card(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                // Check icon with circular background
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: iconInnerSize,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: spacing),
                Text(
                  'System Operational',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'All diagnostic checks passed',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
