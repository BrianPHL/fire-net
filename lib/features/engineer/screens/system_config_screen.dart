import 'package:flutter/material.dart';
import '../../../shared/layouts/engineer_scaffold.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/threshold_card.dart';

class SystemConfigScreen extends StatefulWidget {
  const SystemConfigScreen({super.key});

  @override
  State<SystemConfigScreen> createState() => _SystemConfigScreenState();
}

class _SystemConfigScreenState extends State<SystemConfigScreen> {

  // Mock data palang lahat

  // Temperature thresholds in celsius
  double tempWarning = 40;
  double tempDanger = 50;

  // Smoke thresholds in parts per million
  double smokeWarning = 50;
  double smokeDanger = 100;

  // Gas thresholds in parts per million
  double gasWarning = 100;
  double gasDanger = 200;

  @override
  Widget build(BuildContext context) {
    return EngineerScaffold(
      title: 'Threshold Config',
      currentIndex: 2,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set alert triggers',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'These values determine when alerts are triggered.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Set warning and danger thresholds for each sensor type.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),

            // Temperature 
            ThresholdCard(
              icon: Icons.thermostat,
              title: 'Temperature (C)',
              warningLabel: 'Warning Threshold',
              warningValue: tempWarning,
              warningMin: 0,
              warningMax: 100,
              warningUnit: 'C',
              onWarningChanged: (value) {
                setState(() {
                  tempWarning = value;
                });
              },
              dangerLabel: 'Danger Threshold',
              dangerValue: tempDanger,
              dangerMin: 0,
              dangerMax: 100,
              dangerUnit: 'C',
              onDangerChanged: (value) {
                setState(() {
                  tempDanger = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Smoke 
            ThresholdCard(
              icon: Icons.smoke_free,
              title: 'Smoke (ppm)',
              warningLabel: 'Warning Threshold',
              warningValue: smokeWarning,
              warningMin: 0,
              warningMax: 500,
              warningUnit: 'ppm',
              onWarningChanged: (value) {
                setState(() {
                  smokeWarning = value;
                });
              },
              dangerLabel: 'Danger Threshold',
              dangerValue: smokeDanger,
              dangerMin: 0,
              dangerMax: 500,
              dangerUnit: 'ppm',
              onDangerChanged: (value) {
                setState(() {
                  smokeDanger = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Gas 
            ThresholdCard(
              icon: Icons.science,
              title: 'Gas (ppm)',
              warningLabel: 'Warning Threshold',
              warningValue: gasWarning,
              warningMin: 0,
              warningMax: 500,
              warningUnit: 'ppm',
              onWarningChanged: (value) {
                setState(() {
                  gasWarning = value;
                });
              },
              dangerLabel: 'Danger Threshold',
              dangerValue: gasDanger,
              dangerMin: 0,
              dangerMax: 500,
              dangerUnit: 'ppm',
              onDangerChanged: (value) {
                setState(() {
                  gasDanger = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // Save button 
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // UI only - no save logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings saved (UI only)'),
                      backgroundColor: AppColors.safe,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}