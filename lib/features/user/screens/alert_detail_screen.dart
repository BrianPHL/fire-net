import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/alert.dart';
import '../../../models/sensor_node.dart';
import '../../../routes/app_routes.dart';
import '../../../services/alert_service.dart';
import '../user_service.dart';
import '../../../shared/widgets/status_pill.dart';

class AlertDetailScreen extends StatefulWidget {
  const AlertDetailScreen({super.key, required this.alert});

  final Alert alert;

  @override
  State<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends State<AlertDetailScreen> {
  final _alertService = AlertService();
  final _userService = UserService();
  bool _isResolving = false;
  bool _isLoadingSensor = false;

  Alert get _alert => widget.alert;

  Future<void> _resolveAlert() async {
    if (!_alert.isActive || _isResolving) {
      return;
    }

    final confirmed = await ErrorDialogHelper.showConfirmationDialog(
      context,
      title: 'Resolve Alert',
      message: 'Mark this alert as resolved?',
      confirmText: 'Resolve',
      cancelText: 'Cancel',
    );

    if (!confirmed) {
      return;
    }

    setState(() => _isResolving = true);

    try {
      await _alertService.resolveAlert(
        alertId: _alert.id,
        resolvedBy: FirebaseAuth.instance.currentUser?.uid,
      );

      if (!mounted) {
        return;
      }

      ErrorDialogHelper.showSnackbarSuccess(
        context,
        'Alert resolved successfully.',
      );
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ErrorDialogHelper.showSnackbarError(
        context,
        'Failed to resolve alert. Please try again.',
      );
      setState(() => _isResolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Alert Details'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StatusPill(
              label: _alert.isActive ? 'Active' : 'Resolved',
              color: _alert.isActive
                  ? ThemeColors.getDanger(context)
                  : ThemeColors.getSafe(context),
              backgroundColor: _alert.isActive
                  ? ThemeColors.getDangerBackground(context)
                  : ThemeColors.getSafeBackground(context),
              icon: _alert.isActive ? Icons.warning_amber : Icons.check_circle,
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
            if (_alert.isActive) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isResolving ? null : _resolveAlert,
                  icon: _isResolving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.task_alt),
                  label: Text(_isResolving ? 'Resolving...' : 'Resolve Alert'),
                ),
              ),
            ],
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
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(context).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _alert.severity == Alert.severityDanger
                        ? 'Danger Alert'
                        : _alert.severity == Alert.severitySafe
                        ? 'Safe Alert'
                        : 'Warning Alert',
                    style: TextStyle(
                      color: _getSeverityColor(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _alert.title,
            style: TextStyle(
              color: _getSeverityColor(context),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _friendlyDescription(_alert.description),
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
              _alert.nodeName,
              _alert.location,
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              'Triggered',
              Helpers.formatDateTime(_alert.triggeredAt),
              null,
            ),
            if (_alert.isResolved && _alert.resolvedAt != null) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                Icons.check_circle,
                'Resolved',
                Helpers.formatDateTime(_alert.resolvedAt!),
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
          child: Icon(
            icon,
            color: ThemeColors.getTextSecondary(context),
            size: 20,
          ),
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
              _friendlyExplanation(_alert.explanation ?? _alert.description),
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
        onTap: _openSensorDetails,
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

  Future<void> _openSensorDetails() async {
    if (_isLoadingSensor) {
      return;
    }

    if (_alert.nodeId.isEmpty) {
      ErrorDialogHelper.showSnackbarError(
        context,
        'Sensor details are unavailable for this alert.',
      );
      return;
    }

    setState(() => _isLoadingSensor = true);
    ErrorDialogHelper.showLoadingDialog(
      context,
      message: 'Loading sensor details...',
    );

    SensorNode? matchedSensor;
    String? errorMessage;

    try {
      final sensors = await _userService.streamSensorNodes().first;
      if (!mounted) {
        return;
      }

      for (final sensor in sensors) {
        if (sensor.id == _alert.nodeId) {
          matchedSensor = sensor;
          break;
        }
      }

      if (matchedSensor == null) {
        errorMessage = 'Sensor not found for this alert.';
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      errorMessage = 'Unable to load sensor details. Please try again.';
    } finally {
      if (mounted) {
        ErrorDialogHelper.closeLoadingDialog(context);
        setState(() => _isLoadingSensor = false);
      }
    }

    if (!mounted) {
      return;
    }

    if (matchedSensor != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.sensorDetail,
        arguments: matchedSensor,
      );
      return;
    }

    ErrorDialogHelper.showSnackbarError(
      context,
      errorMessage ?? 'Sensor details are unavailable for this alert.',
    );
  }

  Color _getSeverityColor(BuildContext context) {
    if (_alert.severity == Alert.severityDanger) {
      return ThemeColors.getDanger(context);
    }
    if (_alert.severity == Alert.severitySafe) {
      return ThemeColors.getSafe(context);
    }
    return ThemeColors.getWarning(context);
  }

  Color _getSeverityBackgroundColor(BuildContext context) {
    if (_alert.severity == Alert.severityDanger) {
      return ThemeColors.getDangerBackground(context);
    }
    if (_alert.severity == Alert.severitySafe) {
      return ThemeColors.getSafeBackground(context);
    }
    return ThemeColors.getWarningBackground(context);
  }

  IconData _getAlertIcon() {
    if (_alert.severity == Alert.severityDanger) {
      return Icons.local_fire_department;
    }
    if (_alert.severity == Alert.severitySafe) {
      return Icons.check_circle;
    }
    return Icons.warning_amber;
  }

  String _friendlyDescription(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _looksTechnical(trimmed)) {
      if (_alert.severity == Alert.severityDanger) {
        return 'A critical safety condition was detected. Please inspect the area immediately.';
      }
      if (_alert.severity == Alert.severityWarning) {
        return 'Unusual sensor activity was detected. Please check the area and stay alert.';
      }
      return 'Sensor conditions have returned to normal levels.';
    }
    return trimmed;
  }

  String _friendlyExplanation(String text) {
    final trimmed = text.trim();
    if (trimmed.isNotEmpty && !_looksTechnical(trimmed)) {
      return trimmed;
    }

    final severityLabel = _alert.severity == Alert.severityDanger
        ? 'critical'
        : _alert.severity == Alert.severityWarning
        ? 'warning'
        : 'safe';

    final action = _alert.severity == Alert.severityDanger
        ? 'Move people to safety, improve ventilation, and check for smoke or heat sources right away.'
        : _alert.severity == Alert.severityWarning
        ? 'Inspect the area, improve ventilation if needed, and continue monitoring sensor updates.'
        : 'No immediate action is required. Keep monitoring the sensor feed.';

    return '${_alert.nodeName} at ${_alert.location} reported a $severityLabel condition. $action';
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
