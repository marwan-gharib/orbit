import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/constants/hero_tags.dart';

import 'harness.dart';

void main() {
  test('should namespace the tag it builds for an id', () {
    expect(AppHeroTag.of(summaryId), '${HeroTags.prefix}$summaryId');
  });

  test('should never give two ids the same tag', () {
    expect(AppHeroTag.of(summaryId), isNot(AppHeroTag.of(listName)));
  });

  testWidgets('should build a hero with the standard flight profile', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppHero(id: summaryId, child: const Text(cardTitle)),
      ),
    );

    final Hero hero = tester.widget<Hero>(find.byType(Hero));
    expect(hero.tag, AppHeroTag.of(summaryId));
    expect(hero.curve, AppCurves.enter);
    expect(hero.reverseCurve, AppCurves.exit);
    expect(hero.transitionOnUserGestures, isTrue);
    expect(hero.flightShuttleBuilder, AppHero.flightShuttle);
  });

  testWidgets('should hand its placeholder builder to the hero', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppHero(
          id: summaryId,
          placeholderBuilder: (_, size, _) =>
              SizedBox(width: size.width, height: size.height),
          child: const Text(cardTitle),
        ),
      ),
    );

    expect(
      tester.widget<Hero>(find.byType(Hero)).placeholderBuilder,
      isNotNull,
    );
  });

  testWidgets('should cross-fade the two containers while the hero flies', (
    tester,
  ) async {
    final GoRouter router = await pumpNavigationApp(tester);

    await openDetails(tester, router);
    await tester.pump(AppDurations.normal ~/ 2);

    expect(findFlightShuttle(), findsOneWidget);
    final List<double> layers = tester
        .widgetList<Opacity>(
          find.descendant(
            of: findFlightShuttle(),
            matching: find.byType(Opacity),
          ),
        )
        .map((Opacity opacity) => opacity.opacity)
        .toList();
    expect(layers, hasLength(2));
    expect(
      layers.first + layers.last,
      closeTo(AppAnimationConstants.fadeOpacityEnd, 0.05),
      reason: 'the shuttle should hand over from one container to the other',
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('should hand its content back when the flight lands', (
    tester,
  ) async {
    final GoRouter router = await pumpNavigationApp(tester);

    await openDetails(tester, router);
    await tester.pump(AppDurations.normal ~/ 2);
    await tester.pump(AppDurations.normal);
    await tester.pump();

    expect(findFlightShuttle(), findsNothing);
    expect(find.text(cardTitle), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('should keep the whole navigation readable in RTL', (
    tester,
  ) async {
    final GoRouter router = await pumpNavigationApp(
      tester,
      direction: TextDirection.rtl,
    );

    await openDetails(tester, router);
    await tester.pump(AppDurations.normal);
    await tester.pump();

    expect(find.text(detailsTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
