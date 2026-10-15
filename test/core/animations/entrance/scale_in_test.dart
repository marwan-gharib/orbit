import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  double scaleOf(WidgetTester tester) =>
      tester.widget<ScaleTransition>(find.byType(ScaleTransition)).scale.value;

  testWidgets('should zoom the child in from the token scale when built', (
    tester,
  ) async {
    await pumpEntrance(tester, const ScaleIn(child: Text('payload')));

    expect(scaleOf(tester), AppAnimationConstants.scaleInBegin);

    await tester.pump(AppDurations.slow);

    expect(scaleOf(tester), AppAnimationConstants.scaleInEnd);
    expect(find.text('payload'), findsOneWidget);
  });

  testWidgets('should hold the start scale until the delay has passed', (
    tester,
  ) async {
    await pumpEntrance(
      tester,
      const ScaleIn(delay: AppDurations.fast, child: Text('payload')),
    );

    await tester.pump(const Duration(milliseconds: 50));
    expect(scaleOf(tester), AppAnimationConstants.scaleInBegin);

    await tester.pump(AppDurations.slow);
    expect(scaleOf(tester), AppAnimationConstants.scaleInEnd);
  });

  testWidgets(
    'should render the final state immediately when animations are disabled',
    (tester) async {
      await pumpEntrance(
        tester,
        const ScaleIn(child: Text('payload')),
        disableAnimations: true,
      );

      expect(scaleOf(tester), AppAnimationConstants.scaleInEnd);
    },
  );
}
