import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/state/progress_driver.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';

import 'harness.dart';

void main() {
  group('ProgressDriver (replay mode)', () {
    testWidgets('should expose the post-hold progress to the builder', (
      tester,
    ) async {
      final seen = <double>[];
      double? latest;
      await pumpState(
        tester,
        ProgressDriver(
          duration: AppDurations.normal,
          active: true,
          delayFraction: 0.25,
          builder: (context, progress, child) {
            latest = progress;
            seen.add(progress);
            return child;
          },
          child: const Text('payload'),
        ),
      );
      await tester.pump();
      expect(latest, 0.0, reason: 'inside the delay hold');

      await tester.pump();
      await tester.pump(AppDurations.normal ~/ 4);
      await tester.pump();
      expect(
        latest,
        closeTo(0.0, 0.001),
        reason: 'still inside the first quarter of the timeline',
      );

      await tester.pump(AppDurations.normal ~/ 4);
      await tester.pump();
      expect(latest, greaterThan(0.0));
      expect(latest, lessThan(1.0));

      await tester.pumpAndSettle();
      expect(latest, 1.0);
      expect(seen.first, 0.0);
    });

    testWidgets('should hold the start state when inactive and replay the '
        'run on re-activation', (tester) async {
      double? latest;
      Widget driver(bool active) => ProgressDriver(
        duration: AppDurations.normal,
        active: active,
        builder: (context, progress, child) {
          latest = progress;
          return child;
        },
        child: const Text('payload'),
      );

      await pumpState(tester, driver(true));
      await tester.pumpAndSettle();
      expect(latest, 1.0);

      await pumpState(tester, driver(false));
      await tester.pump();
      expect(latest, 0.0, reason: 'inactive holds the start state');

      await tester.pump(AppDurations.normal * 2);
      await tester.pump();
      expect(latest, 0.0, reason: 'time does not advance an inactive page');

      await pumpState(tester, driver(true));
      await tester.pump();
      expect(latest, 0.0, reason: 're-activation restarts the run from zero');
    });

    testWidgets('should jump to the settled progress when animations are '
        'disabled', (tester) async {
      double? latest;
      await pumpState(
        tester,
        ProgressDriver(
          duration: AppDurations.normal,
          active: true,
          builder: (context, progress, child) {
            latest = progress;
            return child;
          },
          child: const Text('payload'),
        ),
        disableAnimations: true,
      );
      await tester.pump();
      expect(latest, 1.0);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('ProgressDriver (toggle mode)', () {
    testWidgets('should mount settled on the state it is built in', (
      tester,
    ) async {
      double? latest;
      await pumpState(
        tester,
        ProgressDriver(
          duration: AppDurations.normal,
          active: true,
          mode: ProgressDriverMode.toggle,
          builder: (context, progress, child) {
            latest = progress;
            return child;
          },
          child: const Text('payload'),
        ),
      );
      await tester.pump();
      expect(latest, 1.0);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('should drive forward on activation and reverse on '
        'deactivation, continuing from the running value', (tester) async {
      double? latest;
      Widget driver(bool active) => ProgressDriver(
        duration: AppDurations.normal,
        active: active,
        mode: ProgressDriverMode.toggle,
        builder: (context, progress, child) {
          latest = progress;
          return child;
        },
        child: const Text('payload'),
      );

      await pumpState(tester, driver(false));
      await tester.pump();
      expect(latest, 0.0);

      await pumpState(tester, driver(true));
      await tester.pump(AppDurations.normal ~/ 2);
      await tester.pump();
      final midValue = latest!;
      expect(midValue, inExclusiveRange(0.0, 1.0));

      await pumpState(tester, driver(false));
      await tester.pump(AppDurations.normal ~/ 4);
      await tester.pump();
      expect(
        latest,
        lessThan(midValue),
        reason: 'deactivation reverses from where the run was',
      );

      await tester.pumpAndSettle();
      expect(latest, 0.0);
    });

    testWidgets('should snap to the target state when animations are '
        'disabled', (tester) async {
      double? latest;
      Widget driver(bool active) => ProgressDriver(
        duration: AppDurations.normal,
        active: active,
        mode: ProgressDriverMode.toggle,
        builder: (context, progress, child) {
          latest = progress;
          return child;
        },
        child: const Text('payload'),
      );

      await pumpState(tester, driver(false), disableAnimations: true);
      await pumpState(tester, driver(true), disableAnimations: true);
      expect(latest, 1.0);
      expect(tester.hasRunningAnimations, isFalse);

      await pumpState(tester, driver(false), disableAnimations: true);
      expect(latest, 0.0);
    });
  });
}
