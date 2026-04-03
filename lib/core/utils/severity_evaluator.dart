import '../../models/threshold_config.dart';
import '../constants/sensor_thresholds.dart';

class SeverityEvaluation {
  const SeverityEvaluation({
    required this.severity,
    required this.exceededMetrics,
  });

  final String severity;
  final List<String> exceededMetrics;

  bool get isDanger => severity == SensorThresholds.severityDanger;
  bool get isWarning => severity == SensorThresholds.severityWarning;
  bool get isSafe => severity == SensorThresholds.severitySafe;
}

class SeverityEvaluator {
  SeverityEvaluator._();

  static SeverityEvaluation evaluate({
    required double temperature,
    required double smoke,
    required double gas,
    bool hasSensorError = false,
    ThresholdConfig? thresholds,
  }) {
    final config = thresholds ?? ThresholdConfig.defaults();

    if (hasSensorError) {
      return const SeverityEvaluation(
        severity: SensorThresholds.severityDanger,
        exceededMetrics: <String>['sensorError'],
      );
    }

    final dangerMetrics = <String>[];
    if (temperature >= config.temperatureDanger) {
      dangerMetrics.add('temperature');
    }
    if (smoke >= config.smokeDanger) {
      dangerMetrics.add('smoke');
    }
    if (gas >= config.gasDanger) {
      dangerMetrics.add('gas');
    }

    if (dangerMetrics.isNotEmpty) {
      return SeverityEvaluation(
        severity: SensorThresholds.severityDanger,
        exceededMetrics: dangerMetrics,
      );
    }

    final warningMetrics = <String>[];
    if (temperature >= config.temperatureWarning) {
      warningMetrics.add('temperature');
    }
    if (smoke >= config.smokeWarning) {
      warningMetrics.add('smoke');
    }
    if (gas >= config.gasWarning) {
      warningMetrics.add('gas');
    }

    if (warningMetrics.isNotEmpty) {
      return SeverityEvaluation(
        severity: SensorThresholds.severityWarning,
        exceededMetrics: warningMetrics,
      );
    }

    return const SeverityEvaluation(
      severity: SensorThresholds.severitySafe,
      exceededMetrics: <String>[],
    );
  }

  static String evaluateSeverity({
    required double temperature,
    required double smoke,
    required double gas,
    bool hasSensorError = false,
    ThresholdConfig? thresholds,
  }) {
    return evaluate(
      temperature: temperature,
      smoke: smoke,
      gas: gas,
      hasSensorError: hasSensorError,
      thresholds: thresholds,
    ).severity;
  }
}