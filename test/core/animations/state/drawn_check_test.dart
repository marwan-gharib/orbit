import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/animations/state/drawn_check.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';

import 'harness.dart';

void main() {
  testWidgets('should draw the check and burst once without errors', (
    tester,
  ) async {
    await pumpState(tester, const DrawnCheck(color: Colors.green));
    await tester.pump(AppDurations.extraSlow + AppDurations.normal);

    expect(tester.takeException(), isNull);
  });

  testWidgets('should skip the burst when burst is false', (tester) async {
    await pumpState(
      tester,
      const DrawnCheck(color: Colors.green, burst: false),
    );
    await tester.pump(AppDurations.extraSlow + AppDurations.normal);

    expect(tester.takeException(), isNull);
  });

  testWidgets('should request a square of the given edge', (tester) async {
    await pumpState(tester, const DrawnCheck(color: Colors.green, size: 40));
    await tester.pump(AppDurations.extraSlow);

    final paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(DrawnCheck),
        matching: find.byType(CustomPaint),
      ),
    );

    expect(paint.size, const Size(40, 40));
  });

  testWidgets('should show the check already drawn with reduce motion on', (
    tester,
  ) async {
    await pumpState(
      tester,
      const DrawnCheck(color: Colors.green),
      disableAnimations: true,
    );
    await tester.pump(AppDurations.extraSlow);

    expect(tester.takeException(), isNull);
  });
}
