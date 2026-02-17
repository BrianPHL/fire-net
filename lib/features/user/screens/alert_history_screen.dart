import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/alert.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/layouts/app_scaffold.dart';
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
      currentIndex: _currentIndex,
      onNavigationChanged: _onNavigationChanged,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            _buildFilters(),
            _buildAlertsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.cardBackgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.history,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alert History',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_filteredAlerts.length} alerts found',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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

  Widget _buildFilters() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Card(
          color: AppColors.cardBackgroundLight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.filter_alt,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Filters',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Severity',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSeverityChips(),
                const SizedBox(height: 16),
                const Text(
                  'Time Range',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
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
          backgroundColor: AppColors.cardBackground,
          selectedColor: severity == 'Danger' 
              ? AppColors.dangerBackground 
              : severity == 'Warning'
                  ? AppColors.warningBackground
                  : AppColors.primary.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected
                ? (severity == 'Danger' 
                    ? AppColors.danger 
                    : severity == 'Warning'
                        ? AppColors.warning
                        : AppColors.primary)
                : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }

  Widget _buildTimeRangeChips() {
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
          backgroundColor: AppColors.cardBackground,
          selectedColor: AppColors.primary.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: 16),
              Text(
                'No Alerts Found',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try adjusting your filters',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
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
          },
          childCount: _filteredAlerts.length,
        ),
      ),
    );
  }
}
