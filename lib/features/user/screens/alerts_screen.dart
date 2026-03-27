import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/alert.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/layouts/app_scaffold.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../auth/auth_service.dart';
import '../widgets/alert_card.dart';

/// Active alerts screen showing current unresolved alerts
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _currentIndex = 1;
  final _authService = AuthService();

  // Mock data
  final List<Alert> _alerts = Alert.getMockAlerts()
      .where((alert) => alert.isActive)
      .toList();

  void _onNavigationChanged(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.userHome);
        break;
      case 1:
        // Already on alerts
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.alertHistory);
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: _currentIndex,
      onNavigationChanged: _onNavigationChanged,
      onLogout: _handleLogout,
      body: SafeArea(
        child: CustomScrollView(slivers: [_buildHeader(), _buildAlertsList()]),
      ),
    );
  }

  Widget _buildHeader() {
    final dangerCount = _alerts.where((a) => a.severity == 'danger').length;
    final warningCount = _alerts.where((a) => a.severity == 'warning').length;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSectionHeader(
                  title: 'Active Alerts',
                  subtitle: 'Monitor unresolved warning and danger events',
                  trailing: StatusPill(
                    label: 'Live Feed',
                    color: AppColors.warning,
                    backgroundColor: AppColors.warningBackground,
                    icon: Icons.notifications_active,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    StatusPill(
                      label: '$dangerCount danger',
                      color: AppColors.danger,
                      backgroundColor: AppColors.dangerBackground,
                      icon: Icons.local_fire_department,
                    ),
                    StatusPill(
                      label: '$warningCount warning',
                      color: AppColors.warning,
                      backgroundColor: AppColors.warningBackground,
                      icon: Icons.warning_amber,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsList() {
    if (_alerts.isEmpty) {
      return SliverFillRemaining(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: AppColors.safe),
                  const SizedBox(height: 16),
                  const Text(
                    'No Active Alerts',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'All systems are operating normally',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final alert = _alerts[index];
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
        }, childCount: _alerts.length),
      ),
    );
  }
}
