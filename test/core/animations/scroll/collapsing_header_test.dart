import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

void main() {
  const backgroundKey = ValueKey<String>('collapsing-background');
  const expandedHeight = 240.0;

  double opacityOf(WidgetTester tester) => tester
      .widget<FadeTransition>(
        find
            .ancestor(
              of: find.byKey(backgroundKey),
              matching: find.byType(FadeTransition),
            )
            .first,
      )
      .opacity
      .value;

  double scaleXOf(WidgetTester tester) {
    final transform = tester.widget<Transform>(
      find
          .ancestor(
            of: find.byKey(backgroundKey),
            matching: find.byType(Transform),
          )
          .first,
    );
    return transform.transform.storage[0];
  }

  Widget subject(
    ScrollController controller, {
    bool disableAnimations = false,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(
          body: CustomScrollView(
            controller: controller,
            slivers: [
              CollapsingHeader(
                expandedHeight: expandedHeight,
                title: const Text('Sara Ahmed'),
                background: const ColoredBox(
                  key: backgroundKey,
                  color: Color(0xFF123456),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 2000)),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('should show the background fully opaque at the top', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(subject(controller));

    expect(opacityOf(tester), AppAnimationConstants.fadeOpacityEnd);
    expect(find.text('Sara Ahmed'), findsOneWidget);
  });

  testWidgets('should fade and zoom the background while collapsing', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(subject(controller));

    controller.jumpTo(expandedHeight / 2);
    await tester.pump();

    expect(opacityOf(tester), lessThan(AppAnimationConstants.fadeOpacityEnd));
    expect(
      opacityOf(tester),
      greaterThan(AppAnimationConstants.fadeOpacityBegin),
    );
    expect(scaleXOf(tester), greaterThan(1.0));
  });

  testWidgets('should fade the background out when fully collapsed', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(subject(controller));

    controller.jumpTo(2000);
    await tester.pump();

    expect(opacityOf(tester), AppAnimationConstants.fadeOpacityBegin);
  });

  testWidgets(
    'should keep the scroll-linked collapse with animations disabled',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(subject(controller, disableAnimations: true));

      controller.jumpTo(expandedHeight / 2);
      await tester.pump();

      expect(opacityOf(tester), lessThan(AppAnimationConstants.fadeOpacityEnd));
    },
  );

  testWidgets('should build inside a CustomScrollView without exceptions', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(subject(controller));

    controller.jumpTo(2000);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
