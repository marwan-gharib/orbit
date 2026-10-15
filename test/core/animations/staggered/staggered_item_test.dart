import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import '../entrance/harness.dart';

void main() {
  double opacityOf(WidgetTester tester) =>
      tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity.value;

  testWidgets(
    'should delay the entrance by index times stagger when the index is within the cap',
    (tester) async {
      await pumpEntrance(
        tester,
        const StaggeredItem(index: 2, child: Text('payload')),
      );

      await tester.pump(const Duration(milliseconds: 50));
      expect(opacityOf(tester), AppAnimationConstants.fadeOpacityBegin);

      await tester.pump(AppDurations.slow);
      expect(opacityOf(tester), AppAnimationConstants.fadeOpacityEnd);
    },
  );

  testWidgets(
    'should render the child immediately when the index is past the cap',
    (tester) async {
      await pumpEntrance(
        tester,
        const StaggeredItem(
          index: AppAnimationConstants.maxStaggerIndex + 1,
          child: Text('payload'),
        ),
      );

      expect(find.byType(FadeSlideIn), findsNothing);
      expect(find.text('payload'), findsOneWidget);
    },
  );

  testWidgets(
    'should render the final state immediately when animations are disabled',
    (tester) async {
      await pumpEntrance(
        tester,
        const StaggeredItem(index: 3, child: Text('payload')),
        disableAnimations: true,
      );

      expect(opacityOf(tester), AppAnimationConstants.fadeOpacityEnd);
    },
  );

  testWidgets('should not restart the entrance when the widget rebuilds', (
    tester,
  ) async {
    Widget build() => const StaggeredItem(index: 4, child: Text('payload'));

    await pumpEntrance(tester, build());
    await tester.pump(const Duration(milliseconds: 250));
    final midway = opacityOf(tester);
    expect(midway, greaterThan(0.0));
    expect(midway, lessThan(1.0));

    await pumpEntrance(tester, build());

    expect(opacityOf(tester), closeTo(midway, 0.0001));
  });
}
