import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/entrance/assembly_layer.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';

import 'harness.dart';

/// The test square every layer wraps; paint-space probes read through it.
const square = SizedBox.square(dimension: 100);

RenderBox squareBox(WidgetTester tester) => tester.renderObject<RenderBox>(
  find.descendant(
    of: find.byType(AssemblyLayer),
    matching: find.byWidgetPredicate((w) => w == square),
  ),
);

/// Maps a point of [square] through every wrapper transform of the layer.
Offset painted(WidgetTester tester, Offset local) =>
    squareBox(tester).localToGlobal(local);

void main() {
  const squareCenter = Offset(50, 50);
  const squareCorner = Offset(100, 100);
  const startDisplacement = Offset(0.0, 0.5);

  // The test window pins tight constraints on the root; an Align relaxes
  // them so the 100 square sizes itself and sits at the top-left corner.
  Widget inCorner(AssemblyLayer layer) =>
      Align(alignment: Alignment.topLeft, child: layer);

  group('AssemblyLayer', () {
    testWidgets('should hold the start displacement before the window begins', (
      tester,
    ) async {
      await pumpEntrance(
        tester,
        inCorner(
          AssemblyLayer(
            progress: 0.0,
            begin: 0.4,
            end: 0.8,
            from: startDisplacement,
            fromDegrees: 90,
            fromScale: 0.5,
            child: square,
          ),
        ),
      );

      expect(
        tester
            .widget<FractionalTranslation>(find.byType(FractionalTranslation))
            .translation,
        startDisplacement,
      );
      // Scale and rotation keep the pivot point; the displacement lifts it
      // by half the square.
      expect(painted(tester, squareCenter).dx, closeTo(50, 1e-7));
      expect(painted(tester, squareCenter).dy, closeTo(100, 1e-7));
      // The corner keeps its scaled reach from the center regardless of the
      // rotation direction.
      final reach = (painted(tester, squareCorner) - Offset(50, 100)).distance;
      expect(reach, closeTo(50 * 1.4142135623730951 / 2, 1e-6));
    });

    testWidgets('should settle to identity at the end of the window', (
      tester,
    ) async {
      await pumpEntrance(
        tester,
        inCorner(
          AssemblyLayer(
            progress: 0.8,
            begin: 0.4,
            end: 0.8,
            from: startDisplacement,
            fromDegrees: 90,
            fromScale: 0.5,
            child: square,
          ),
        ),
      );

      expect(
        tester
            .widget<FractionalTranslation>(find.byType(FractionalTranslation))
            .translation,
        Offset.zero,
      );
      expect(painted(tester, squareCenter), closeToPoint(const Offset(50, 50)));
      expect(
        painted(tester, squareCorner),
        closeToPoint(const Offset(100, 100)),
      );
    });

    testWidgets('should combine the uniform and vertical scales', (
      tester,
    ) async {
      const progress = 0.6;
      const begin = 0.4;
      const end = 0.8;
      final eased = AppCurves.enter.transform(
        (progress - begin) / (end - begin),
      );
      final uniform = 0.5 + 0.5 * eased;

      await pumpEntrance(
        tester,
        inCorner(
          AssemblyLayer(
            progress: progress,
            begin: begin,
            end: end,
            fromScale: 0.5,
            fromScaleY: 0.0,
            child: square,
          ),
        ),
      );

      final scales = tester
          .widgetList<Transform>(find.byType(Transform))
          .map((t) => t.transform)
          .whereType<Matrix4>()
          .toList();
      expect(scales, hasLength(2), reason: 'one scale node per axis');

      final corner = painted(tester, squareCorner);
      expect(corner.dx, closeTo(50 + 50 * uniform, 1e-6));
      expect(corner.dy, closeTo(50 + 50 * eased * uniform, 1e-6));
    });

    testWidgets('should ease the position with the spring when overshoot '
        'is set', (tester) async {
      const progress = 0.6;
      const begin = 0.4;
      const end = 0.8;
      final raw = (progress - begin) / (end - begin);
      final expected = 1.0 - AppCurves.spring.transform(raw);

      await pumpEntrance(
        tester,
        inCorner(
          AssemblyLayer(
            progress: progress,
            begin: begin,
            end: end,
            overshoot: true,
            from: const Offset(0.0, 0.5),
            child: square,
          ),
        ),
      );

      final translation = tester
          .widget<FractionalTranslation>(find.byType(FractionalTranslation))
          .translation;
      expect(translation.dx, closeTo(0.0, 1e-9));
      expect(translation.dy, closeTo(0.5 * expected, 1e-9));
    });

    testWidgets('should keep easing the position across the whole window', (
      tester,
    ) async {
      // The caller composites opacity separately; the transform itself
      // always spans begin..end.
      const progress = 0.55;
      const begin = 0.5;
      const end = 1.0;
      final eased = AppCurves.enter.transform(
        (progress - begin) / (end - begin),
      );

      await pumpEntrance(
        tester,
        inCorner(
          AssemblyLayer(
            progress: progress,
            begin: begin,
            end: end,
            from: const Offset(0.0, 0.5),
            child: square,
          ),
        ),
      );

      final translation = tester
          .widget<FractionalTranslation>(find.byType(FractionalTranslation))
          .translation;
      expect(translation.dy, closeTo(0.5 * (1.0 - eased), 1e-9));
    });

    testWidgets('should render a settled default layer as the bare child', (
      tester,
    ) async {
      await pumpEntrance(
        tester,
        inCorner(
          AssemblyLayer(progress: 1.0, begin: 0.0, end: 1.0, child: square),
        ),
      );

      expect(find.byType(FractionalTranslation), findsNothing);
      expect(find.byType(Transform), findsNothing);
    });
  });
}

Matcher closeToPoint(Offset expected) => _CloseToPoint(expected);

class _CloseToPoint extends Matcher {
  const _CloseToPoint(this.expected);

  final Offset expected;

  @override
  bool matches(Object? item, Map<Object?, Object?> matchState) =>
      item is Offset &&
      (item.dx - expected.dx).abs() < 1e-7 &&
      (item.dy - expected.dy).abs() < 1e-7;

  @override
  Description describe(Description description) =>
      description.add('within 1e-7 of $expected');
}
