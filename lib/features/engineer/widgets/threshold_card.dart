import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ThresholdCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String warningLabel;
  final double warningValue;
  final double warningMin;
  final double warningMax;
  final String warningUnit;
  final ValueChanged<double> onWarningChanged;
  final String dangerLabel;
  final double dangerValue;
  final double dangerMin;
  final double dangerMax;
  final String dangerUnit;
  final ValueChanged<double> onDangerChanged;

  const ThresholdCard({
    super.key,
    required this.icon,
    required this.title,
    required this.warningLabel,
    required this.warningValue,
    required this.warningMin,
    required this.warningMax,
    required this.warningUnit,
    required this.onWarningChanged,
    required this.dangerLabel,
    required this.dangerValue,
    required this.dangerMin,
    required this.dangerMax,
    required this.dangerUnit,
    required this.onDangerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Warning threshold
            ThresholdInput(
              label: warningLabel,
              value: warningValue,
              min: warningMin,
              max: warningMax,
              unit: warningUnit,
              color: AppColors.warning,
              onChanged: onWarningChanged,
            ),

            const SizedBox(height: 20),

            // Danger threshold
            ThresholdInput(
              label: dangerLabel,
              value: dangerValue,
              min: dangerMin,
              max: dangerMax,
              unit: dangerUnit,
              color: AppColors.danger,
              onChanged: onDangerChanged,
            ),
          ],
        ),
      ),
    );
  }
}

/// Threshold input field with slider
class ThresholdInput extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final Color color;
  final ValueChanged<double> onChanged;

  const ThresholdInput({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackgroundLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                unit,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: AppColors.cardBackgroundLight,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
