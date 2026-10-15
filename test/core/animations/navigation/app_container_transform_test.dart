import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/constants/hero_tags.dart';

import 'harness.dart';

void main() {
  /// The pair as a container transform: both routes hold still, and the
  /// details page is built by [AppContainerTransform.page].
  Future<GoRouter> pumpTransform(
    WidgetTester tester, {
    bool disableAnimations = false,
  }) => pumpNavigationApp(
    tester,
    listTransition: AppPageTransition.containerTransform,
    disableAnimations: disableAnimations,
    detailsPageBuilder: (BuildContext context, GoRouterState state) =>
        AppContainerTransform.page(
          context: context,
          state: state,
          id: summaryId,
          child: const Text(detailsTitle),
        ),
  );

  testWidgets('should make the arriving page itself the flying container', (
    tester,
  ) async {
    final GoRouter router = await pumpTransform(tester);

    // While the flight runs the arriving hero shows its placeholder, so the
    // page itself can only be read once the container has landed.
    await openDetails(tester, router);
    await tester.pump(AppDurations.normal ~/ 2);
    await tester.pump(AppDurations.normal);
    await tester.pump();

    expect(
      find.ancestor(of: find.text(detailsTitle), matching: find.byType(Hero)),
      findsOneWidget,
      reason: 'the details page should be the container the card grew into',
    );
    expect(
      tester
          .widget<Hero>(
            find.ancestor(
              of: find.text(detailsTitle),
              matching: find.byType(Hero),
            ),
          )
          .tag,
      AppHeroTag.of(summaryId),
      reason: 'the container should fly under the namespaced tag',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'should hold the covered list still while the new page fades in',
    (tester) async {
      final GoRouter router = await pumpTransform(tester);
      final Offset resting = tester.getTopLeft(find.text(listTitle));

      await openDetails(tester, router);
      await tester.pump(AppDurations.normal ~/ 2);

      expect(
        find.byType(SlideTransition),
        findsNothing,
        reason: 'no route should slide out from under the card',
      );
      expect(
        tester.getTopLeft(find.text(listTitle)),
        resting,
        reason: 'the covered list should neither slide nor scale away',
      );
      expect(
        fadingOpacities(tester),
        hasLength(1),
        reason: 'only the arriving page should be fading in',
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets('should cross-fade the card into the page during the flight', (
    tester,
  ) async {
    final GoRouter router = await pumpTransform(tester);

    await openDetails(tester, router);
    await tester.pump(AppDurations.normal ~/ 2);
    expect(findFlightShuttle(), findsOneWidget);

    await tester.pump(AppDurations.normal);
    await tester.pump();
    expect(findFlightShuttle(), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'should swap to the final state at once when animations are disabled',
    (tester) async {
      final GoRouter router = await pumpTransform(
        tester,
        disableAnimations: true,
      );

      await openDetails(tester, router);

      expect(detailsRouteOf(tester).transitionDuration, Duration.zero);
      expect(find.text(detailsTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test('should fly with the namespaced tag the source card asked for', () {
    expect(AppHeroTag.of(summaryId), '${HeroTags.prefix}$summaryId');
  });
}
