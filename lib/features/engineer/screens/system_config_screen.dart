import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/helpers.dart';
import '../../../models/threshold_config.dart';
import '../../../services/threshold_config_service.dart';
import '../../../shared/layouts/engineer_scaffold.dart';
import '../widgets/threshold_card.dart';

class SystemConfigScreen extends StatefulWidget {
  const SystemConfigScreen({super.key});

  @override
  State<SystemConfigScreen> createState() => _SystemConfigScreenState();
}

class _SystemConfigScreenState extends State<SystemConfigScreen> {
  static const double _minValue = 0;
  static const double _temperatureMax = 100;
  static const double _smokeAndGasMax = 2500;

  final ThresholdConfigService _thresholdConfigService =
      ThresholdConfigService();

  ThresholdConfig _draftConfig = ThresholdConfig.defaults();
  bool _hasLoadedDraft = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isDirty = false;
  String? _actionMessage;
  bool _actionMessageIsError = false;

  @override
  Widget build(BuildContext context) {
    return EngineerScaffold(
      title: 'Threshold Config',
      currentIndex: 2,
      body: StreamBuilder<ThresholdConfig?>(
        stream: _thresholdConfigService.watchThresholdConfig(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(context, snapshot.error);
          }

          final remoteConfig = snapshot.data;
          final activeConfig = _resolveActiveConfig(remoteConfig);
          final validationMessage = activeConfig.validate();
          final hasStoredConfig = remoteConfig != null;

          return SingleChildScrollView(
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
                  'Each danger threshold must be higher than its warning threshold.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                _buildSyncStatus(
                  context,
                  snapshot.connectionState,
                  hasStoredConfig,
                ),
                if (_actionMessage != null) ...[
                  const SizedBox(height: 12),
                  _buildActionBanner(
                    context,
                    _actionMessage!,
                    isError: _actionMessageIsError,
                  ),
                ],
                if (validationMessage != null) ...[
                  const SizedBox(height: 12),
                  _buildValidationBanner(context, validationMessage),
                ],
                const SizedBox(height: 24),
                ThresholdCard(
                  icon: Icons.thermostat,
                  title: 'Temperature (C)',
                  warningLabel: 'Warning Threshold',
                  warningValue: activeConfig.temperatureWarning,
                  warningMin: _minValue,
                  warningMax: _temperatureMax,
                  warningUnit: 'C',
                  onWarningChanged: (value) =>
                      _updateDraft(temperatureWarning: value),
                  dangerLabel: 'Danger Threshold',
                  dangerValue: activeConfig.temperatureDanger,
                  dangerMin: _minValue,
                  dangerMax: _temperatureMax,
                  dangerUnit: 'C',
                  onDangerChanged: (value) =>
                      _updateDraft(temperatureDanger: value),
                ),
                const SizedBox(height: 16),
                ThresholdCard(
                  icon: Icons.smoke_free,
                  title: 'Smoke (ppm)',
                  warningLabel: 'Warning Threshold',
                  warningValue: activeConfig.smokeWarning,
                  warningMin: _minValue,
                  warningMax: _smokeAndGasMax,
                  warningUnit: 'ppm',
                  onWarningChanged: (value) => _updateDraft(smokeWarning: value),
                  dangerLabel: 'Danger Threshold',
                  dangerValue: activeConfig.smokeDanger,
                  dangerMin: _minValue,
                  dangerMax: _smokeAndGasMax,
                  dangerUnit: 'ppm',
                  onDangerChanged: (value) => _updateDraft(smokeDanger: value),
                ),
                const SizedBox(height: 16),
                ThresholdCard(
                  icon: Icons.science,
                  title: 'Gas (ppm)',
                  warningLabel: 'Warning Threshold',
                  warningValue: activeConfig.gasWarning,
                  warningMin: _minValue,
                  warningMax: _smokeAndGasMax,
                  warningUnit: 'ppm',
                  onWarningChanged: (value) => _updateDraft(gasWarning: value),
                  dangerLabel: 'Danger Threshold',
                  dangerValue: activeConfig.gasDanger,
                  dangerMin: _minValue,
                  dangerMax: _smokeAndGasMax,
                  dangerUnit: 'ppm',
                  onDangerChanged: (value) => _updateDraft(gasDanger: value),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _isSaving ||
                                _isDeleting ||
                                validationMessage != null
                            ? null
                            : () => _handleSave(hasStoredConfig),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                hasStoredConfig ? 'Update Changes' : 'Create Config',
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _isSaving || _isDeleting ? null : _handleResetToDefaults,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Reset Defaults'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed:
                        _isSaving || _isDeleting || !hasStoredConfig ? null : _handleDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: _isDeleting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Delete Config'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  ThresholdConfig _resolveActiveConfig(ThresholdConfig? remoteConfig) {
    if (remoteConfig != null && !_isDirty) {
      if (!_hasLoadedDraft || _draftConfig != remoteConfig) {
        _hasLoadedDraft = true;
        _draftConfig = remoteConfig;
      }
      return remoteConfig;
    }

    if (!_hasLoadedDraft) {
      _hasLoadedDraft = true;
      _draftConfig = remoteConfig ?? ThresholdConfig.defaults();
    }

    return _draftConfig;
  }

  void _updateDraft({
    double? temperatureWarning,
    double? temperatureDanger,
    double? smokeWarning,
    double? smokeDanger,
    double? gasWarning,
    double? gasDanger,
  }) {
    setState(() {
      _draftConfig = _draftConfig.copyWith(
        temperatureWarning: temperatureWarning,
        temperatureDanger: temperatureDanger,
        smokeWarning: smokeWarning,
        smokeDanger: smokeDanger,
        gasWarning: gasWarning,
        gasDanger: gasDanger,
      );
      _isDirty = true;
    });
  }

  Future<void> _handleSave(bool hasStoredConfig) async {
    final validationMessage = _draftConfig.validate();
    if (validationMessage != null) {
      setState(() {
        _actionMessage = validationMessage;
        _actionMessageIsError = true;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _actionMessage = null;
      _actionMessageIsError = false;
    });

    try {
      if (hasStoredConfig) {
        await _thresholdConfigService.updateThresholdConfig(_draftConfig);
      } else {
        await _thresholdConfigService.createThresholdConfig(_draftConfig);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isDirty = false;
        _actionMessage = hasStoredConfig
            ? 'Thresholds updated successfully.'
            : 'Thresholds created successfully.';
        _actionMessageIsError = false;
      });
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      ErrorDialogHelper.showSnackbarError(
        context,
        _thresholdErrorMessage(error),
      );
      setState(() {
        _actionMessage = _thresholdErrorMessage(error);
        _actionMessageIsError = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _actionMessage = 'Unable to save threshold config.';
        _actionMessageIsError = true;
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleResetToDefaults() async {
    final confirmed = await ErrorDialogHelper.showConfirmationDialog(
      context,
      title: 'Reset thresholds?',
      message: 'This will restore the default threshold values.',
      confirmText: 'Reset',
      cancelText: 'Cancel',
    );

    if (!confirmed) {
      return;
    }

    setState(() {
      _isSaving = true;
      _actionMessage = null;
      _actionMessageIsError = false;
    });

    try {
      await _thresholdConfigService.resetToDefaults();

      if (!mounted) {
        return;
      }

      setState(() {
        _draftConfig = ThresholdConfig.defaults();
        _isDirty = false;
        _actionMessage = 'Thresholds reset to defaults.';
        _actionMessageIsError = false;
      });
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _actionMessage = _thresholdErrorMessage(error);
        _actionMessageIsError = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _actionMessage = 'Unable to reset thresholds.';
        _actionMessageIsError = true;
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await ErrorDialogHelper.showConfirmationDialog(
      context,
      title: 'Delete threshold config?',
      message: 'This will remove the Firestore threshold document.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDangerous: true,
    );

    if (!confirmed) {
      return;
    }

    setState(() {
      _isDeleting = true;
      _actionMessage = null;
      _actionMessageIsError = false;
    });

    try {
      await _thresholdConfigService.deleteThresholdConfig();

      if (!mounted) {
        return;
      }

      setState(() {
        _draftConfig = ThresholdConfig.defaults();
        _isDirty = false;
        _actionMessage = 'Threshold config deleted.';
        _actionMessageIsError = false;
      });
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _actionMessage = _thresholdErrorMessage(error);
        _actionMessageIsError = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _actionMessage = 'Unable to delete threshold config.';
        _actionMessageIsError = true;
      });
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Widget _buildSyncStatus(
    BuildContext context,
    ConnectionState connectionState,
    bool hasStoredConfig,
  ) {
    final label = switch (connectionState) {
      ConnectionState.waiting => 'Loading thresholds...',
      ConnectionState.active =>
        hasStoredConfig
            ? 'Live sync enabled'
            : 'No saved config yet - using defaults',
      ConnectionState.none => 'Disconnected',
      ConnectionState.done => 'Stream closed',
    };

    final color = hasStoredConfig
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      ),
    );
  }

  Widget _buildValidationBanner(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
    );
  }

  Widget _buildActionBanner(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isError
                  ? Theme.of(context).colorScheme.onErrorContainer
                  : Theme.of(context).colorScheme.onPrimaryContainer,
            ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load threshold config.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Unknown error',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _thresholdErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Firestore denied the write. Your account is not being recognized as engineer/admin, or the rules were not published to this project.';
      case 'not-found':
        return 'Threshold config document was not found.';
      case 'failed-precondition':
        return 'Firestore is not ready or the index/rules are not deployed correctly.';
      default:
        return error.message ?? 'Unable to save threshold config.';
    }
  }
}
