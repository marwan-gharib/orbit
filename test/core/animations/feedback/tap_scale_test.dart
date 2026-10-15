import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  double scaleOf(WidgetTester tester) =>
      tester.widget<ScaleTransition>(find.byType(ScaleTransition)).scale.value;

  Future<TestGesture> pressAtCenter(WidgetTester tester) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(TapScale)),
    );
    await tester.pump();
    return gesture;
  }

  testWidgets('should scale the child down to the token while pressed', (
    tester,
  ) async {
    await pumpFeedback(tester, const TapScale(child: Text('payload')));
    final gesture = await pressAtCenter(tester);

    await tester.pump(AppDurations.fast);

    expect(scaleOf(tester), AppAnimationConstants.tapScale);
    await gesture.up();
  });

  testWidgets('should spring back to rest when the pointer is released', (
    tester,
  ) async {
    await pumpFeedback(tester, const TapScale(child: Text('payload')));
    final gesture = await pressAtCenter(tester);
    await tester.pump(AppDurations.fast);

    await gesture.up();
    await tester.pump();
    await tester.pump(AppDurations.fast);

    expect(scaleOf(tester), 1.0);
  });

  testWidgets('should call onTap when the child is tapped', (tester) async {
    var taps = 0;
    await pumpFeedback(
      tester,
      TapScale(onTap: () => taps++, child: const Text('payload')),
    );

    await tester.tap(find.byType(TapScale));

    expect(taps, 1);
  });

  testWidgets('should call onLongPress when the child is long pressed', (
    tester,
  ) async {
    var longPresses = 0;
    await pumpFeedback(
      tester,
      TapScale(onLongPress: () => longPresses++, child: const Text('payload')),
    );

    final gesture = await pressAtCenter(tester);
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.up();
    await tester.pump();

    expect(longPresses, 1);
  });

  testWidgets('should not scale when disabled', (tester) async {
    await pumpFeedback(
      tester,
      const TapScale(enabled: false, child: Text('payload')),
    );
    final gesture = await pressAtCenter(tester);

    await tester.pump(AppDurations.fast);

    expect(scaleOf(tester), 1.0);
    await gesture.up();
  });

  testWidgets('should not fire callbacks when disabled', (tester) async {
    var taps = 0;
    await pumpFeedback(
      tester,
      TapScale(
        enabled: false,
        onTap: () => taps++,
        child: const Text('payload'),
      ),
    );

    await tester.tap(find.byType(TapScale));

    expect(taps, 0);
  });

  testWidgets(
    'should apply the pressed state immediately when animations are disabled',
    (tester) async {
      await pumpFeedback(
        tester,
        const TapScale(child: Text('payload')),
        disableAnimations: true,
      );
      final gesture = await pressAtCenter(tester);

      expect(scaleOf(tester), AppAnimationConstants.tapScale);

      await gesture.up();
      await tester.pump();

      expect(scaleOf(tester), 1.0);
    },
  );

  testWidgets('should expose a button role when onTap is set', (tester) async {
    final handle = tester.ensureSemantics();

    await pumpFeedback(
      tester,
      TapScale(onTap: () {}, child: const Text('payload')),
    );

    expect(
      tester.getSemantics(find.byType(TapScale)).flagsCollection.isButton,
      isTrue,
    );
    handle.dispose();
  });

  testWidgets('should not expose a button role when onTap is unset', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await pumpFeedback(tester, const TapScale(child: Text('payload')));

    expect(
      tester.getSemantics(find.byType(TapScale)).flagsCollection.isButton,
      isFalse,
    );
    handle.dispose();
  });

  testWidgets('should play the requested haptic on press', (tester) async {
    final List<String?> calls = <String?>[];
    recordHapticCalls(tester, calls);
    await pumpFeedback(
      tester,
      const TapScale(haptic: HapticType.light, child: Text('payload')),
    );

    final gesture = await pressAtCenter(tester);
    await tester.pump();

    expect(calls, contains('HapticFeedbackType.lightImpact'));
    await gesture.up();
  });
}
