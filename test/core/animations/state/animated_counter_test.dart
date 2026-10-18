import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:orbit/core/animations/state/animated_counter.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';

import 'harness.dart';

void main() {
  String displayedNumber(WidgetTester tester) =>
      tester.widget<Text>(find.byType(Text)).data ?? '';

  int displayedInteger(WidgetTester tester) =>
      int.parse(displayedNumber(tester));

  testWidgets('should count up from zero when first displayed', (tester) async {
    await pumpState(tester, const AnimatedCounter(value: 300));

    expect(displayedNumber(tester), '0');

    await tester.pumpAndSettle();

    expect(displayedNumber(tester), '300');
  });

  testWidgets('should show the final value immediately when animations are '
      'disabled', (tester) async {
    await pumpState(
      tester,
      const AnimatedCounter(value: 300),
      disableAnimations: true,
    );

    expect(displayedNumber(tester), '300');
  });

  testWidgets('should tick from the old value to the new value when the '
      'value changes', (tester) async {
    await pumpState(tester, const AnimatedCounter(value: 10));
    await tester.pumpAndSettle();
    expect(displayedNumber(tester), '10');

    await pumpState(tester, const AnimatedCounter(value: 90));
    await tester.pump(AppDurations.normal ~/ 2);
    final midway = displayedInteger(tester);
    expect(midway, greaterThan(10));
    expect(midway, lessThan(90));

    await tester.pumpAndSettle();
    expect(displayedNumber(tester), '90');
  });

  testWidgets('should keep its progress when rebuilt with the same value', (
    tester,
  ) async {
    await pumpState(tester, const AnimatedCounter(value: 10));
    await tester.pump(AppDurations.normal ~/ 4);
    final midway = displayedInteger(tester);
    expect(midway, greaterThan(0));

    await pumpState(tester, const AnimatedCounter(value: 10));

    expect(displayedInteger(tester), midway);
  });

  testWidgets('should keep the configured number of decimals when '
      'formatting', (tester) async {
    await pumpState(
      tester,
      const AnimatedCounter(value: 3.14159, decimalPlaces: 2),
      disableAnimations: true,
    );

    expect(displayedNumber(tester), '3.14');
  });

  testWidgets('should use the custom formatter when one is provided', (
    tester,
  ) async {
    await pumpState(
      tester,
      AnimatedCounter(
        value: 1200,
        animateFromZero: false,
        formatter: (value) => 'EUR ${value.toStringAsFixed(2)}',
      ),
      disableAnimations: true,
    );

    expect(displayedNumber(tester), 'EUR 1200.00');
  });

  testWidgets('should format with the given locale when a locale is passed', (
    tester,
  ) async {
    final expected = NumberFormat.decimalPattern('de').format(1234567);

    await pumpState(
      tester,
      const AnimatedCounter(
        value: 1234567,
        locale: Locale('de'),
        animateFromZero: false,
      ),
      disableAnimations: true,
    );

    expect(displayedNumber(tester), expected);
  });

  testWidgets('should use tabular figures so digits keep their width', (
    tester,
  ) async {
    await pumpState(tester, const AnimatedCounter(value: 42));

    final style = tester.widget<Text>(find.byType(Text)).style;

    expect(style?.fontFeatures, contains(const FontFeature.tabularFigures()));
  });

  group('externally driven progress', () {
    Widget driven(double progress, {Curve curve = AppCurves.enter}) =>
        AnimatedCounter(
          value: 75,
          progress: progress,
          interval: const (0.55, 1.0),
          curve: curve,
        );

    testWidgets('should start and finish exactly outside the interval', (
      tester,
    ) async {
      await pumpState(tester, driven(0.55));
      expect(displayedNumber(tester), '0');

      await pumpState(tester, driven(1.0));
      expect(displayedNumber(tester), '75');
    });

    testWidgets('should ease the count through the interval', (tester) async {
      await pumpState(tester, driven(0.775));

      final expected = (75.0 * AppCurves.enter.transform(0.5)).round();
      expect(displayedNumber(tester), expected.toString());
    });

    testWidgets('should count below the interval start and keep easing '
        'inside it', (tester) async {
      await pumpState(tester, driven(0.1));
      expect(displayedNumber(tester), '0');

      // Past 0.9 the interval still eases: the digits are not at the end yet.
      await pumpState(tester, driven(0.9));
      final eased = AppCurves.enter.transform((0.9 - 0.55) / 0.45);
      expect(displayedNumber(tester), (75.0 * eased).round().toString());
    });
  });

  group('text layout passthrough', () {
    testWidgets('should forward maxLines and overflow to the rendered digit', (
      tester,
    ) async {
      await pumpState(
        tester,
        const AnimatedCounter(
          value: 75,
          progress: 1.0,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.style?.fontSize, 10);
    });
  });
}
