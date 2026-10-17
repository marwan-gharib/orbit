import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/entrance/clip_reveal.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';

import 'harness.dart';

/// A 480x480 framed probe so clip fractions map to exact pixel widths.
Widget probe(double progress) => SizedBox(
  width: 480,
  height: 480,
  child: ClipReveal(
    progress: progress,
    begin: 0.5,
    end: 0.85,
    fromX: 0.13,
    toX: 0.87,
    child: const ColoredBox(color: Color(0xFFFFFFFF), child: SizedBox.expand()),
  ),
);

CustomClipper<Rect> clipperOf(WidgetTester tester) => tester
    .widget<ClipRect>(
      find.descendant(
        of: find.byType(ClipReveal),
        matching: find.byType(ClipRect),
      ),
    )
    .clipper!;

void main() {
  group('ClipReveal', () {
    testWidgets('should keep the child clipped to the start edge before the '
        'window', (tester) async {
      await pumpEntrance(
        tester,
        SizedBox(width: 480, height: 480, child: probe(0.0)),
      );

      final rect = clipperOf(tester).getClip(const Size.square(480));
      expect(rect.left, 0.0);
      expect(rect.width, closeTo(0.13 * 480, 1e-9));
      expect(rect.height, 480);
    });

    testWidgets('should ease inside the window and reveal fully afterwards', (
      tester,
    ) async {
      await pumpEntrance(
        tester,
        SizedBox(width: 480, height: 480, child: probe(0.675)),
      );

      final eased = AppCurves.enter.transform((0.675 - 0.5) / 0.35);
      final midRect = clipperOf(tester).getClip(const Size.square(480));
      expect(midRect.width, closeTo((0.13 + 0.74 * eased) * 480, 1e-9));

      await pumpEntrance(
        tester,
        SizedBox(width: 480, height: 480, child: probe(1.0)),
      );
      // The band ends at toX once the sweep completes; the artwork's ink
      // lives inside [fromX, toX], so nothing visible is lost.
      final settledRect = clipperOf(tester).getClip(const Size.square(480));
      expect(settledRect.left, 0.0);
      expect(settledRect.width, closeTo(0.87 * 480, 1e-9));
      expect(settledRect.height, 480);
    });
  });
}
