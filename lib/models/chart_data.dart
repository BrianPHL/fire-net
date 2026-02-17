class ChartDataPoint {
  final DateTime time;
  final double value;

  const ChartDataPoint({
    required this.time,
    required this.value,
  });

  /// Mock 24-hour temperature trend data
  static List<ChartDataPoint> getMockTemperatureTrend() {
    final now = DateTime.now();
    return List.generate(24, (index) {
      final time = now.subtract(Duration(hours: 23 - index));
      double value;
      
      // Simulation of gradual temperature increase in the last few hours
      if (index < 18) {
        value = 20.0 + (index * 0.5); 
      } else if (index < 22) {
        value = 29.0 + (index - 18) * 2; 
      } else {
        value = 37.0 + (index - 22) * 7.5; 
      }
      
      return ChartDataPoint(time: time, value: value);
    });
  }

  /// Mock smoke trend data
  static List<ChartDataPoint> getMockSmokeTrend() {
    final now = DateTime.now();
    return List.generate(24, (index) {
      final time = now.subtract(Duration(hours: 23 - index));
      double value;
      
      if (index < 20) {
        value = 10.0 + (index * 0.3);
      } else {
        value = 16.0 + (index - 20) * 57.25;
      }
      
      return ChartDataPoint(time: time, value: value);
    });
  }

  /// Mock gas trend data
  static List<ChartDataPoint> getMockGasTrend() {
    final now = DateTime.now();
    return List.generate(24, (index) {
      final time = now.subtract(Duration(hours: 23 - index));
      final value = 40.0 + (index * 2.3);
      
      return ChartDataPoint(time: time, value: value);
    });
  }
}
