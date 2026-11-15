import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/responsive/responsive_scaler.dart';

import '../widgets/harness.dart';

void main() {
  setUp(Responsive.unbind);
  tearDown(Responsive.unbind);

  group('Responsive facade with a bound test scaler', () {
    test('should delegate each axis to the bound scaler', () {
      Responsive.bind(
        const AxisTestScaler(
          widthFactor: 2,
          heightFactor: 3,
          adaptiveFactor: 0.5,
        ),
      );

      expect(Responsive.width(10), 20);
      expect(Responsive.height(10), 30);
      expect(Responsive.radius(10), 5);
      expect(Responsive.font(10), 5);
      expect(Responsive.adapt(10), 5);
    });

    test('should report the bound scaler as initialized', () {
      expect(Responsive.isInitialized, isFalse);

      Responsive.bind(const AxisTestScaler());

      expect(Responsive.isInitialized, isTrue);
    });

    test('should pass values through unchanged once unbound', () {
      Responsive.bind(const AxisTestScaler(widthFactor: 2, heightFactor: 2));
      Responsive.unbind();

      expect(Responsive.width(10), 10);
      expect(Responsive.height(10), 10);
      expect(Responsive.radius(10), 10);
      expect(Responsive.font(10), 10);
      expect(Responsive.adapt(10), 10);
      expect(Responsive.isInitialized, isFalse);
    });

    test('should forward configure to the bound scaler', () {
      var configured = false;
      Responsive.bind(_RecordingScaler(onConfigure: () => configured = true));

      Responsive.configure(
        const MediaQueryData(size: Size(800, 1000)),
        designSize: Responsive.designSize,
      );

      expect(configured, isTrue);
    });
  });

  group('IdentityResponsiveScaler', () {
    const scaler = IdentityResponsiveScaler();

    test('should pass every value through unchanged', () {
      expect(scaler.width(12), 12);
      expect(scaler.height(12), 12);
      expect(scaler.radius(12), 12);
      expect(scaler.font(12), 12);
      expect(scaler.adapt(12), 12);
    });

    test('should never report itself initialized', () {
      expect(scaler.isInitialized, isFalse);
    });

    test('should tolerate configure and complete ensureInitialized', () async {
      scaler.configure(
        const MediaQueryData(size: Size(800, 1000)),
        designSize: Responsive.designSize,
      );
      await scaler.ensureInitialized();

      expect(scaler.width(12), 12);
    });
  });

  group('ResponsiveScope', () {
    testWidgets('should bind and configure the default engine on mount', (
      tester,
    ) async {
      expect(Responsive.isInitialized, isFalse);

      await pumpApp(tester, home: const SizedBox.shrink());

      expect(Responsive.isInitialized, isTrue);
      // Surface is 800x1000 against a 375x812 design: the width ratio 2.13
      // clamps to the 1.30 cap, so 10 logical px become 13.
      expect(Responsive.width(10), closeTo(13, 0.0001));
    });

    testWidgets('should clamp the system text scale for the whole subtree', (
      tester,
    ) async {
      double? effectiveScale;
      await pumpApp(
        tester,
        textScaleFactor: 2,
        home: Builder(
          builder: (context) {
            effectiveScale = MediaQuery.textScalerOf(context).scale(10);
            return const SizedBox.shrink();
          },
        ),
      );

      expect(effectiveScale, closeTo(13, 0.0001));
    });

    testWidgets('should restore the identity scaler when it unmounts', (
      tester,
    ) async {
      await pumpApp(tester, home: const SizedBox.shrink());
      expect(Responsive.isInitialized, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());

      expect(Responsive.isInitialized, isFalse);
      expect(Responsive.width(10), 10);
    });
  });
}

class _RecordingScaler extends ResponsiveScaler {
  const _RecordingScaler({required this.onConfigure});

  final void Function() onConfigure;

  @override
  double width(double value) => value;

  @override
  double height(double value) => value;

  @override
  double radius(double value) => value;

  @override
  double font(double value) => value;

  @override
  double adapt(double value) => value;

  @override
  bool get isInitialized => true;

  @override
  void configure(MediaQueryData metrics, {required Size designSize}) =>
      onConfigure();

  @override
  Future<void> ensureInitialized() async {}
}
