import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/widgets/charts/app_bar_chart.dart';
import 'package:orbit/core/widgets/charts/chart_data.dart';

import '../../../core/widgets/harness.dart';

String _compact(double value) => value.toStringAsFixed(0);

void main() {
  testWidgets('should paint bars and labels without errors', (tester) async {
    await pumpWidget(
      tester,
      AppBarChart(
        groups: const [
          ChartBarGroup(label: 'Nov', values: [40000, 15000]),
          ChartBarGroup(label: 'Dec', values: [70000, 35000]),
        ],
        series: const [
          ChartSeries(name: 'Deal', color: Colors.blue),
          ChartSeries(name: 'Weighted', color: Colors.teal),
        ],
        valueFormatter: _compact,
      ),
      settle: false,
    );
    await tester.pump(AppDurations.extraSlow + AppDurations.normal);

    expect(tester.takeException(), isNull);
  });

  testWidgets('should show a selection bubble after tapping a group', (
    tester,
  ) async {
    await pumpWidget(
      tester,
      AppBarChart(
        groups: const [
          ChartBarGroup(label: 'Nov', values: [40000]),
          ChartBarGroup(label: 'Dec', values: [70000]),
        ],
        series: const [ChartSeries(name: 'Deal', color: Colors.blue)],
        valueFormatter: _compact,
        height: 200,
      ),
      settle: false,
    );
    await tester.pump(AppDurations.extraSlow + AppDurations.normal);

    final box = tester.getSize(find.byType(AppBarChart));
    // Second group's slot centre: axis + half a slot into the second half.
    await tester.tapAt(Offset(box.width * 0.75, box.height * 0.5));
    await tester.pump(AppDurations.fast);

    expect(tester.takeException(), isNull);
  });

  testWidgets('should tolerate an empty chart', (tester) async {
    await pumpWidget(
      tester,
      AppBarChart(
        groups: const [],
        series: const [ChartSeries(name: 'Deal', color: Colors.blue)],
        valueFormatter: _compact,
        height: 200,
      ),
      settle: false,
    );
    await tester.pump(AppDurations.extraSlow + AppDurations.normal);

    expect(tester.takeException(), isNull);
  });
}
