import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/alert.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/status_pill.dart';

/// Alert detail screen showing comprehensive alert information
class AlertDetailScreen extends StatelessWidget {
  final Alert alert;

  const AlertDetailScreen({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Alert Details'),
        actions: [
          Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: StatusPill(
                label: alert.isActive ? 'Active' : 'Resolved',
                color: alert.isActive ? ThemeColors.getDanger(context) : ThemeColors.getSafe(context),
                backgroundColor: alert.isActive 
                    ? ThemeColors.getDangerBackground(context) 
                    : ThemeColors.getSafeBackground(context),
                icon: alert.isActive ? Icons.warning_amber : Icons.check_circle,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAlertBanner(context),
            const SizedBox(height: 24),
            _buildInfoCard(context),
            const SizedBox(height: 16),
            _buildExplanationCard(context),
            const SizedBox(height: 16),
            _buildSensorNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: _getSeverityBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getSeverityColor(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getSeverityColor(context).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getAlertIcon(),
                  color: _getSeverityColor(context),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(context).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        alert.severity == 'danger' ? 'Danger Alert' : 'Warning Alert',
                        style: TextStyle(
                          color: _getSeverityColor(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            alert.title,
            style: TextStyle(
              color: _getSeverityColor(context),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            alert.description,
            style: TextStyle(
              color: ThemeColors.getTextPrimary(context),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              context,
              Icons.location_on,
              'Affected Node',
              alert.nodeName,
              alert.location,
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              'Triggered',
              Helpers.formatDateTime(alert.triggeredAt),
              null,
            ),
            if (alert.isResolved) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                Icons.check_circle,
                'Resolved',
                Helpers.formatDateTime(alert.resolvedAt!),
                null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    String? subtitle,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ThemeColors.getCardBackgroundLight(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: ThemeColors.getTextSecondary(context), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: ThemeColors.getTextPrimary(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: ThemeColors.getTextPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExplanationCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: ThemeColors.getTextPrimary(context),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Alert Explanation',
                  style: TextStyle(
                    color: ThemeColors.getTextPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alert.explanation ?? alert.description,
              style: TextStyle(
                color: ThemeColors.getTextSecondary(context),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorNavigation(BuildContext context) {
    return Card(
      color: ThemeColors.getCardBackgroundLight(context),
      child: InkWell(
        onTap: () {
          // Navigate to sensor detail - in real app, pass sensor data
          Navigator.pushNamed(context, AppRoutes.sensorDetail);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ThemeColors.getPrimary(context).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.sensors,
                  color: ThemeColors.getPrimary(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'View Sensor Details',
                      style: TextStyle(
                        color: ThemeColors.getTextPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'See real-time readings and trends',
                      style: TextStyle(
                        color: ThemeColors.getTextSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: ThemeColors.getPrimary(context),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(BuildContext context) {
    return alert.severity == 'danger' ? ThemeColors.getDanger(context) : ThemeColors.getWarning(context);
  }

  Color _getSeverityBackgroundColor(BuildContext context) {
    return alert.severity == 'danger' 
        ? ThemeColors.getDangerBackground(context)
        : ThemeColors.getWarningBackground(context);
  }

  IconData _getAlertIcon() {
    return alert.severity == 'danger'
        ? Icons.local_fire_department
        : Icons.warning_amber;
  }
}
