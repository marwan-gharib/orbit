import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit/core/animations/animations.dart';

/// Test-only route paths. The app keeps its real ones in `RoutePaths`.
const String listPath = '/list';
const String listName = 'list';
const String detailsSegment = 'details';
const String detailsPath = '$listPath/$detailsSegment';

/// Test-only id shared by the list card and the details container, so the two
/// ends of the flight pair up.
const String summaryId = 'summary';

/// Texts the tests look for, kept as constants so no test hunts a raw string.
const String listTitle = 'List route';
const String detailsTitle = 'Details route';
const String cardTitle = 'Summary card';

/// The list side of the pair: a card wrapped in the standard [AppHero].
class _ListPage extends StatelessWidget {
  const _ListPage();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: <Widget>[
        const Text(listTitle),
        AppHero(id: summaryId, child: const Text(cardTitle)),
      ],
    ),
  );
}

/// The details side of the pair: its own container for the same flight.
class _DetailsPage extends StatelessWidget {
  const _DetailsPage();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: <Widget>[
        const Text(detailsTitle),
        AppHero(id: summaryId, child: const Text(cardTitle)),
      ],
    ),
  );
}

/// Pumps [router] under the [MediaQuery] and [Directionality] the navigation
/// group reads, so a test can flip `disableAnimations` or the text direction
/// without rebuilding the app.
Future<void> pumpRouter(
  WidgetTester tester,
  GoRouter router, {
  bool disableAnimations = false,
  TextDirection direction = TextDirection.ltr,
}) {
  return tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: Directionality(textDirection: direction, child: child!),
      ),
    ),
  );
}

/// Pumps a two-route app: a list screen that opens a details screen below it.
///
/// Both transitions default to `null`, which is the "let the app-wide default
/// apply" case. Pass [detailsPageBuilder] to build the details route yourself
/// — that is how `AppContainerTransform.page` gets tested.
Future<GoRouter> pumpNavigationApp(
  WidgetTester tester, {
  AppPageTransition? listTransition,
  AppPageTransition? detailsTransition,
  GoRouterPageBuilder? detailsPageBuilder,
  bool disableAnimations = false,
  TextDirection direction = TextDirection.ltr,
}) async {
  final GoRouter router = GoRouter(
    initialLocation: listPath,
    routes: <RouteBase>[
      AppRoute.create(
        path: listPath,
        transition: listTransition,
        builder: (_, _) => const _ListPage(),
        routes: <RouteBase>[
          detailsPageBuilder != null
              ? GoRoute(path: detailsSegment, pageBuilder: detailsPageBuilder)
              : AppRoute.create(
                  path: detailsSegment,
                  transition: detailsTransition,
                  builder: (_, _) => const _DetailsPage(),
                ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await pumpRouter(
    tester,
    router,
    disableAnimations: disableAnimations,
    direction: direction,
  );
  return router;
}

/// Opens the details route on top of the list and runs the frame that mounts
/// it, leaving its transition at its very first frame.
Future<void> openDetails(WidgetTester tester, GoRouter router) async {
  router.go(detailsPath);
  await tester.pump();
}

/// The route the details screen is mounted in, read from its own element —
/// the only handle a test has on a route's durations.
///
/// The first frame after a push parks the arriving route offstage until the
/// hero controller posts its transition, so the search reads offstage widgets
/// too.
ModalRoute<Object?> detailsRouteOf(WidgetTester tester) => ModalRoute.of(
  tester.element(find.text(detailsTitle, skipOffstage: false)),
)!;

/// The slide offsets that are actually in motion; every other [SlideTransition]
/// in the tree sits at its resting value.
List<Offset> movingSlides(WidgetTester tester) => tester
    .widgetList<SlideTransition>(find.byType(SlideTransition))
    .map((SlideTransition slide) => slide.position.value)
    .where((Offset offset) => offset != Offset.zero)
    .toList();

/// The opacity values caught between the token bounds — the pages that are
/// mid-fade rather than fully in or out.
List<double> fadingOpacities(WidgetTester tester) => tester
    .widgetList<FadeTransition>(find.byType(FadeTransition))
    .map((FadeTransition fade) => fade.opacity.value)
    .where(
      (double value) =>
          value > AppAnimationConstants.fadeOpacityBegin &&
          value < AppAnimationConstants.fadeOpacityEnd,
    )
    .toList();

/// The flight shuttle an [AppHero] carries: one stack of exactly two
/// [Opacity] layers, cross-faded across the flight.
Finder findFlightShuttle() => find.byWidgetPredicate(
  (Widget widget) =>
      widget is Stack &&
      widget.fit == StackFit.expand &&
      widget.children.length == 2 &&
      widget.children.every((Widget child) => child is Opacity),
);
