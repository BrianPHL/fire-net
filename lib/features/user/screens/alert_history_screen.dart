import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/alert.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/layouts/app_scaffold.dart';
import '../../auth/auth_service.dart';
import '../widgets/alert_card.dart';

/// Alert history screen showing all past alerts with filters
class AlertHistoryScreen extends StatefulWidget {
  const AlertHistoryScreen({super.key});

  @override
  State<AlertHistoryScreen> createState() => _AlertHistoryScreenState();
}

class _AlertHistoryScreenState extends State<AlertHistoryScreen> {
  int _currentIndex = 2;
  String _selectedSeverity = 'All';
  String _selectedTimeRange = 'All Time';
  final _authService = AuthService();

  // Mock data
  final List<Alert> _allAlerts = Alert.getMockAlerts();

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
        // Already on history
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

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      ErrorDialogHelper.showSnackbarError(
        context,
        AuthService.getLogoutErrorMessage(error),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ErrorDialogHelper.showSnackbarError(
        context,
        'Unable to logout. Please try again.',
      );
    }
  }

  List<Alert> get _filteredAlerts {
    return _allAlerts.where((alert) {
      // Severity filter
      if (_selectedSeverity != 'All') {
        if (_selectedSeverity == 'Danger' && alert.severity != 'danger') {
          return false;
        }
        if (_selectedSeverity == 'Warning' && alert.severity != 'warning') {
          return false;
        }
      }

      // Time range filter
      if (_selectedTimeRange != 'All Time') {
        final now = DateTime.now();
        final difference = now.difference(alert.triggeredAt);

        if (_selectedTimeRange == 'Today' && difference.inDays > 0) {
          return false;
        }
        if (_selectedTimeRange == 'Week' && difference.inDays > 7) {
          return false;
        }
        if (_selectedTimeRange == 'Month' && difference.inDays > 30) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Alert History',
      currentIndex: _currentIndex,
      onNavigationChanged: _onNavigationChanged,
      onLogout: _handleLogout,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [_buildHeader(context), _buildFilters(context), _buildAlertsList()],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              child: Icon(
                Icons.history,
                color: ThemeColors.getTextPrimary(context),
                size: 24,
              ),
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
                  '${_filteredAlerts.length} alerts found',
                  style: TextStyle(
                    color: ThemeColors.getTextSecondary(context),
                    fontSize: 14,
                  ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Card(
          color: ThemeColors.getCardBackgroundLight(context),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.filter_alt,
                      size: 20,
                      color: ThemeColors.getTextPrimary(context),
                    ),
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
                  style: TextStyle(
                    color: ThemeColors.getTextSecondary(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSeverityChips(context),
                const SizedBox(height: 16),
                Text(
                  'Time Range',
                  style: TextStyle(
                    color: ThemeColors.getTextSecondary(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTimeRangeChips(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityChips(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: ['All', 'Danger', 'Warning'].map((severity) {
        final isSelected = _selectedSeverity == severity;
        return ChoiceChip(
          label: Text(severity),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedSeverity = severity);
          },
          backgroundColor: ThemeColors.getCardBackgroundLight(context),
          selectedColor: severity == 'Danger'
              ? ThemeColors.getDangerBackground(context)
              : severity == 'Warning'
              ? ThemeColors.getWarningBackground(context)
              : ThemeColors.getPrimary(context).withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isSelected
                ? (severity == 'Danger'
                      ? ThemeColors.getDanger(context)
                      : severity == 'Warning'
                      ? ThemeColors.getWarning(context)
                      : ThemeColors.getPrimary(context))
                : ThemeColors.getTextSecondary(context),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }

  Widget _buildTimeRangeChips(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: ['Today', 'Week', 'Month', 'All Time'].map((timeRange) {
        final isSelected = _selectedTimeRange == timeRange;
        return ChoiceChip(
          label: Text(timeRange),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedTimeRange = timeRange);
          },
          backgroundColor: ThemeColors.getCardBackgroundLight(context),
          selectedColor: ThemeColors.getPrimary(context).withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isSelected ? ThemeColors.getPrimary(context) : ThemeColors.getTextSecondary(context),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }

  Widget _buildAlertsList() {
    if (_filteredAlerts.isEmpty) {
      return SliverFillRemaining(
        child: Builder(
          builder: (context) => Center(
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
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final alert = _filteredAlerts[index];
          return AlertCard(
            alert: alert,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.alertDetail,
                arguments: alert,
              );
            },
          );
        }, childCount: _filteredAlerts.length),
      ),
    );
  }
}
