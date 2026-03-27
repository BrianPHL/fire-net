import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Reusable FireNet logo widget with consistent branding
/// 
/// This widget represents the unified FireNet brand across the application.
/// Displays a circular red fire icon above the "FireNet" text.
class FireNetLogo extends StatelessWidget {
  /// Size of the circular icon container
  final double iconSize;

  /// Size of the fire icon inside the container
  final double fireIconSize;

  /// Size of the "FireNet" text
  final double textSize;

  /// Spacing between icon and text
  final double spacing;

  /// Whether to include the text below the icon
  final bool showText;

  const FireNetLogo({
    super.key,
    this.iconSize = 100,
    this.fireIconSize = 56,
    this.textSize = 32,
    this.spacing = 20,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular fire icon container (red theme)
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.danger.withValues(alpha: 0.15),
          ),
          child: Icon(
            Icons.local_fire_department,
            size: fireIconSize,
            color: AppColors.danger,
          ),
        ),
        if (showText) ...[
          SizedBox(height: spacing),
          // FireNet text in red
          Text(
            'FireNet',
            style: TextStyle(
              color: AppColors.danger,
              fontSize: textSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ],
    );
  }
}
