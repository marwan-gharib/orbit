import 'dart:math' as math;

/// Pure axis maths shared by the chart widgets.
abstract final class ChartScale {
  static const List<double> _steps = [
    1,
    1.2,
    1.5,
    2,
    2.5,
    3,
    4,
    5,
    6,
    8,
    10,
  ];

  /// Smallest "nice" axis maximum that is `>= value` (1, 1.2, 1.5, 2, 2.5,
  /// 3, 4, 5, 6, 8 or 10 times a power of ten). Returns 1 for empty or
  /// invalid input so an all-zero chart still has a sane scale.
  static double niceMax(double value) {
    if (value.isNaN || value.isInfinite || value <= 0) return 1;
    final exponent = (math.log(value) / math.ln10).floor();
    final magnitude = math.pow(10, exponent).toDouble();
    final normalized = value / magnitude;
    for (final step in _steps) {
      if (normalized <= step + 1e-9) return step * magnitude;
    }
    return 10 * magnitude;
  }

  /// Evenly spaced grid values from 0 to [max] (inclusive).
  static List<double> gridValues(double max, {int divisions = 4}) => [
    for (var i = 0; i <= divisions; i++) max * i / divisions,
  ];

  /// Largest value across [series], or 0 when everything is empty.
  static double maxOf(Iterable<Iterable<double>> series) {
    var result = 0.0;
    for (final values in series) {
      for (final value in values) {
        if (value > result) result = value;
      }
    }
    return result;
  }
}
