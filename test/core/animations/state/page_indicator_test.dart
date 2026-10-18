import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/state/page_indicator.dart';

import 'harness.dart';

void main() {
  Widget indicator({
    int current = 0,
    int count = 4,
    ValueChanged<int>? onTap,
  }) => SizedBox(
    width: 600,
    height: 72,
    child: PageIndicator(
      currentIndex: current,
      pageCount: count,
      onTap: onTap ?? (_) {},
      semanticsLabel: (current, total) => 'Page $current of $total',
      dotSize: 8.0,
      dotSpacing: 4.0,
      tapBoxHeight: 48.0,
    ),
  );

  group('PageIndicator', () {
    testWidgets('should render one a11y node per dot', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpState(tester, indicator(current: 1));

      expect(find.bySemanticsLabel('Page 1 of 4'), findsOneWidget);
      expect(find.bySemanticsLabel('Page 2 of 4'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('should report the tapped dot index', (tester) async {
      final tapped = <int>[];
      await pumpState(tester, indicator(current: 0, onTap: tapped.add));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey(1)));
      expect(tapped, [1]);
    });

    testWidgets('should grow the active dot into the pill targeted by the '
        'factor token', (tester) async {
      await pumpState(tester, indicator(current: 1));
      await tester.pumpAndSettle();

      final targetWidth = tester
          .getSize(
            find
                .descendant(
                  of: find.byKey(const ValueKey(1)),
                  matching: find.byType(AnimatedContainer),
                )
                .first,
          )
          .width;
      expect(targetWidth, closeTo(8.0 * 3.0, 1e-9));

      final restingWidth = tester
          .getSize(
            find
                .descendant(
                  of: find.byKey(const ValueKey(0)),
                  matching: find.byType(AnimatedContainer),
                )
                .first,
          )
          .width;
      expect(restingWidth, closeTo(8.0, 1e-9));
    });

    testWidgets('should keep the dot tap box band fixed at the tap height', (
      tester,
    ) async {
      // Advance so dot 0 rests and reads as a plain dot.
      await pumpState(tester, indicator(current: 1));
      await tester.pumpAndSettle();

      final rect = tester.getRect(find.byKey(const ValueKey(0)));
      expect(rect.height, 48.0);
      expect(rect.width, closeTo(8.0 + 2 * 4.0, 1e-9));
    });

    testWidgets('should order dots by reading direction', (tester) async {
      await pumpState(tester, indicator(), direction: TextDirection.ltr);
      final ltrStart = tester.getRect(find.byKey(const ValueKey(0))).left;
      final ltrEnd = tester.getRect(find.byKey(const ValueKey(3))).left;
      expect(ltrStart, lessThan(ltrEnd));

      await pumpState(tester, indicator(), direction: TextDirection.rtl);
      final rtlStart = tester.getRect(find.byKey(const ValueKey(0))).left;
      final rtlEnd = tester.getRect(find.byKey(const ValueKey(3))).left;
      expect(rtlStart, greaterThan(rtlEnd));
    });

    testWidgets('should jump instantly when animations are disabled', (
      tester,
    ) async {
      await pumpState(tester, indicator(current: 0), disableAnimations: true);
      await pumpState(tester, indicator(current: 1), disableAnimations: true);
      await tester.pump();

      // The active dot was already settled into on the disabled harness.
      final targetWidth = tester
          .getSize(
            find
                .descendant(
                  of: find.byKey(const ValueKey(1)),
                  matching: find.byType(AnimatedContainer),
                )
                .first,
          )
          .width;
      expect(targetWidth, closeTo(8.0 * 3.0, 1e-9));
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
