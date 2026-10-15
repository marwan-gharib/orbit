import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  PhysicalModel barOf(WidgetTester tester) => tester.widget<PhysicalModel>(
    find
        .descendant(
          of: find.byType(FadeOnScrollBar),
          matching: find.byType(PhysicalModel),
        )
        .first,
  );

  Widget bar() => FadeOnScrollBar(
    backgroundColor: const Color(0xFF123456),
    child: const SizedBox(height: 56, child: Text('bar')),
  );

  Widget listWithController(ScrollController controller) => ListView(
    controller: controller,
    children: const [SizedBox(height: 1500)],
  );

  testWidgets('should keep the bar transparent at the top of the view', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpScroll(
      tester,
      Stack(
        children: [
          listWithController(controller),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBarFadeOnScroll(
              scrollController: controller,
              child: bar(),
            ),
          ),
        ],
      ),
    );

    expect(barOf(tester).elevation, AppAnimationConstants.fadeOpacityBegin);
    expect(barOf(tester).color.a, moreOrLessEquals(0.0));
  });

  testWidgets('should fade the background and raise the elevation mid-scroll', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpScroll(
      tester,
      Stack(
        children: [
          listWithController(controller),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBarFadeOnScroll(
              scrollController: controller,
              child: bar(),
            ),
          ),
        ],
      ),
    );

    controller.jumpTo(AppAnimationConstants.appBarFadeThreshold / 2);
    await tester.pump();

    expect(
      barOf(tester).elevation,
      moreOrLessEquals(AppAnimationConstants.appBarFadeElevation / 2),
    );
    expect(barOf(tester).color.a, moreOrLessEquals(0.5));
  });

  testWidgets('should clamp the fade once the threshold is passed', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpScroll(
      tester,
      Stack(
        children: [
          listWithController(controller),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBarFadeOnScroll(
              scrollController: controller,
              child: bar(),
            ),
          ),
        ],
      ),
    );

    controller.jumpTo(AppAnimationConstants.appBarFadeThreshold * 2);
    await tester.pump();

    expect(
      barOf(tester).elevation,
      moreOrLessEquals(AppAnimationConstants.appBarFadeElevation),
    );
    expect(barOf(tester).color.a, moreOrLessEquals(1.0));
  });

  testWidgets(
    'should follow scroll notifications when no controller is given',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpScroll(
        tester,
        AppBarFadeOnScroll(
          child: Stack(
            children: [
              listWithController(controller),
              Positioned(top: 0, left: 0, right: 0, child: bar()),
            ],
          ),
        ),
      );

      controller.jumpTo(AppAnimationConstants.appBarFadeThreshold);
      await tester.pump();

      expect(barOf(tester).color.a, moreOrLessEquals(1.0));
    },
  );

  testWidgets(
    'should render the final state immediately when animations are disabled',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpScroll(
        tester,
        Stack(
          children: [
            listWithController(controller),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBarFadeOnScroll(
                scrollController: controller,
                child: bar(),
              ),
            ),
          ],
        ),
        disableAnimations: true,
      );

      expect(
        barOf(tester).elevation,
        moreOrLessEquals(AppAnimationConstants.appBarFadeElevation),
      );
      expect(barOf(tester).color.a, moreOrLessEquals(1.0));
    },
  );

  testWidgets('should render fully opaque without an ancestor provider', (
    tester,
  ) async {
    await pumpScroll(
      tester,
      const FadeOnScrollBar(
        backgroundColor: Color(0xFF123456),
        child: SizedBox(width: 200, height: 56),
      ),
    );

    expect(
      barOf(tester).elevation,
      moreOrLessEquals(AppAnimationConstants.appBarFadeElevation),
    );
    expect(barOf(tester).color.a, moreOrLessEquals(1.0));
  });
}
