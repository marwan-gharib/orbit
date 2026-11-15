import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/widgets/charts/app_donut_chart.dart';
import 'package:orbit/core/widgets/charts/chart_data.dart';

import '../../../core/widgets/harness.dart';

void main() {
  List<ChartSlice> slices() => const [
    ChartSlice(label: 'Lead', value: 2, color: Colors.blue),
    ChartSlice(label: 'Won', value: 6, color: Colors.green),
  ];

  testWidgets('should paint the ring without errors', (tester) async {
    await pumpWidget(
      tester,
      AppDonutChart(slices: slices(), size: 160),
      settle: false,
    );
    await tester.pump(AppDurations.extraSlow + AppDurations.normal);

    expect(tester.takeException(), isNull);
  });

  testWidgets('should report a tapped slice and clear on a second tap', (
    tester,
  ) async {
    int? selected;
    await pumpWidget(
      tester,
      AppDonutChart(
        slices: slices(),
        size: 160,
        onSelectionChanged: (index) => selected = index,
      ),
      settle: false,
    );
    await tester.pump(AppDurations.extraSlow);

    // Slices start at 12 o'clock and run clockwise; a point 36° clockwise
    // from the top lands inside the first slice (2/10 of the circle).
    final origin = tester.getTopLeft(find.byType(AppDonutChart));
    await tester.tapAt(origin + const Offset(121, 23));
    await tester.pump(AppDurations.fast);

    expect(selected, 0);

    await tester.tapAt(origin + const Offset(121, 23));
    await tester.pump(AppDurations.fast);

    expect(selected, isNull);
  });

  testWidgets('should expose the selection to the centre builder', (
    tester,
  ) async {
    await pumpWidget(
      tester,
      AppDonutChart(
        slices: slices(),
        size: 160,
        centerBuilder: (context, index) => Text('picked ${index ?? 'none'}'),
      ),
      settle: false,
    );
    await tester.pump(AppDurations.extraSlow);

    expect(find.text('picked none'), findsOneWidget);

    final origin = tester.getTopLeft(find.byType(AppDonutChart));
    await tester.tapAt(origin + const Offset(121, 23));
    await tester.pump(AppDurations.fast);

    expect(find.text('picked 0'), findsOneWidget);
  });

  testWidgets('should show only a track ring when every slice is zero', (
    tester,
  ) async {
    await pumpWidget(
      tester,
      AppDonutChart(
        slices: const [ChartSlice(label: 'Lead', value: 0, color: Colors.blue)],
        size: 160,
      ),
      settle: false,
    );
    await tester.pump(AppDurations.extraSlow + AppDurations.normal);

    expect(tester.takeException(), isNull);
  });
}
