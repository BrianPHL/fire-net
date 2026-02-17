class AppRoutes {
  AppRoutes._();

  // Auth routes
  static const String login = '/login';
  static const String register = '/register';

  // User routes
  static const String userHome = '/user/home';
  static const String alerts = '/user/alerts';
  static const String alertHistory = '/user/alert-history';
  static const String alertDetail = '/user/alert-detail';
  static const String sensors = '/user/sensors';
  static const String sensorDetail = '/user/sensor-detail';

  // Engineer routes
  static const String engineerDashboard = '/engineer/dashboard';
  static const String sensorManagement = '/engineer/sensor-management';
  static const String systemConfig = '/engineer/system-config';

  // Initial route
  static const String initial = login;
}
