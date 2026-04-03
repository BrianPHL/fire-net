import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/alert.dart';
import '../../../routes/app_routes.dart';
import '../../../services/alert_service.dart';
import '../../../shared/layouts/app_scaffold.dart';
import '../../auth/auth_service.dart';
import '../user_service.dart';
import '../widgets/alert_card.dart';

class AlertHistoryScreen extends StatefulWidget {
  const AlertHistoryScreen({super.key});

  @override
  State<AlertHistoryScreen> createState() => _AlertHistoryScreenState();
}

class _AlertHistoryScreenState extends State<AlertHistoryScreen> {
  int _currentIndex = 2;
  String _selectedSeverity = 'all';
  String _selectedTimeRange = 'all_time';

  final _authService = AuthService();
  final _alertService = AlertService();
  final _userService = UserService();

  @override
  void initState() {
    super.initState();
    _alertService.startAutoGeneration(
      sensorStream: _userService.streamSensorNodes(),
      createdBy: FirebaseAuth.instance.currentUser?.uid,
    );
  }

  @override
  void dispose() {
    _alertService.stopAutoGeneration();
    super.dispose();
  }

  void _onNavigationChanged(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.userHome);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.alerts);
        break;
      case 2:
        break;
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await ErrorDialogHelper.showConfirmationDialog(
      context,
      title: 'Confirm Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      isDangerous: true,
    );

    if (!confirmed) {
      return;
    }

    try {
      await _authService.signOut();

      if (!mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      ErrorDialogHelper.showSnackbarError(context, AuthService.getLogoutErrorMessage(error));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ErrorDialogHelper.showSnackbarError(context, 'Unable to logout. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Alert History',
      currentIndex: _currentIndex,
      onNavigationChanged: _onNavigationChanged,
      onLogout: _handleLogout,
      body: SafeArea(
        child: StreamBuilder<List<Alert>>(
          stream: _alertService.watchAlerts(status: Alert.statusResolved),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load alert history.',
                  style: TextStyle(color: ThemeColors.getTextPrimary(context)),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final alerts = snapshot.data ?? <Alert>[];
            final filteredAlerts = _applyFilters(alerts);

            return CustomScrollView(
              slivers: [
                _buildHeader(filteredAlerts.length),
                _buildFilters(context),
                _buildAlertsList(filteredAlerts),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Alert> _applyFilters(List<Alert> alerts) {
    final now = DateTime.now();

    return alerts.where((alert) {
      if (_selectedSeverity != 'all' && alert.severity != _selectedSeverity) {
        return false;
      }

      if (_selectedTimeRange == 'today' && now.difference(alert.triggeredAt).inDays > 0) {
        return false;
      }
      if (_selectedTimeRange == 'week' && now.difference(alert.triggeredAt).inDays > 7) {
        return false;
      }
      if (_selectedTimeRange == 'month' && now.difference(alert.triggeredAt).inDays > 30) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildHeader(int alertCount) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ThemeColors.getCardBackgroundLight(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.history, color: ThemeColors.getTextPrimary(context), size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alert History',
                  style: TextStyle(
                    color: ThemeColors.getTextPrimary(context),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$alertCount alerts found',
                  style: TextStyle(color: ThemeColors.getTextSecondary(context), fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          color: ThemeColors.getCardBackgroundLight(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.filter_alt, size: 20, color: ThemeColors.getTextPrimary(context)),
                    const SizedBox(width: 8),
                    Text(
                      'Filters',
                      style: TextStyle(
                        color: ThemeColors.getTextPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Severity',
                  style: TextStyle(color: ThemeColors.getTextSecondary(context), fontSize: 14),
                ),
                const SizedBox(height: 8),
                _buildSeverityChips(),
                const SizedBox(height: 16),
                Text(
                  'Time Range',
                  style: TextStyle(color: ThemeColors.getTextSecondary(context), fontSize: 14),
                ),
                const SizedBox(height: 8),
                _buildTimeRangeChips(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityChips() {
    const options = <String, String>{
      'all': 'All',
      Alert.severitySafe: 'Safe',
      Alert.severityWarning: 'Warning',
      Alert.severityDanger: 'Danger',
    };

    return Wrap(
      spacing: 8,
      children: options.entries.map((entry) {
        return ChoiceChip(
          label: Text(entry.value),
          selected: _selectedSeverity == entry.key,
          onSelected: (_) {
            setState(() => _selectedSeverity = entry.key);
          },
          side: BorderSide.none,
        );
      }).toList(),
    );
  }

  Widget _buildTimeRangeChips() {
    const options = <String, String>{
      'today': 'Today',
      'week': 'Week',
      'month': 'Month',
      'all_time': 'All Time',
    };

    return Wrap(
      spacing: 8,
      children: options.entries.map((entry) {
        return ChoiceChip(
          label: Text(entry.value),
          selected: _selectedTimeRange == entry.key,
          onSelected: (_) {
            setState(() => _selectedTimeRange = entry.key);
          },
          side: BorderSide.none,
        );
      }).toList(),
    );
  }

  Widget _buildAlertsList(List<Alert> alerts) {
    if (alerts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: ThemeColors.getTextTertiary(context)),
              const SizedBox(height: 16),
              Text(
                'No Alerts Found',
                style: TextStyle(
                  color: ThemeColors.getTextPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters',
                style: TextStyle(color: ThemeColors.getTextSecondary(context), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final alert = alerts[index];
          return AlertCard(
            alert: alert,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.alertDetail, arguments: alert);
            },
          );
        }, childCount: alerts.length),
      ),
    );
  }
}
