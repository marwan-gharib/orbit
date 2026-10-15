import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  double offsetXOf(WidgetTester tester) => tester
      .widget<Transform>(find.byType(Transform))
      .transform
      .getTranslation()
      .x;

  Future<void> fireTrigger(WidgetTester tester, {int trigger = 1}) =>
      pumpFeedback(
        tester,
        ShakeWidget(trigger: trigger, child: const Text('payload')),
      );

  testWidgets(
    'should translate the child horizontally while shaking when the trigger increments',
    (tester) async {
      await fireTrigger(tester, trigger: 0);
      await fireTrigger(tester);

      await tester.pump(AppDurations.fast);

      expect(offsetXOf(tester), isNot(0.0));
      expect(
        offsetXOf(tester).abs(),
        lessThanOrEqualTo(AppAnimationConstants.shakeAmplitude),
      );
    },
  );

  testWidgets('should settle at zero offset when the shake completes', (
    tester,
  ) async {
    await fireTrigger(tester, trigger: 0);
    await fireTrigger(tester);

    await tester.pump(AppDurations.slow);

    expect(offsetXOf(tester), 0.0);
  });

  testWidgets('should kick toward the start edge when the text is LTR', (
    tester,
  ) async {
    await fireTrigger(tester, trigger: 0);
    await fireTrigger(tester);

    await tester.pump(AppDurations.fast);

    expect(offsetXOf(tester), lessThan(0.0));
  });

  testWidgets('should kick toward the start edge when the text is RTL', (
    tester,
  ) async {
    await pumpFeedback(
      tester,
      const ShakeWidget(child: Text('payload')),
      direction: TextDirection.rtl,
    );
    await pumpFeedback(
      tester,
      const ShakeWidget(trigger: 1, child: Text('payload')),
      direction: TextDirection.rtl,
    );

    await tester.pump(AppDurations.fast);

    expect(offsetXOf(tester), greaterThan(0.0));
  });

  testWidgets('should skip the motion when animations are disabled', (
    tester,
  ) async {
    await pumpFeedback(
      tester,
      const ShakeWidget(child: Text('payload')),
      disableAnimations: true,
    );
    await pumpFeedback(
      tester,
      const ShakeWidget(trigger: 1, child: Text('payload')),
      disableAnimations: true,
    );

    await tester.pump(AppDurations.fast);

    expect(offsetXOf(tester), 0.0);
  });

  testWidgets(
    'should fire the error haptic on trigger even when animations are disabled',
    (tester) async {
      final List<String?> calls = <String?>[];
      recordHapticCalls(tester, calls);
      await pumpFeedback(
        tester,
        const ShakeWidget(child: Text('payload')),
        disableAnimations: true,
      );

      await pumpFeedback(
        tester,
        const ShakeWidget(trigger: 1, haptic: true, child: Text('payload')),
        disableAnimations: true,
      );
      await tester.pump();

      expect(calls, contains(isNull)); // bare vibrate = AppHaptics.error()
    },
  );

  testWidgets('should shake when the controller fires', (tester) async {
    final shake = ShakeController();
    await pumpFeedback(
      tester,
      ShakeWidget(controller: shake, child: const Text('payload')),
    );

    shake.shake();
    await tester.pump(); // start frame: the ticker registers its first tick
    await tester.pump(AppDurations.fast);

    expect(offsetXOf(tester), isNot(0.0));
  });

  test('should not throw when shaken before a widget attaches', () {
    ShakeController().shake();
  });

  testWidgets('should dispose cleanly mid-shake', (tester) async {
    await fireTrigger(tester, trigger: 0);
    await fireTrigger(tester);
    await tester.pump(AppDurations.fast);

    await pumpFeedback(tester, const SizedBox());

    expect(tester.takeException(), isNull);
  });
}
