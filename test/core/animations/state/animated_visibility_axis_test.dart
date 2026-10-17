import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/state/animated_visibility.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';

import 'harness.dart';

void main() {
  final halfDuration = AppDurations.normal ~/ 2;
  const payload = SizedBox.square(
    dimension: 200,
    child: ColoredBox(color: Color(0xFF0000FF)),
  );
  Widget shown({Axis axis = Axis.vertical}) =>
      AnimatedVisibility(visible: true, axis: axis, child: payload);
  Widget hidden({Axis axis = Axis.vertical, bool collapseSize = true}) =>
      AnimatedVisibility(
        visible: false,
        axis: axis,
        collapseSize: collapseSize,
        child: payload,
      );

  group('AnimatedVisibility horizontal axis', () {
    testWidgets('should collapse the width anchored to the LTR start edge', (
      tester,
    ) async {
      // Loose width so the animated alignment can shrink; the cross axis is
      // pinned by the wrapper.
      await pumpState(
        tester,
        Center(
          child: SizedBox(height: 300, child: shown(axis: Axis.horizontal)),
        ),
      );
      await pumpState(
        tester,
        Center(
          child: SizedBox(height: 300, child: hidden(axis: Axis.horizontal)),
        ),
      );

      await tester.pump(halfDuration);
      final alignRect = tester.getRect(find.byType(SizeTransition));
      expect(alignRect.width, lessThan(200));
      expect(alignRect.width, greaterThan(0));
      expect(
        tester.getRect(find.byWidget(payload)).left,
        alignRect.left,
        reason: 'the visible remainder hugs the start edge (left in LTR)',
      );

      await tester.pumpAndSettle();
      // Hidden without maintainState: the subtree leaves the tree.
      expect(find.byType(SizeTransition), findsNothing);
      expect(find.byWidget(payload), findsNothing);
    });

    testWidgets('should collapse the width anchored to the RTL start edge', (
      tester,
    ) async {
      await pumpState(
        tester,
        Center(
          child: SizedBox(height: 300, child: shown(axis: Axis.horizontal)),
        ),
      );
      await pumpState(
        tester,
        Center(
          child: SizedBox(height: 300, child: hidden(axis: Axis.horizontal)),
        ),
        direction: TextDirection.rtl,
      );

      await tester.pump(halfDuration);
      final alignRect = tester.getRect(find.byType(SizeTransition));
      expect(alignRect.width, lessThan(200));
      expect(
        tester.getRect(find.byWidget(payload)).right,
        alignRect.right,
        reason: 'in RTL the start edge is the right side',
      );
      await tester.pumpAndSettle();
      expect(find.byType(SizeTransition), findsNothing);
      expect(find.byWidget(payload), findsNothing);
    });

    testWidgets('should keep vertical behavior on the default axis', (
      tester,
    ) async {
      await pumpState(
        tester,
        Center(child: SizedBox(width: 300, child: shown())),
      );
      await pumpState(
        tester,
        Center(child: SizedBox(width: 300, child: hidden())),
      );

      await tester.pump(halfDuration);
      expect(tester.getRect(find.byType(SizeTransition)).height, lessThan(200));
      await tester.pumpAndSettle();
      expect(find.byType(SizeTransition), findsNothing);
      expect(find.byWidget(payload), findsNothing);
    });

    testWidgets('should keep the full size while fading when collapseSize is '
        'false', (tester) async {
      await pumpState(tester, Center(child: shown()));
      await pumpState(tester, Center(child: hidden(collapseSize: false)));

      await tester.pump(halfDuration);
      final size = tester.getSize(find.byType(FadeTransition));
      expect(size.height, 200, reason: 'no size animation plays');
      expect(size.width, 200);

      final opacity = tester
          .widget<FadeTransition>(find.byType(FadeTransition))
          .opacity
          .value;
      expect(opacity, lessThan(1.0));

      await tester.pumpAndSettle();
      expect(find.byType(SizeTransition), findsNothing);
      expect(find.byWidget(payload), findsNothing);
    });

    testWidgets('should ride the slide and scale options', (tester) async {
      Widget driven(bool visible) => Center(
        child: SizedBox(
          height: 100,
          child: AnimatedVisibility(
            visible: visible,
            offset: const Offset(0.4, 0.0),
            scaleBegin: 0.85,
            child: payload,
          ),
        ),
      );

      await pumpState(tester, driven(false));
      await pumpState(tester, driven(true));

      await tester.pump(halfDuration);
      final eased = AppCurves.standard.transform(0.5);
      final position = tester
          .widget<SlideTransition>(find.byType(SlideTransition))
          .position
          .value;
      expect(position.dx, closeTo(0.4 * (1 - eased), 1e-9));
      expect(position.dy, 0.0);
      expect(
        tester
            .widget<ScaleTransition>(find.byType(ScaleTransition))
            .scale
            .value,
        closeTo(0.85 + 0.15 * eased, 1e-9),
      );

      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SlideTransition>(find.byType(SlideTransition))
            .position
            .value,
        Offset.zero,
      );
    });

    testWidgets('should ease the hide leg with the reverse curve', (
      tester,
    ) async {
      Widget toggle(bool visible) => Center(
        child: AnimatedVisibility(
          visible: visible,
          curve: AppCurves.enter,
          reverseCurve: AppCurves.exit,
          child: payload,
        ),
      );

      await pumpState(tester, toggle(true));
      await pumpState(tester, toggle(false));

      await tester.pump(halfDuration);
      expect(
        tester
            .widget<FadeTransition>(find.byType(FadeTransition))
            .opacity
            .value,
        closeTo(AppCurves.exit.transform(0.5), 1e-9),
        reason: 'the hide leg applies the reverse curve to the same timeline',
      );
    });

    testWidgets('should jump the extended options when animations are '
        'disabled', (tester) async {
      Widget toggle(bool visible) => Center(
        child: SizedBox(
          height: 300,
          child: AnimatedVisibility(
            visible: visible,
            axis: Axis.horizontal,
            offset: const Offset(0.4, 0.0),
            scaleBegin: 0.85,
            child: payload,
          ),
        ),
      );

      await pumpState(tester, toggle(false), disableAnimations: true);
      await pumpState(tester, toggle(true), disableAnimations: true);

      expect(tester.hasRunningAnimations, isFalse);
      expect(tester.getSize(find.byType(SizeTransition)).width, 200);
      expect(
        tester
            .widget<SlideTransition>(find.byType(SlideTransition))
            .position
            .value,
        Offset.zero,
      );
      expect(
        tester
            .widget<ScaleTransition>(find.byType(ScaleTransition))
            .scale
            .value,
        1.0,
      );
    });
  });
}
