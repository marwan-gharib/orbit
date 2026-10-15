import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  double opacityOf(WidgetTester tester) =>
      tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity.value;

  testWidgets(
    'should fade the child in from transparent to opaque when built',
    (tester) async {
      await pumpEntrance(tester, const FadeIn(child: Text('payload')));

      expect(opacityOf(tester), AppAnimationConstants.fadeOpacityBegin);

      await tester.pump(AppDurations.slow);

      expect(opacityOf(tester), AppAnimationConstants.fadeOpacityEnd);
      expect(find.text('payload'), findsOneWidget);
    },
  );

  testWidgets('should hold the child transparent until the delay has passed', (
    tester,
  ) async {
    await pumpEntrance(
      tester,
      const FadeIn(
        delay: AppDurations.fast,
        duration: AppDurations.fast,
        child: Text('payload'),
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));
    expect(opacityOf(tester), AppAnimationConstants.fadeOpacityBegin);

    await tester.pump(AppDurations.slow);
    expect(opacityOf(tester), AppAnimationConstants.fadeOpacityEnd);
  });

  testWidgets(
    'should render the final state immediately when animations are disabled',
    (tester) async {
      await pumpEntrance(
        tester,
        const FadeIn(child: Text('payload')),
        disableAnimations: true,
      );

      expect(opacityOf(tester), AppAnimationConstants.fadeOpacityEnd);
    },
  );

  testWidgets('should not restart when the widget rebuilds', (tester) async {
    await pumpEntrance(tester, const FadeIn(child: Text('payload')));
    await tester.pump(const Duration(milliseconds: 150));
    final midway = opacityOf(tester);
    expect(midway, greaterThan(0.0));

    await pumpEntrance(tester, const FadeIn(child: Text('payload')));

    expect(opacityOf(tester), closeTo(midway, 0.0001));
  });

  testWidgets('should dispose cleanly when removed before the delay elapses', (
    tester,
  ) async {
    await pumpEntrance(
      tester,
      const FadeIn(delay: Duration(seconds: 10), child: Text('payload')),
    );

    await pumpEntrance(tester, const SizedBox());

    expect(tester.takeException(), isNull);
  });
}
