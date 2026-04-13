import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/alert.dart';
import '../../../routes/app_routes.dart';
import '../../../services/alert_service.dart';
import '../../../shared/layouts/app_scaffold.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../auth/auth_service.dart';
import '../user_service.dart';
import '../widgets/alert_card.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _currentIndex = 1;
  String _selectedSeverity = 'all';

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

      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.startup, (route) => false);
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

      ErrorDialogHelper.showSnackbarError(context, 'Unable to logout. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Active Alerts',
      currentIndex: _currentIndex,
      onNavigationChanged: _onNavigationChanged,
      onLogout: _handleLogout,
      body: SafeArea(
        child: StreamBuilder<List<Alert>>(
          stream: _alertService.watchAlerts(status: Alert.statusActive),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load alerts.',
                  style: TextStyle(color: ThemeColors.getTextPrimary(context)),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final activeAlerts = snapshot.data ?? <Alert>[];
            final filteredAlerts = _applySeverityFilter(activeAlerts);

            return CustomScrollView(
              slivers: [
                _buildHeader(activeAlerts),
                _buildSeverityFilter(context),
                _buildAlertsList(filteredAlerts),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Alert> _applySeverityFilter(List<Alert> alerts) {
    if (_selectedSeverity == 'all') {
      return alerts;
    }
    return alerts.where((alert) => alert.severity == _selectedSeverity).toList();
  }

  Widget _buildHeader(List<Alert> alerts) {
    final dangerCount = alerts.where((a) => a.severity == Alert.severityDanger).length;
    final warningCount = alerts.where((a) => a.severity == Alert.severityWarning).length;
    final safeCount = alerts.where((a) => a.severity == Alert.severitySafe).length;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return AppSectionHeader(
                      title: 'Active Alerts',
                      subtitle: 'Live Firestore stream of unresolved events',
                      trailing: StatusPill(
                        label: 'Live Feed',
                        color: ThemeColors.getWarning(context),
                        backgroundColor: ThemeColors.getWarningBackground(context),
                        icon: Icons.notifications_active,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    StatusPill(
                      label: '$dangerCount danger',
                      color: ThemeColors.getDanger(context),
                      backgroundColor: ThemeColors.getDangerBackground(context),
                      icon: Icons.local_fire_department,
                    ),
                    StatusPill(
                      label: '$warningCount warning',
                      color: ThemeColors.getWarning(context),
                      backgroundColor: ThemeColors.getWarningBackground(context),
                      icon: Icons.warning_amber,
                    ),
                    StatusPill(
                      label: '$safeCount safe',
                      color: ThemeColors.getSafe(context),
                      backgroundColor: ThemeColors.getSafeBackground(context),
                      icon: Icons.check_circle,
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

  Widget _buildSeverityFilter(BuildContext context) {
    const options = <String, String>{
      'all': 'All',
      Alert.severitySafe: 'Safe',
      Alert.severityWarning: 'Warning',
      Alert.severityDanger: 'Danger',
    };

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.entries.map((entry) {
            final isSelected = _selectedSeverity == entry.key;
            return ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedSeverity = entry.key);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAlertsList(List<Alert> alerts) {
    if (alerts.isEmpty) {
      return SliverFillRemaining(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: ThemeColors.getSafe(context)),
                  const SizedBox(height: 16),
                  Text(
                    'No Active Alerts',
                    style: TextStyle(
                      color: ThemeColors.getTextPrimary(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All systems are operating normally',
                    style: TextStyle(color: ThemeColors.getTextSecondary(context), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
