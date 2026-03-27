class SensorThresholds {
  // Prevent instantiation
  SensorThresholds._();

  // Temperature thresholds (in Celsius)
  static const double tempWarning = 40.0;
  static const double tempDanger = 50.0;
  static const double tempNormal = 35.0;

  // Smoke thresholds (in PPM - parts per million)
  static const double smokeWarning = 50.0;
  static const double smokeDanger = 100.0;
  static const double smokeNormal = 30.0;

  // Gas thresholds (in PPM)
  static const double gasWarning = 100.0;
  static const double gasDanger = 200.0;
  static const double gasNormal = 50.0;

  // Alert severity levels
  static const String severitySafe = 'safe';
  static const String severityWarning = 'warning';
  static const String severityDanger = 'danger';
}
