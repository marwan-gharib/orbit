import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  late FakeLottieAssets assets;

  setUp(() {
    // The composition cache is process-wide; clearing it per test keeps
    // every load visible to [FakeLottieAssets] and order-independent.
    Lottie.cache.clear();
    assets = FakeLottieAssets();
  });

  testWidgets('should request the success asset when the success '
      'constructor is built', (tester) async {
    await pumpLottie(tester, const AppLottie.success(size: 60), assets: assets);
    await pumpLottieLoad(tester);
    expect(assets.requestedAssets, [AppLottieAssets.success]);
  });

  testWidgets('should request the given path when a generic asset is built', (
    tester,
  ) async {
    await pumpLottie(
      tester,
      const AppLottie.asset(AppLottieAssets.loading),
      assets: assets,
    );
    await pumpLottieLoad(tester);
    expect(assets.requestedAssets, [AppLottieAssets.loading]);
  });

  testWidgets('should stop on the last frame when success finishes playing', (
    tester,
  ) async {
    await pumpLottie(tester, const AppLottie.success(size: 60), assets: assets);
    await tester.pumpAndSettle();

    final controller = progressOf(tester);
    expect(controller.value, 1.0);
    expect(controller.isAnimating, isFalse);
  });

  testWidgets('should call onCompleted once when success finishes playing', (
    tester,
  ) async {
    var calls = 0;
    await pumpLottie(
      tester,
      AppLottie.success(size: 60, onCompleted: () => calls++),
      assets: assets,
    );
    await tester.pumpAndSettle();

    expect(calls, 1);
  });

  testWidgets('should keep looping when loading repeats', (tester) async {
    await pumpLottie(tester, const AppLottie.loading(size: 24), assets: assets);
    await pumpLottieLoad(tester);
    await tester.pump(const Duration(milliseconds: 1200));

    expect(progressOf(tester).isAnimating, isTrue);
  });

  testWidgets(
    'should show the last frame without playing when disableAnimations '
    'is on',
    (tester) async {
      await pumpLottie(
        tester,
        const AppLottie.success(size: 60),
        assets: assets,
        disableAnimations: true,
      );
      await pumpLottieLoad(tester);
      await tester.pump();

      final controller = progressOf(tester);
      expect(controller.value, 1.0);
      expect(controller.isAnimating, isFalse);
      await tester.pump(const Duration(milliseconds: 500));
      expect(controller.value, 1.0);
    },
  );

  testWidgets(
    'should show the first frame without playing when disableAnimations '
    'is on for loading',
    (tester) async {
      await pumpLottie(
        tester,
        const AppLottie.loading(size: 24),
        assets: assets,
        disableAnimations: true,
      );
      await pumpLottieLoad(tester);
      await tester.pump();

      final controller = progressOf(tester);
      expect(controller.value, 0.0);
      expect(controller.isAnimating, isFalse);
      await tester.pump(const Duration(milliseconds: 500));
      expect(controller.value, 0.0);
    },
  );

  testWidgets(
    'should call onCompleted once when disableAnimations jumps to the '
    'last frame',
    (tester) async {
      var calls = 0;
      await pumpLottie(
        tester,
        AppLottie.success(size: 60, onCompleted: () => calls++),
        assets: assets,
        disableAnimations: true,
      );
      await pumpLottieLoad(tester);
      await tester.pump();

      expect(calls, 1);
    },
  );

  testWidgets('should render the fallback icon when the asset fails to load', (
    tester,
  ) async {
    await pumpLottie(tester, const AppLottie.error(size: 64), assets: assets);
    await pumpLottieLoad(tester);

    expect(find.byType(Icon), findsOneWidget);
    expect(tester.takeException(), isA<FlutterError>());
  });

  testWidgets('should render the given fallback when the asset fails to load', (
    tester,
  ) async {
    await pumpLottie(
      tester,
      const AppLottie.error(size: 64, fallback: SizedBox.shrink()),
      assets: assets,
    );
    await pumpLottieLoad(tester);

    expect(find.byType(Icon), findsNothing);
    expect(tester.takeException(), isA<FlutterError>());
  });

  testWidgets('should constrain the animation when a size is given', (
    tester,
  ) async {
    await pumpLottie(
      tester,
      const Center(child: AppLottie.success(size: 60)),
      assets: assets,
    );
    await pumpLottieLoad(tester);

    expect(tester.getSize(find.byType(AppLottie)), const Size(60, 60));
  });

  testWidgets('should keep playing from its position when the parent '
      'rebuilds', (tester) async {
    Widget tree(double spacerHeight) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: spacerHeight),
          const AppLottie.success(size: 60),
        ],
      ),
    );

    await pumpLottie(tester, tree(10), assets: assets);
    await pumpLottieLoad(tester);
    await tester.pump(const Duration(milliseconds: 300));
    final controllerBefore = progressOf(tester);
    final double valueBefore = controllerBefore.value;

    await pumpLottie(tester, tree(20), assets: assets);
    final controllerAfter = progressOf(tester);
    expect(identical(controllerBefore, controllerAfter), isTrue);
    expect(controllerAfter.value, closeTo(valueBefore, 0.01));

    await tester.pump(const Duration(milliseconds: 300));
    expect(controllerAfter.value, greaterThan(valueBefore));
  });

  testWidgets('should mirror the animation when the direction is RTL and '
      'mirrorInRtl is true', (tester) async {
    await pumpLottie(
      tester,
      const AppLottie.success(size: 60, mirrorInRtl: true),
      assets: assets,
      direction: TextDirection.rtl,
    );
    await pumpLottieLoad(tester);

    expect(find.byType(Transform), findsOneWidget);
  });

  testWidgets('should not mirror the animation when the direction is LTR', (
    tester,
  ) async {
    await pumpLottie(
      tester,
      const AppLottie.success(size: 60, mirrorInRtl: true),
      assets: assets,
    );
    await pumpLottieLoad(tester);

    expect(find.byType(Transform), findsNothing);
  });
}

/// The wrapper's playback controller; [AppLottie] always provides one.
Animation<double> progressOf(WidgetTester tester) =>
    tester.widget<Lottie>(find.byType(Lottie)).controller!;
