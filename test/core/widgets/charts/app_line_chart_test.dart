import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/widgets/charts/app_line_chart.dart';
import 'package:orbit/core/widgets/charts/chart_data.dart';

import '../../../core/widgets/harness.dart';

String _compact(double value) => value.toStringAsFixed(0);

void main() {
  testWidgets('should paint lines, dots and labels without errors', (
    tester,
  ) async {
    await pumpWidget(
      tester,
      AppLineChart(
        labels: const ['Nov', 'Dec'],
        series: const [
          ChartSeries(name: 'Deal', color: Colors.blue),
          ChartSeries(name: 'Weighted', color: Colors.teal),
        ],
        values: const [
          [30000, 70000],
          [15000, 35000],
        ],
        valueFormatter: _compact,
        height: 200,
      ),
      settle: false,
    );
    await tester.pump(AppDurations.extraSlow + AppDurations.normal);

    expect(tester.takeException(), isNull);
  });

  testWidgets('should show a selection bubble after tapping a point', (
    tester,
  ) async {
    await pumpWidget(
      tester,
      AppLineChart(
        labels: const ['Nov', 'Dec'],
        series: const [ChartSeries(name: 'Deal', color: Colors.blue)],
        values: const [
          [30000, 70000],
        ],
        valueFormatter: _compact,
        height: 200,
      ),
      settle: false,
    );
    await tester.pump(AppDurations.extraSlow + AppDurations.normal);

    final box = tester.getSize(find.byType(AppLineChart));
    await tester.tapAt(Offset(box.width * 0.6, box.height * 0.4));
    await tester.pump(AppDurations.fast);

    expect(tester.takeException(), isNull);
  });

  testWidgets('should tolerate empty labels', (tester) async {
    await pumpWidget(
      tester,
      AppLineChart(
        labels: const [],
        series: const [ChartSeries(name: 'Deal', color: Colors.blue)],
        values: const [],
        valueFormatter: _compact,
        height: 200,
      ),
      settle: false,
    );
    await tester.pump(AppDurations.extraSlow + AppDurations.normal);

    expect(tester.takeException(), isNull);
  });
}
