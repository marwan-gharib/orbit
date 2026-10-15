import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  double scaleOf(WidgetTester tester) =>
      tester.widget<ScaleTransition>(find.byType(ScaleTransition)).scale.value;

  double opacityOf(WidgetTester tester) =>
      tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity.value;

  testWidgets('should breathe in scale and opacity while active', (
    tester,
  ) async {
    await pumpFeedback(
      tester,
      const PulseWidget(active: true, child: Text('payload')),
    );

    await tester.pump(AppDurations.fast);

    expect(scaleOf(tester), greaterThan(1.0));
    expect(opacityOf(tester), lessThan(1.0));
  });

  testWidgets('should start looping when active turns true', (tester) async {
    await pumpFeedback(tester, const PulseWidget(child: Text('payload')));
    expect(scaleOf(tester), 1.0);

    await pumpFeedback(
      tester,
      const PulseWidget(active: true, child: Text('payload')),
    );

    await tester.pump(AppDurations.fast);

    expect(scaleOf(tester), greaterThan(1.0));
  });

  testWidgets('should stop at rest when active turns false', (tester) async {
    await pumpFeedback(
      tester,
      const PulseWidget(active: true, child: Text('payload')),
    );
    await tester.pump(AppDurations.fast);
    expect(scaleOf(tester), greaterThan(1.0));

    await pumpFeedback(tester, const PulseWidget(child: Text('payload')));

    expect(scaleOf(tester), 1.0);
    expect(opacityOf(tester), 1.0);

    // The ticker must be dead: a further full breath stays at rest.
    await tester.pump(AppDurations.slow);
    expect(scaleOf(tester), 1.0);
    expect(opacityOf(tester), 1.0);
  });

  testWidgets('should not loop when animations are disabled', (tester) async {
    await pumpFeedback(
      tester,
      const PulseWidget(active: true, child: Text('payload')),
      disableAnimations: true,
    );

    await tester.pump(AppDurations.slow);

    expect(scaleOf(tester), 1.0);
    expect(opacityOf(tester), 1.0);
  });

  testWidgets('should dispose cleanly while looping', (tester) async {
    await pumpFeedback(
      tester,
      const PulseWidget(active: true, child: Text('payload')),
    );
    await tester.pump(AppDurations.fast);

    await pumpFeedback(tester, const SizedBox());

    expect(tester.takeException(), isNull);
  });
}
