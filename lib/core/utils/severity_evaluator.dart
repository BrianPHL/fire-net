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

class AdvancedSeverityEvaluation {
  const AdvancedSeverityEvaluation({
    required this.severity,
    required this.exceededMetrics,
    required this.triggeredRules,
    required this.riskScore,
    required this.confidence,
    required this.alertCode,
  });

  final String severity;
  final List<String> exceededMetrics;
  final List<String> triggeredRules;
  final int riskScore;
  final String confidence;
  final String alertCode;

  bool get isDanger => severity == SensorThresholds.severityDanger;
  bool get isWarning => severity == SensorThresholds.severityWarning;
  bool get isSafe => severity == SensorThresholds.severitySafe;
}

class SeverityEvaluator {
  SeverityEvaluator._();

  static const double _mlxObjectWarning = 60.0;
  static const double _mlxObjectDanger = 80.0;
  static const double _thermalDeltaWarning = 15.0;
  static const double _thermalDeltaDanger = 25.0;

  static AdvancedSeverityEvaluation evaluateAdvanced({
    required double temperature,
    required double smoke,
    required double gas,
    bool fireDetected = false,
    bool hasSensorError = false,
    double? mlxAmbient,
    double? mlxObject,
    ThresholdConfig? thresholds,
  }) {
    final config = thresholds ?? ThresholdConfig.defaults();

    if (hasSensorError) {
      return const AdvancedSeverityEvaluation(
        severity: SensorThresholds.severityDanger,
        exceededMetrics: <String>['sensorError'],
        triggeredRules: <String>['sensor_error'],
        riskScore: 100,
        confidence: 'high',
        alertCode: 'sensor_fault',
      );
    }

    final temperatureWarning = temperature >= config.temperatureWarning;
    final temperatureDanger = temperature >= config.temperatureDanger;
    final smokeWarning = smoke >= config.smokeWarning;
    final smokeDanger = smoke >= config.smokeDanger;
    final gasWarning = gas >= config.gasWarning;
    final gasDanger = gas >= config.gasDanger;

    final hasMlxAmbient = mlxAmbient != null;
    final hasMlxObject = mlxObject != null;
    final thermalDelta = hasMlxAmbient && hasMlxObject
        ? (mlxObject - mlxAmbient)
        : 0.0;

    final irObjectWarning = hasMlxObject && mlxObject >= _mlxObjectWarning;
    final irObjectDanger = hasMlxObject && mlxObject >= _mlxObjectDanger;
    final thermalDeltaWarning =
        hasMlxAmbient && hasMlxObject && thermalDelta >= _thermalDeltaWarning;
    final thermalDeltaDanger =
        hasMlxAmbient && hasMlxObject && thermalDelta >= _thermalDeltaDanger;

    final heatAndGas = temperatureWarning && gasWarning;
    final heatAndSmoke = temperatureWarning && smokeWarning;
    final gasAndSmoke = gasWarning && smokeWarning;
    final thermalAndCombustion =
        (irObjectWarning || thermalDeltaWarning) &&
        (gasWarning || smokeWarning);
    final fireCorroborated =
        fireDetected &&
        (temperatureWarning ||
            gasWarning ||
            smokeWarning ||
            irObjectWarning ||
            thermalDeltaWarning);

    final exceededMetrics = <String>[];
    if (temperatureWarning) {
      exceededMetrics.add('temperature');
    }
    if (smokeWarning) {
      exceededMetrics.add('smoke');
    }
    if (gasWarning) {
      exceededMetrics.add('gas');
    }
    if (irObjectWarning) {
      exceededMetrics.add('mlxObject');
    }
    if (thermalDeltaWarning) {
      exceededMetrics.add('thermalDelta');
    }
    if (fireDetected) {
      exceededMetrics.add('fireDetected');
    }

    final triggeredRules = <String>[];
    if (temperatureDanger) {
      triggeredRules.add('temperature_danger');
    } else if (temperatureWarning) {
      triggeredRules.add('temperature_warning');
    }
    if (smokeDanger) {
      triggeredRules.add('co_danger');
    } else if (smokeWarning) {
      triggeredRules.add('co_warning');
    }
    if (gasDanger) {
      triggeredRules.add('gas_danger');
    } else if (gasWarning) {
      triggeredRules.add('gas_warning');
    }
    if (irObjectDanger) {
      triggeredRules.add('ir_object_danger');
    } else if (irObjectWarning) {
      triggeredRules.add('ir_object_warning');
    }
    if (thermalDeltaDanger) {
      triggeredRules.add('thermal_delta_danger');
    } else if (thermalDeltaWarning) {
      triggeredRules.add('thermal_delta_warning');
    }
    if (heatAndGas) {
      triggeredRules.add('heat_gas_correlation');
    }
    if (heatAndSmoke) {
      triggeredRules.add('heat_co_correlation');
    }
    if (gasAndSmoke) {
      triggeredRules.add('gas_co_correlation');
    }
    if (thermalAndCombustion) {
      triggeredRules.add('thermal_combustion_correlation');
    }
    if (fireDetected) {
      triggeredRules.add('fire_flag');
    }

    var riskScore = 0;
    if (temperatureWarning) {
      riskScore += 10;
    }
    if (temperatureDanger) {
      riskScore += 10;
    }
    if (smokeWarning) {
      riskScore += 14;
    }
    if (smokeDanger) {
      riskScore += 14;
    }
    if (gasWarning) {
      riskScore += 14;
    }
    if (gasDanger) {
      riskScore += 14;
    }
    if (irObjectWarning) {
      riskScore += 8;
    }
    if (irObjectDanger) {
      riskScore += 8;
    }
    if (thermalDeltaWarning) {
      riskScore += 8;
    }
    if (thermalDeltaDanger) {
      riskScore += 8;
    }
    if (heatAndGas) {
      riskScore += 6;
    }
    if (heatAndSmoke) {
      riskScore += 6;
    }
    if (gasAndSmoke) {
      riskScore += 10;
    }
    if (thermalAndCombustion) {
      riskScore += 10;
    }
    if (fireDetected) {
      riskScore += 20;
    }
    if (riskScore > 100) {
      riskScore = 100;
    }

    final severity = _deriveSeverity(
      riskScore: riskScore,
      fireCorroborated: fireCorroborated,
      temperatureDanger: temperatureDanger,
      smokeDanger: smokeDanger,
      gasDanger: gasDanger,
      irObjectWarning: irObjectWarning,
      irObjectDanger: irObjectDanger,
      thermalDeltaWarning: thermalDeltaWarning,
      thermalDeltaDanger: thermalDeltaDanger,
      gasWarning: gasWarning,
      smokeWarning: smokeWarning,
      temperatureWarning: temperatureWarning,
    );

    final signalCount = <bool>[
      temperatureWarning,
      smokeWarning,
      gasWarning,
      fireDetected,
      irObjectWarning || thermalDeltaWarning,
    ].where((value) => value).length;

    final confidence = _deriveConfidence(
      severity: severity,
      riskScore: riskScore,
      signalCount: signalCount,
      fireCorroborated: fireCorroborated,
    );

    final alertCode = _deriveAlertCode(
      fireCorroborated: fireCorroborated,
      temperatureDanger: temperatureDanger,
      smokeDanger: smokeDanger,
      gasDanger: gasDanger,
      irObjectDanger: irObjectDanger,
      thermalDeltaDanger: thermalDeltaDanger,
      gasAndSmoke: gasAndSmoke,
      thermalAndCombustion: thermalAndCombustion,
      heatAndGas: heatAndGas,
      heatAndSmoke: heatAndSmoke,
      temperatureWarning: temperatureWarning,
      smokeWarning: smokeWarning,
      gasWarning: gasWarning,
      irObjectWarning: irObjectWarning,
      thermalDeltaWarning: thermalDeltaWarning,
    );

    return AdvancedSeverityEvaluation(
      severity: severity,
      exceededMetrics: exceededMetrics,
      triggeredRules: triggeredRules,
      riskScore: riskScore,
      confidence: confidence,
      alertCode: alertCode,
    );
  }

  static SeverityEvaluation evaluate({
    required double temperature,
    required double smoke,
    required double gas,
    bool fireDetected = false,
    bool hasSensorError = false,
    double? mlxAmbient,
    double? mlxObject,
    ThresholdConfig? thresholds,
  }) {
    final advanced = evaluateAdvanced(
      temperature: temperature,
      smoke: smoke,
      gas: gas,
      fireDetected: fireDetected,
      hasSensorError: hasSensorError,
      mlxAmbient: mlxAmbient,
      mlxObject: mlxObject,
      thresholds: thresholds,
    );

    return SeverityEvaluation(
      severity: advanced.severity,
      exceededMetrics: advanced.exceededMetrics,
    );
  }

  static String evaluateSeverity({
    required double temperature,
    required double smoke,
    required double gas,
    bool fireDetected = false,
    bool hasSensorError = false,
    double? mlxAmbient,
    double? mlxObject,
    ThresholdConfig? thresholds,
  }) {
    return evaluate(
      temperature: temperature,
      smoke: smoke,
      gas: gas,
      fireDetected: fireDetected,
      hasSensorError: hasSensorError,
      mlxAmbient: mlxAmbient,
      mlxObject: mlxObject,
      thresholds: thresholds,
    ).severity;
  }

  static String _deriveSeverity({
    required int riskScore,
    required bool fireCorroborated,
    required bool temperatureDanger,
    required bool smokeDanger,
    required bool gasDanger,
    required bool irObjectWarning,
    required bool irObjectDanger,
    required bool thermalDeltaWarning,
    required bool thermalDeltaDanger,
    required bool gasWarning,
    required bool smokeWarning,
    required bool temperatureWarning,
  }) {
    final danger =
        fireCorroborated ||
        (temperatureDanger && (gasDanger || smokeDanger)) ||
        (gasDanger && smokeDanger) ||
        ((irObjectDanger || thermalDeltaDanger) &&
            (gasWarning || smokeWarning)) ||
        riskScore >= 80;

    if (danger) {
      return SensorThresholds.severityDanger;
    }

    final warning =
        riskScore >= 35 ||
        temperatureWarning ||
        smokeWarning ||
        gasWarning ||
        irObjectWarning ||
        thermalDeltaWarning;

    if (warning) {
      return SensorThresholds.severityWarning;
    }

    return SensorThresholds.severitySafe;
  }

  static String _deriveConfidence({
    required String severity,
    required int riskScore,
    required int signalCount,
    required bool fireCorroborated,
  }) {
    if (fireCorroborated || riskScore >= 85 || signalCount >= 4) {
      return 'high';
    }

    if (riskScore >= 55 || signalCount >= 2) {
      return 'medium';
    }

    if (severity == SensorThresholds.severitySafe) {
      return 'low';
    }

    return 'low';
  }

  static String _deriveAlertCode({
    required bool fireCorroborated,
    required bool temperatureDanger,
    required bool smokeDanger,
    required bool gasDanger,
    required bool irObjectDanger,
    required bool thermalDeltaDanger,
    required bool gasAndSmoke,
    required bool thermalAndCombustion,
    required bool heatAndGas,
    required bool heatAndSmoke,
    required bool temperatureWarning,
    required bool smokeWarning,
    required bool gasWarning,
    required bool irObjectWarning,
    required bool thermalDeltaWarning,
  }) {
    if (fireCorroborated) {
      return 'fire_confirmed_multisensor';
    }
    if (gasDanger && smokeDanger) {
      return 'toxic_combustion_high';
    }
    if (temperatureDanger && (gasDanger || smokeDanger)) {
      return 'heat_combustion_critical';
    }
    if ((irObjectDanger || thermalDeltaDanger) &&
        (gasWarning || smokeWarning)) {
      return 'thermal_combustion_critical';
    }
    if (temperatureDanger) {
      return 'temperature_critical';
    }
    if (gasDanger) {
      return 'gas_critical';
    }
    if (smokeDanger) {
      return 'co_critical';
    }
    if (irObjectDanger) {
      return 'infrared_object_critical';
    }
    if (thermalDeltaDanger) {
      return 'thermal_delta_critical';
    }
    if (gasAndSmoke) {
      return 'gas_co_correlation_warning';
    }
    if (thermalAndCombustion) {
      return 'thermal_combustion_warning';
    }
    if (heatAndGas || heatAndSmoke) {
      return 'heat_combustion_warning';
    }
    if (temperatureWarning) {
      return 'temperature_warning';
    }
    if (gasWarning) {
      return 'gas_warning';
    }
    if (smokeWarning) {
      return 'co_warning';
    }
    if (irObjectWarning) {
      return 'infrared_object_warning';
    }
    if (thermalDeltaWarning) {
      return 'thermal_delta_warning';
    }
    return 'normal';
  }
}
