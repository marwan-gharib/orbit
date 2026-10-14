import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  double scaleOf(WidgetTester tester) =>
      tester.widget<ScaleTransition>(find.byType(ScaleTransition)).scale.value;

  Future<void> fireTrigger(WidgetTester tester, {int trigger = 1}) =>
      pumpFeedback(
        tester,
        BounceWidget(trigger: trigger, child: const Text('payload')),
      );

  testWidgets('should scale past rest when the trigger increments', (
    tester,
  ) async {
    await fireTrigger(tester, trigger: 0);
    await fireTrigger(tester);

    await tester.pump(AppDurations.fast);

    expect(scaleOf(tester), greaterThan(1.0));
  });

  testWidgets('should rest at scale one when the bounce completes', (
    tester,
  ) async {
    await fireTrigger(tester, trigger: 0);
    await fireTrigger(tester);

    await tester.pump(AppDurations.slow);

    expect(scaleOf(tester), 1.0);
  });

  testWidgets('should skip the motion when animations are disabled', (
    tester,
  ) async {
    await pumpFeedback(
      tester,
      const BounceWidget(child: Text('payload')),
      disableAnimations: true,
    );
    await pumpFeedback(
      tester,
      const BounceWidget(trigger: 1, child: Text('payload')),
      disableAnimations: true,
    );

    await tester.pump(AppDurations.fast);

    expect(scaleOf(tester), 1.0);
  });

  testWidgets('should bounce when the controller fires', (tester) async {
    final bounce = BounceController();
    await pumpFeedback(
      tester,
      BounceWidget(controller: bounce, child: const Text('payload')),
    );

    bounce.bounce();
    await tester.pump(); // start frame: the ticker registers its first tick
    await tester.pump(AppDurations.fast);

    expect(scaleOf(tester), greaterThan(1.0));
  });

  test('should not throw when bounced before a widget attaches', () {
    BounceController().bounce();
  });

  testWidgets('should dispose cleanly mid-bounce', (tester) async {
    await fireTrigger(tester, trigger: 0);
    await fireTrigger(tester);
    await tester.pump(AppDurations.fast);

    await pumpFeedback(tester, const SizedBox());

    expect(tester.takeException(), isNull);
  });
}
