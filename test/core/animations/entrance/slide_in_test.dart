import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  Offset positionOf(WidgetTester tester) => tester
      .widget<SlideTransition>(find.byType(SlideTransition))
      .position
      .value;

  testWidgets(
    'should slide the child in from the start edge when direction is ltr',
    (tester) async {
      await pumpEntrance(
        tester,
        const SlideIn.fromStart(child: Text('payload')),
      );

      expect(positionOf(tester).dx, lessThan(0.0));

      await tester.pump(AppDurations.slow);

      expect(positionOf(tester), Offset.zero);
      expect(find.text('payload'), findsOneWidget);
    },
  );

  testWidgets(
    'should slide the child in from the end edge when direction is rtl',
    (tester) async {
      await pumpEntrance(
        tester,
        const SlideIn.fromStart(child: Text('payload')),
        direction: TextDirection.rtl,
      );

      expect(positionOf(tester).dx, greaterThan(0.0));
    },
  );

  testWidgets('should honor a custom offset when one is provided', (
    tester,
  ) async {
    await pumpEntrance(
      tester,
      const SlideIn.fromTop(offset: Offset(0.0, -0.5), child: Text('payload')),
    );

    expect(positionOf(tester).dy, -0.5);
  });

  testWidgets(
    'should render the final state immediately when animations are disabled',
    (tester) async {
      await pumpEntrance(
        tester,
        const SlideIn.fromBottom(child: Text('payload')),
        disableAnimations: true,
      );

      expect(positionOf(tester), Offset.zero);
    },
  );
}
