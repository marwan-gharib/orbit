import 'package:flutter/painting.dart';

/// One x-axis group of a bar chart: a label and one value per series.
final class ChartBarGroup {
  const ChartBarGroup({
    required this.label,
    required this.values,
    this.color,
  });

  final String label;
  final List<double> values;

  /// Overrides the series colour for this group's bars (e.g. one colour per
  /// stage in a single-series chart).
  final Color? color;
}

/// A named, coloured series of a bar or line chart.
final class ChartSeries {
  const ChartSeries({required this.name, required this.color});

  final String name;
  final Color color;
}

/// One slice of a donut chart.
final class ChartSlice {
  const ChartSlice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}
