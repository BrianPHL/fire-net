import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// App scaffold layout with consistent structure
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? floatingActionButton;
  final int? currentIndex;
  final ValueChanged<int>? onNavigationChanged;
  final List<Widget>? actions;
  final VoidCallback? onLogout;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;

  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.floatingActionButton,
    this.currentIndex,
    this.onNavigationChanged,
    this.actions,
    this.onLogout,
    this.bottom,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final appBarActions = <Widget>[
      ...?actions,
      if (onLogout != null)
        IconButton(
          onPressed: onLogout,
          tooltip: 'Logout',
          icon: const Icon(Icons.logout),
        ),
    ];

    return Scaffold(
      appBar: title != null || onLogout != null
          ? AppBar(
              title: title != null ? Text(title!) : null,
              automaticallyImplyLeading: showBackButton,
              actions: appBarActions,
              bottom: bottom,
            )
          : null,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: currentIndex != null && onNavigationChanged != null
          ? _buildBottomNavigationBar()
          : null,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderColor, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex!,
        onTap: onNavigationChanged,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
