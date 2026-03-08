import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class EngineerScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? floatingActionButton;
  final int currentIndex;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;

  const EngineerScaffold({
    super.key,
    this.title,
    required this.body,
    this.floatingActionButton,
    required this.currentIndex,
    this.actions,
    this.bottom,
    this.showBackButton = false,
  });

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
    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              automaticallyImplyLeading: showBackButton,
              actions: actions,
              bottom: bottom,
            )
          : null,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onNavigationChanged(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
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
