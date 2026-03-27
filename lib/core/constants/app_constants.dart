/// General app constants
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // App info
  static const String appName = 'FireNet';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'A decentralized IoT-based fire, gas, and smoke detection network';

  // API endpoints (placeholder palang)
  static const String baseUrl = 'http://localhost:3000/api';
  static const String wsUrl = 'ws://localhost:3000';

  // Time formats
  static const String timeFormat = 'hh:mm a';
  static const String dateFormat = 'MMM d';
  static const String fullDateFormat = 'MMM d, yyyy';
  static const String dateTimeFormat = 'MMM d, yyyy • hh:mm a';

  // UI constants
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double iconSize = 24.0;

  // Animation durations
  static const int defaultAnimationDuration = 300;
  static const int fastAnimationDuration = 150;
  static const int slowAnimationDuration = 600;
}
