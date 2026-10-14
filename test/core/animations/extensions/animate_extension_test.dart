import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  testWidgets('should wrap the child in FadeIn when fadeIn is called', (
    tester,
  ) async {
    await pumpAnimations(tester, const Text('payload').fadeIn());

    expect(find.byType(FadeIn), findsOneWidget);
    expect(find.text('payload'), findsOneWidget);
  });

  testWidgets('should wrap the child in SlideIn when slideIn is called', (
    tester,
  ) async {
    await pumpAnimations(tester, const Text('payload').slideIn());

    expect(find.byType(SlideIn), findsOneWidget);
  });

  testWidgets('should wrap the child in ScaleIn when scaleIn is called', (
    tester,
  ) async {
    await pumpAnimations(tester, const Text('payload').scaleIn());

    expect(find.byType(ScaleIn), findsOneWidget);
  });

  testWidgets(
    'should wrap the child in FadeSlideIn when fadeSlideIn is called',
    (tester) async {
      await pumpAnimations(tester, const Text('payload').fadeSlideIn());

      expect(find.byType(FadeSlideIn), findsOneWidget);
    },
  );

  testWidgets('should wrap the child in BlurIn when blurIn is called', (
    tester,
  ) async {
    await pumpAnimations(tester, const Text('payload').blurIn());

    expect(find.byType(BlurIn), findsOneWidget);
  });

  testWidgets('should forward the delay when fadeSlideIn receives one', (
    tester,
  ) async {
    await pumpAnimations(
      tester,
      const Text('payload').fadeSlideIn(delay: AppDurations.fast),
    );

    final FadeSlideIn widget = tester.widget<FadeSlideIn>(
      find.byType(FadeSlideIn),
    );
    expect(widget.delay, AppDurations.fast);
  });

  testWidgets('should finish at the final state when the entrance has played', (
    tester,
  ) async {
    await pumpAnimations(tester, const Text('payload').fadeIn());

    await tester.pump(AppDurations.slow);

    final FadeTransition fade = tester.widget<FadeTransition>(
      find.byType(FadeTransition),
    );
    expect(fade.opacity.value, AppAnimationConstants.fadeOpacityEnd);
  });

  testWidgets('should call onTap when the tapScale child is tapped', (
    tester,
  ) async {
    var taps = 0;
    await pumpAnimations(
      tester,
      const Text('payload').tapScale(onTap: () => taps++),
    );

    await tester.tap(find.text('payload'));

    expect(taps, 1);
  });

  testWidgets('should disable press feedback when tapScale is disabled', (
    tester,
  ) async {
    await pumpAnimations(
      tester,
      const Text('payload').tapScale(enabled: false),
    );

    final TapScale widget = tester.widget<TapScale>(find.byType(TapScale));
    expect(widget.enabled, isFalse);
  });

  testWidgets('should attach the controller when shake is called', (
    tester,
  ) async {
    final ShakeController controller = ShakeController();
    await pumpAnimations(tester, const Text('payload').shake(controller));

    final ShakeWidget widget = tester.widget<ShakeWidget>(
      find.byType(ShakeWidget),
    );
    expect(widget.controller, same(controller));

    controller.shake();
    await tester.pump();
    await tester.pump(AppDurations.slow);
  });

  testWidgets(
    'should run the pulse loop by default when pulse has no arguments',
    (tester) async {
      await pumpAnimations(tester, const Text('payload').pulse());

      final PulseWidget widget = tester.widget<PulseWidget>(
        find.byType(PulseWidget),
      );
      expect(widget.active, isTrue);
    },
  );

  testWidgets('should rest the pulse when pulse is not active', (tester) async {
    await pumpAnimations(tester, const Text('payload').pulse(active: false));

    final PulseWidget widget = tester.widget<PulseWidget>(
      find.byType(PulseWidget),
    );
    expect(widget.active, isFalse);
  });

  testWidgets('should attach the controller when bounce is called', (
    tester,
  ) async {
    final BounceController controller = BounceController();
    await pumpAnimations(tester, const Text('payload').bounce(controller));

    final BounceWidget widget = tester.widget<BounceWidget>(
      find.byType(BounceWidget),
    );
    expect(widget.controller, same(controller));

    controller.bounce();
    await tester.pump();
    await tester.pump(AppDurations.slow);
  });

  testWidgets('should forward the index when staggered is called', (
    tester,
  ) async {
    await pumpAnimations(tester, const Text('payload').staggered(index: 3));

    final StaggeredListItem widget = tester.widget<StaggeredListItem>(
      find.byType(StaggeredListItem),
    );
    expect(widget.index, 3);
  });

  testWidgets(
    'should wrap the child in RevealOnScroll when revealOnScroll is called',
    (tester) async {
      await pumpAnimations(tester, const Text('payload').revealOnScroll());

      expect(find.byType(RevealOnScroll), findsOneWidget);
    },
  );
}
