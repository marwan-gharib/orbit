import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  test('should build a go route that carries its own page builder', () {
    final GoRoute route = AppRoute.create(
      path: listPath,
      name: listName,
      caseSensitive: false,
      builder: (_, _) => const SizedBox(),
    );

    expect(route.path, listPath);
    expect(route.name, listName);
    expect(route.caseSensitive, isFalse);
    expect(route.pageBuilder, isNotNull);
    expect(route.builder, isNull);
  });

  test('should hand nesting through to the route it builds', () {
    final GoRoute route = AppRoute.create(
      path: listPath,
      builder: (_, _) => const SizedBox(),
      routes: <RouteBase>[
        AppRoute.create(
          path: detailsSegment,
          builder: (_, _) => const SizedBox(),
        ),
      ],
    );

    expect(route.routes, hasLength(1));
    expect(route.routes.single, isA<GoRoute>());
    expect((route.routes.single as GoRoute).path, detailsSegment);
  });

  testWidgets(
    'should apply the app-wide default when a route names no transition',
    (tester) async {
      final GoRouter router = await pumpNavigationApp(tester);

      await openDetails(tester, router);
      await tester.pump(AppDurations.normal ~/ 2);

      expect(detailsRouteOf(tester).transitionDuration, AppDurations.normal);
      final List<Offset> moving = movingSlides(tester);
      expect(
        moving,
        hasLength(2),
        reason: 'the default shared axis moves both routes',
      );
      expect(
        moving.every((Offset offset) => offset.dx != 0),
        isTrue,
        reason: 'the default should be the horizontal shared axis',
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets('should honour a transition the route names itself', (
    tester,
  ) async {
    final GoRouter router = await pumpNavigationApp(
      tester,
      listTransition: AppPageTransition.none,
      detailsTransition: AppPageTransition.scale,
    );

    await openDetails(tester, router);
    await tester.pump(AppDurations.normal ~/ 2);

    expect(find.byType(ScaleTransition), findsWidgets);
    expect(find.byType(SlideTransition), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('should open a route that opts out of motion completely', (
    tester,
  ) async {
    final GoRouter router = await pumpNavigationApp(
      tester,
      detailsTransition: AppPageTransition.none,
    );

    await openDetails(tester, router);

    expect(detailsRouteOf(tester).transitionDuration, Duration.zero);
    expect(find.text(detailsTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
