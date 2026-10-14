import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  const factor = 0.5;

  Offset offsetOf(WidgetTester tester) {
    final transform = tester.widget<Transform>(
      find
          .descendant(
            of: find.byType(ParallaxWidget),
            matching: find.byType(Transform),
          )
          .first,
    );
    final translation = transform.transform.getTranslation();
    return Offset(translation.x, translation.y);
  }

  Widget verticalList(ScrollController controller) => ListView(
    controller: controller,
    children: [
      SizedBox(
        height: 200,
        child: Stack(
          children: [
            ParallaxWidget(
              parallaxFactor: factor,
              child: const ColoredBox(color: Color(0xFF123456)),
            ),
            const Text('tile'),
          ],
        ),
      ),
      const SizedBox(height: 1000),
    ],
  );

  Widget horizontalList(ScrollController controller) => ListView(
    scrollDirection: Axis.horizontal,
    controller: controller,
    children: [
      SizedBox(
        width: 200,
        child: Stack(
          children: [
            ParallaxWidget(
              parallaxFactor: factor,
              child: const ColoredBox(color: Color(0xFF123456)),
            ),
            const Text('tile'),
          ],
        ),
      ),
      const SizedBox(width: 1000),
    ],
  );

  testWidgets(
    'should offset the background by the parallax factor as the view scrolls',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpScroll(tester, verticalList(controller));
      await tester.pump();

      // Viewport 600, tile 200: offset = factor * (distance - h + V / 2).
      expect(offsetOf(tester), const Offset(0, 50));
      expect(find.byType(OverflowBox), findsOneWidget);

      // Half a tile keeps the tile mounted (a full tile-height would recycle
      // it out of the list, which is also fine — a fresh mount recomputes).
      controller.jumpTo(100);
      await tester.pump();
      // Geometry is only fresh once the scrollable has re-laid out.
      await tester.pump();

      expect(offsetOf(tester), const Offset(0, 100));
    },
  );

  testWidgets('should mirror the offset when the direction is RTL', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpScroll(
      tester,
      horizontalList(controller),
      direction: TextDirection.rtl,
    );
    await tester.pump();

    // Viewport 800 wide, tile 200: at rest the tile sits at the start edge,
    // so offset = factor * (V / 2 - h) = 200, pointing away from the start
    // edge. In RTL the start edge is on the right, so it points the other
    // way than in LTR.
    expect(offsetOf(tester), const Offset(-200, 0));
  });

  testWidgets('should offset toward the trailing edge in LTR horizontal', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpScroll(tester, horizontalList(controller));
    await tester.pump();

    expect(offsetOf(tester), const Offset(200, 0));
  });

  testWidgets('should render the child untransformed without a scrollable', (
    tester,
  ) async {
    await pumpScroll(
      tester,
      const Column(
        children: [ParallaxWidget(child: SizedBox(width: 100, height: 100))],
      ),
    );

    expect(find.byType(Transform), findsNothing);
    expect(find.byType(OverflowBox), findsNothing);
  });

  testWidgets(
    'should render the child without offset when animations are disabled',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpScroll(
        tester,
        verticalList(controller),
        disableAnimations: true,
      );
      await tester.pump();

      expect(find.byType(Transform), findsNothing);
    },
  );
}
