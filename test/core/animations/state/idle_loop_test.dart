import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/state/idle_loop.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';

import 'harness.dart';

void main() {
  // A 120ms probe stays well inside one 1200ms cycle.
  const tick = Duration(milliseconds: 120);

  group('IdleLoop (typed ranges)', () {
    testWidgets('should loop the scale and fade while active, sawtooth-shaped '
        'by the curve', (tester) async {
      await pumpState(
        tester,
        _loop(scaleTo: 1.6, opacityTo: 0.0, curve: AppCurves.pulse),
      );
      await tester.pump(tick);

      final phase = 120 / 1200.0;
      final eased = AppCurves.pulse.transform(phase);
      expect(_scale(tester), closeTo(1.0 + 0.6 * eased, 1e-9));
      expect(find.byType(Opacity), findsOneWidget);
      expect(_opacity(tester), closeTo(1.0 - eased, 1e-9));
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('should run phase-delayed copies out of step', (tester) async {
      await pumpState(
        tester,
        Column(
          children: [
            _loop(scaleTo: 1.6, opacityTo: 0.0, curve: AppCurves.pulse),
            _loop(
              scaleTo: 1.6,
              opacityTo: 0.0,
              curve: AppCurves.pulse,
              phase: 0.5,
            ),
          ],
        ),
      );
      await tester.pump(tick);

      final opacities = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .toList();
      final first = opacities.first.opacity;
      final second = opacities.last.opacity;
      expect(first, closeTo(1.0 - AppCurves.pulse.transform(0.1), 1e-9));
      expect(second, closeTo(1.0 - AppCurves.pulse.transform(0.6), 1e-9));
    });

    testWidgets('should drive out and back in reverse mode', (tester) async {
      await pumpState(tester, _loop(scaleTo: 1.03, reverse: true));
      await tester.pump(tick);

      // Reverse mode pairs one leg with period ~/ 2; 120ms into a 600ms leg
      // puts the stereotype scale at 1 + 3% of 0.2.
      expect(_scale(tester), closeTo(1.0 + 0.03 * 0.2, 1e-9));
    });

    testWidgets('should bob the child by the translate range in reverse mode', (
      tester,
    ) async {
      await pumpState(
        tester,
        _loop(translateTo: const Offset(0.0, 0.01), reverse: true),
      );
      await tester.pump(tick);

      final translation = tester
          .widget<FractionalTranslation>(find.byType(FractionalTranslation))
          .translation;
      expect(translation.dy, closeTo(0.01 * 0.2, 1e-9));
      expect(translation.dx, 0.0);
    });

    testWidgets('should hand the raw phase to the phase builder', (
      tester,
    ) async {
      final phases = <double>[];
      await pumpState(
        tester,
        SizedBox.square(
          dimension: 100,
          child: IdleLoop(
            active: true,
            period: AppDurations.indeterminate,
            phaseBuilder: (context, phase, child) {
              phases.add(phase);
              return child;
            },
            child: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pump(tick);
      await tester.pump(tick);

      expect(phases, isNotEmpty);
      expect(phases.last, greaterThan(0.0));
      expect(phases.last, lessThan(1.0));
    });

    testWidgets('should freeze at the settled frame when inactive', (
      tester,
    ) async {
      await pumpState(
        tester,
        _loop(scaleTo: 1.6, opacityTo: 0.0, active: false),
      );
      await tester.pump(tick);

      expect(tester.hasRunningAnimations, isFalse);
      // The stopped loop holds phase 0: identity scale, which renders
      // without an opacity override.
      expect(_scale(tester), 1.0);
      expect(find.byType(Opacity), findsNothing);
    });

    testWidgets('should hold identity while a phase-delayed loop is stopped', (
      tester,
    ) async {
      await pumpState(
        tester,
        _loop(
          scaleTo: 1.6,
          opacityTo: 0.0,
          curve: AppCurves.pulse,
          phase: 0.5,
          active: false,
        ),
      );
      await tester.pump(tick);

      expect(tester.hasRunningAnimations, isFalse);
      expect(_scale(tester), 1.0);
      expect(find.byType(Opacity), findsNothing);
    });

    testWidgets('should hand the child back untouched when a raw-phase loop '
        'is stopped', (tester) async {
      var shaped = 0;
      await pumpState(
        tester,
        SizedBox.square(
          dimension: 100,
          child: IdleLoop(
            active: false,
            period: AppDurations.indeterminate,
            phaseBuilder: (context, phase, child) {
              shaped += 1;
              return Opacity(opacity: 0.4, child: child);
            },
            child: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pump(tick);

      expect(tester.hasRunningAnimations, isFalse);
      expect(shaped, 0);
      expect(find.byType(Opacity), findsNothing);
    });

    testWidgets('should stop when active turns false mid-loop', (tester) async {
      await pumpState(tester, _loop(scaleTo: 1.6, curve: AppCurves.pulse));
      await tester.pump(tick);
      await tester.pump(tick);
      expect(tester.hasRunningAnimations, isTrue);

      await pumpState(
        tester,
        _loop(scaleTo: 1.6, curve: AppCurves.pulse, active: false),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
      expect(_scale(tester), 1.0);
    });

    testWidgets('should never run when animations are disabled', (
      tester,
    ) async {
      await pumpState(
        tester,
        _loop(scaleTo: 1.6, opacityTo: 0.0, curve: AppCurves.pulse),
        disableAnimations: true,
      );
      await tester.pump(tick);

      expect(tester.hasRunningAnimations, isFalse);
      expect(_scale(tester), 1.0);
      expect(find.byType(Opacity), findsNothing);
    });
  });
}

Widget _loop({
  double scaleTo = 1.0,
  double opacityTo = 1.0,
  Curve? curve,
  double phase = 0.0,
  bool reverse = false,
  bool active = true,
  Offset translateTo = Offset.zero,
}) => SizedBox.square(
  dimension: 100,
  child: IdleLoop(
    active: active,
    period: AppDurations.indeterminate,
    scaleTo: scaleTo,
    opacityTo: opacityTo,
    translateTo: translateTo,
    curve: curve ?? AppCurves.linear,
    reverse: reverse,
    phase: phase,
    child: const SizedBox.expand(),
  ),
);

double _scale(WidgetTester tester) => tester
    .widgetList<Transform>(
      find.descendant(
        of: find.byType(IdleLoop),
        matching: find.byType(Transform),
      ),
    )
    .first
    .transform
    .storage[0];

double _opacity(WidgetTester tester) =>
    tester.widget<Opacity>(find.byType(Opacity)).opacity;
