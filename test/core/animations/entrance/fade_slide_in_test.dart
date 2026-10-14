import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  double opacityOf(WidgetTester tester) =>
      tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity.value;

  Offset positionOf(WidgetTester tester) => tester
      .widget<SlideTransition>(find.byType(SlideTransition))
      .position
      .value;

  testWidgets('should fade and slide the child in when built', (tester) async {
    await pumpEntrance(tester, const FadeSlideIn(child: Text('payload')));

    expect(opacityOf(tester), AppAnimationConstants.fadeOpacityBegin);
    expect(positionOf(tester).dy, greaterThan(0.0));

    await tester.pump(AppDurations.slow);

    expect(opacityOf(tester), AppAnimationConstants.fadeOpacityEnd);
    expect(positionOf(tester), Offset.zero);
    expect(find.text('payload'), findsOneWidget);
  });

  testWidgets('should hold both effects until the delay has passed', (
    tester,
  ) async {
    await pumpEntrance(
      tester,
      const FadeSlideIn(delay: AppDurations.fast, child: Text('payload')),
    );

    await tester.pump(const Duration(milliseconds: 50));
    expect(opacityOf(tester), AppAnimationConstants.fadeOpacityBegin);
    expect(positionOf(tester).dy, greaterThan(0.0));

    await tester.pump(AppDurations.slow);
    expect(opacityOf(tester), AppAnimationConstants.fadeOpacityEnd);
    expect(positionOf(tester), Offset.zero);
  });

  testWidgets(
    'should render the final state immediately when animations are disabled',
    (tester) async {
      await pumpEntrance(
        tester,
        const FadeSlideIn(child: Text('payload')),
        disableAnimations: true,
      );

      expect(opacityOf(tester), AppAnimationConstants.fadeOpacityEnd);
      expect(positionOf(tester), Offset.zero);
    },
  );
}
