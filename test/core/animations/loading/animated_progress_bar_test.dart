import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/loading/animated_progress_bar.dart';
import 'package:orbit/core/animations/tokens/app_animation_constants.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';

import 'harness.dart';

void main() {
  double widthFactorOf(WidgetTester tester) =>
      tester.widget<Align>(find.byType(Align)).widthFactor ?? -1;

  AlignmentDirectional segmentAlignmentOf(WidgetTester tester) =>
      tester.widget<Align>(find.byType(Align)).alignment
          as AlignmentDirectional;

  testWidgets('should render the given progress immediately when built', (
    tester,
  ) async {
    await pumpLoading(tester, const AnimatedProgressBar(progress: 0.3));

    expect(widthFactorOf(tester), closeTo(0.3, 0.0001));
  });

  testWidgets('should ease to the new progress when the value changes', (
    tester,
  ) async {
    await pumpLoading(tester, const AnimatedProgressBar(progress: 0.3));
    await pumpLoading(tester, const AnimatedProgressBar(progress: 0.9));

    await tester.pump(AppDurations.fast);
    final midway = widthFactorOf(tester);
    expect(midway, greaterThan(0.3));
    expect(midway, lessThan(0.9));

    await tester.pump(AppDurations.normal);
    expect(widthFactorOf(tester), closeTo(0.9, 0.0001));
  });

  testWidgets(
    'should jump straight to the new progress when animations are disabled',
    (tester) async {
      await pumpLoading(tester, const AnimatedProgressBar(progress: 0.3));
      await pumpLoading(
        tester,
        const AnimatedProgressBar(progress: 0.9),
        disableAnimations: true,
      );

      expect(widthFactorOf(tester), closeTo(0.9, 0.0001));
    },
  );

  testWidgets('should keep the fill directional when the direction is RTL', (
    tester,
  ) async {
    await pumpLoading(
      tester,
      const AnimatedProgressBar(progress: 0.5),
      direction: TextDirection.rtl,
    );

    final align = tester.widget<Align>(find.byType(Align));
    expect(align.alignment, isA<AlignmentDirectional>());
  });

  testWidgets('should travel a segment across the track when indeterminate', (
    tester,
  ) async {
    await pumpLoading(tester, const AnimatedProgressBar());

    final segment = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(segment.widthFactor, AppAnimationConstants.progressBarSegmentWidth);

    final start = segmentAlignmentOf(tester).start;
    await tester.pump(const Duration(milliseconds: 100));

    expect(segmentAlignmentOf(tester).start, isNot(start));
  });

  testWidgets(
    'should freeze the segment centered when indeterminate with animations disabled',
    (tester) async {
      await pumpLoading(
        tester,
        const AnimatedProgressBar(),
        disableAnimations: true,
      );

      expect(segmentAlignmentOf(tester).start, 0.0);
    },
  );

  testWidgets('should fail fast when the progress is outside the bounds', (
    tester,
  ) async {
    expect(
      () => pumpLoading(tester, AnimatedProgressBar(progress: 1.5)),
      throwsA(isA<AssertionError>()),
    );
  });

  testWidgets('should start the indeterminate travel when switched mid-tween', (
    tester,
  ) async {
    await pumpLoading(tester, const AnimatedProgressBar(progress: 0.3));
    await pumpLoading(tester, const AnimatedProgressBar(progress: 0.9));
    await tester.pump(AppDurations.fast);
    await pumpLoading(tester, const AnimatedProgressBar());

    final start = segmentAlignmentOf(tester).start;
    await tester.pump(const Duration(milliseconds: 100));

    expect(segmentAlignmentOf(tester).start, isNot(start));
  });

  testWidgets('should lay out full width when placed in a Row with Expanded', (
    tester,
  ) async {
    await pumpLoading(
      tester,
      Row(children: [Expanded(child: AnimatedProgressBar(progress: 0.5))]),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(AnimatedProgressBar)).width,
      tester.getSize(find.byType(Row)).width,
    );
  });

  testWidgets('should lay out inside a bounded loose parent when padded', (
    tester,
  ) async {
    await pumpLoading(
      tester,
      const Padding(
        padding: EdgeInsets.all(8),
        child: AnimatedProgressBar(progress: 0.5),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('should dispose cleanly when removed', (tester) async {
    await pumpLoading(tester, const AnimatedProgressBar(progress: 0.5));
    await pumpLoading(tester, const SizedBox());

    expect(tester.takeException(), isNull);
  });
}
