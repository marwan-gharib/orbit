import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/loading/pulsing_placeholder.dart';
import 'package:orbit/core/animations/loading/shimmer_box.dart';
import 'package:orbit/core/animations/tokens/app_animation_constants.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';

import 'harness.dart';

void main() {
  double opacityOf(WidgetTester tester) =>
      tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity.value;

  testWidgets('should start at full opacity when built', (tester) async {
    await pumpLoading(tester, const PulsingPlaceholder(height: 20));

    expect(
      opacityOf(tester),
      AppAnimationConstants.pulsingPlaceholderMaxOpacity,
    );
  });

  testWidgets(
    'should fade between the pulse bounds when animations are enabled',
    (tester) async {
      await pumpLoading(tester, const PulsingPlaceholder(height: 20));

      await tester.pump(AppDurations.pulse ~/ 2);

      final midway = opacityOf(tester);
      expect(
        midway,
        lessThan(AppAnimationConstants.pulsingPlaceholderMaxOpacity),
      );
      expect(
        midway,
        greaterThan(AppAnimationConstants.pulsingPlaceholderMinOpacity),
      );
    },
  );

  testWidgets('should reach the dimmed opacity when one pulse leg completes', (
    tester,
  ) async {
    await pumpLoading(tester, const PulsingPlaceholder(height: 20));

    await tester.pump(AppDurations.pulse);

    expect(
      opacityOf(tester),
      closeTo(AppAnimationConstants.pulsingPlaceholderMinOpacity, 0.0001),
    );
  });

  testWidgets('should hold full opacity when animations are disabled', (
    tester,
  ) async {
    await pumpLoading(
      tester,
      const PulsingPlaceholder(height: 20),
      disableAnimations: true,
    );

    expect(
      opacityOf(tester),
      AppAnimationConstants.pulsingPlaceholderMaxOpacity,
    );
  });

  testWidgets('should render a circle when the shape is circle', (
    tester,
  ) async {
    await pumpLoading(tester, const PulsingPlaceholder.circle(width: 30));

    final box = tester.widget<ShimmerBox>(find.byType(ShimmerBox));
    expect(box.shape, PlaceholderShape.circle);
    expect(box.width, 30);
  });

  testWidgets('should dispose cleanly when removed', (tester) async {
    await pumpLoading(tester, const PulsingPlaceholder(height: 20));
    await pumpLoading(tester, const SizedBox());

    expect(tester.takeException(), isNull);
  });
}
