import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  testWidgets('should run a route transition for the token duration', (
    tester,
  ) async {
    final GoRouter router = await pumpNavigationApp(tester);

    await openDetails(tester, router);

    expect(detailsRouteOf(tester).transitionDuration, AppDurations.normal);
    expect(
      detailsRouteOf(tester).reverseTransitionDuration,
      AppDurations.normal,
    );
  });

  testWidgets('should swap the pages instantly for the none transition', (
    tester,
  ) async {
    final GoRouter router = await pumpNavigationApp(
      tester,
      detailsTransition: AppPageTransition.none,
    );

    await openDetails(tester, router);

    expect(detailsRouteOf(tester).transitionDuration, Duration.zero);
    expect(detailsRouteOf(tester).reverseTransitionDuration, Duration.zero);
  });

  testWidgets('should collapse the duration when animations are disabled', (
    tester,
  ) async {
    final GoRouter router = await pumpNavigationApp(
      tester,
      disableAnimations: true,
    );

    await openDetails(tester, router);

    expect(detailsRouteOf(tester).transitionDuration, Duration.zero);
    expect(detailsRouteOf(tester).reverseTransitionDuration, Duration.zero);
  });

  testWidgets('should animate the arriving page and the page it covers', (
    tester,
  ) async {
    final GoRouter router = await pumpNavigationApp(tester);

    await openDetails(tester, router);
    await tester.pump(AppDurations.normal ~/ 2);

    final List<Offset> moving = movingSlides(tester);
    expect(moving, hasLength(2), reason: 'both routes should be sliding');
    expect(
      moving.any((Offset offset) => offset.dx > 0),
      isTrue,
      reason: 'the new page enters from the end',
    );
    expect(
      moving.any((Offset offset) => offset.dx < 0),
      isTrue,
      reason: 'the covered page leaves toward the start',
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets(
    'should dim the covered page while the new one blooms on fadeThrough',
    (tester) async {
      final GoRouter router = await pumpNavigationApp(
        tester,
        detailsTransition: AppPageTransition.fadeThrough,
      );

      await openDetails(tester, router);
      await tester.pump(AppDurations.normal ~/ 2);

      expect(
        fadingOpacities(tester),
        hasLength(2),
        reason: 'both routes should be mid-fade',
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets('should mirror a horizontal transition in RTL', (tester) async {
    final GoRouter router = await pumpNavigationApp(
      tester,
      direction: TextDirection.rtl,
    );

    await openDetails(tester, router);
    await tester.pump(AppDurations.normal ~/ 2);

    final List<SlideTransition> slides = tester
        .widgetList<SlideTransition>(find.byType(SlideTransition))
        .toList();
    expect(slides, isNotEmpty);
    expect(
      slides.every(
        (SlideTransition slide) => slide.textDirection == TextDirection.rtl,
      ),
      isTrue,
      reason: 'every slide should read its direction from the tree',
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('should install the iOS back-swipe detector on iOS', (
    tester,
  ) async {
    final GoRouter router = await pumpNavigationApp(tester);

    await openDetails(tester, router);
    await tester.pump(AppDurations.normal);

    expect(find.byType(CupertinoPageTransition), findsWidgets);
    expect(
      find.descendant(
        of: find.byType(CupertinoPageTransition),
        matching: find.text(detailsTitle),
      ),
      findsOneWidget,
      reason: 'the arriving route should sit inside the gesture detector',
    );
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets(
    'should skip the back-swipe detector when animations are disabled',
    (tester) async {
      final GoRouter router = await pumpNavigationApp(
        tester,
        disableAnimations: true,
      );

      await openDetails(tester, router);
      await tester.pump(AppDurations.normal);

      expect(find.byType(CupertinoPageTransition), findsNothing);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'should skip the back-swipe detector on platforms without the gesture',
    (tester) async {
      final GoRouter router = await pumpNavigationApp(tester);

      await openDetails(tester, router);
      await tester.pump(AppDurations.normal);

      expect(find.byType(CupertinoPageTransition), findsNothing);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}
