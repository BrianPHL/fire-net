import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/helpers.dart';
import '../../routes/app_routes.dart';
import '../../features/auth/auth_service.dart';

class EngineerScaffold extends StatelessWidget {
  static final AuthService _authService = AuthService();

  final String? title;
  final Widget body;
  final Widget? floatingActionButton;
  final int currentIndex;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;
  final VoidCallback? onLogout;

  const EngineerScaffold({
    super.key,
    this.title,
    required this.body,
    this.floatingActionButton,
    required this.currentIndex,
    this.actions,
    this.bottom,
    this.showBackButton = false,
    this.onLogout,
  });

  Future<void> _handleDefaultLogout(BuildContext context) async {
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

      if (!context.mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } on Exception {
      if (!context.mounted) {
        return;
      }

      ErrorDialogHelper.showSnackbarError(
        context,
        'Unable to logout. Please try again.',
      );
    }
  }

  void _onNavigationChanged(BuildContext context, int index) {
    if (index == currentIndex) return;

    String route;
    switch (index) {
      case 0:
        route = AppRoutes.engineerDashboard;
        break;
      case 1:
        route = AppRoutes.sensorManagement;
        break;
      case 2:
        route = AppRoutes.systemConfig;
        break;
      case 3:
        route = AppRoutes.systemDiagnostics;
        break;
      default:
        return;
    }

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final logoutAction = onLogout ?? () => _handleDefaultLogout(context);

        final appBarActions = <Widget>[
          ...?actions,
          IconButton(
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
          IconButton(
            onPressed: logoutAction,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
          ),
        ];

        return Scaffold(
          appBar: title != null
              ? AppBar(
                  title: Text(title!),
                  automaticallyImplyLeading: showBackButton,
                  actions: appBarActions,
                  bottom: bottom,
                )
              : null,
          body: body,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: _buildBottomNavigationBar(context),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ThemeColors.getBorderColor(context),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onNavigationChanged(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.darkTextSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.router_outlined),
            activeIcon: Icon(Icons.router),
            label: 'Nodes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune),
            activeIcon: Icon(Icons.tune),
            label: 'Config',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_outlined),
            activeIcon: Icon(Icons.monitor_heart),
            label: 'System',
          ),
        ],
      ),
    );
  }
}

