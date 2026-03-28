import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/theme/theme_provider.dart';

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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final appBarActions = <Widget>[
          ...?actions,
          IconButton(
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
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
              ? _buildBottomNavigationBar(context)
              : null,
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
        currentIndex: currentIndex!,
        onTap: onNavigationChanged,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: ThemeColors.getPrimary(context),
        unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color ?? ThemeColors.getTextSecondary(context),
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

