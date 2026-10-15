import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  double opacityOf(WidgetTester tester) => tester
      .widget<FadeTransition>(
        find.descendant(
          of: find.byType(RevealOnScroll),
          matching: find.byType(FadeTransition),
        ),
      )
      .opacity
      .value;

  Widget singleColumn(ScrollController controller, Widget child) =>
      SingleChildScrollView(
        controller: controller,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [SizedBox(height: 1000), child],
        ),
      );

  testWidgets('should reveal the child when it starts inside the viewport', (
    tester,
  ) async {
    await pumpScroll(
      tester,
      Column(
        children: const [
          SizedBox(height: 100),
          RevealOnScroll(child: Text('payload')),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(opacityOf(tester), AppAnimationConstants.fadeOpacityEnd);
    expect(find.text('payload'), findsOneWidget);
  });

  testWidgets('should keep the child hidden while it is outside the viewport', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpScroll(
      tester,
      singleColumn(controller, const RevealOnScroll(child: Text('payload'))),
    );

    expect(opacityOf(tester), AppAnimationConstants.fadeOpacityBegin);
  });

  testWidgets('should reveal the child when it scrolls into the viewport', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpScroll(
      tester,
      singleColumn(controller, const RevealOnScroll(child: Text('payload'))),
    );
    expect(opacityOf(tester), AppAnimationConstants.fadeOpacityBegin);

    controller.jumpTo(600);
    await tester.pump();
    await tester.pump(AppDurations.slow);

    expect(opacityOf(tester), AppAnimationConstants.fadeOpacityEnd);
  });

  testWidgets('should not replay when the child scrolls away and back', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpScroll(
      tester,
      singleColumn(controller, const RevealOnScroll(child: Text('payload'))),
    );

    controller.jumpTo(600);
    await tester.pump();
    await tester.pump(AppDurations.slow);
    expect(opacityOf(tester), AppAnimationConstants.fadeOpacityEnd);

    controller.jumpTo(0);
    await tester.pump();
    controller.jumpTo(600);
    await tester.pump();

    expect(opacityOf(tester), AppAnimationConstants.fadeOpacityEnd);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'should render the final state immediately when animations are disabled',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpScroll(
        tester,
        singleColumn(controller, const RevealOnScroll(child: Text('payload'))),
        disableAnimations: true,
      );

      expect(opacityOf(tester), AppAnimationConstants.fadeOpacityEnd);
    },
  );

  testWidgets('should dispose cleanly when removed before the reveal', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpScroll(
      tester,
      singleColumn(controller, const RevealOnScroll(child: Text('payload'))),
    );

    await pumpScroll(tester, const SizedBox());

    expect(tester.takeException(), isNull);
  });
}
