import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_page_transitions.dart';

/// Builds a [GoRoute] that already carries one of [AppPageTransitions]' page
/// builders, so a feature's route table is one call per screen instead of a
/// `pageBuilder` block repeated everywhere.
///
/// The transition comes from [AppPageTransitions.defaultTransition] unless
/// the route names its own, which makes the app-wide default a single-line
/// change in one place:
///
/// ```dart
/// GoRouter(
///   initialLocation: RoutePaths.orders,
///   routes: <RouteBase>[
///     // No `transition` argument: takes AppPageTransitions.defaultTransition.
///     AppRoute.create(path: RoutePaths.orders, builder: (_, _) => const OrdersScreen()),
///     // A route that overrides it…
///     AppRoute.create(
///       path: RoutePaths.orderDetails,
///       transition: AppPageTransition.slide,
///       builder: (_, state) => OrderDetailsScreen(id: state.pathParameters['id']!),
///       // …and nested routes that override it again.
///       routes: <RouteBase>[
///         AppRoute.create(
///           path: RoutePaths.orderEdit,
///           transition: AppPageTransition.fadeThrough,
///           builder: (_, state) => OrderEditScreen(id: state.pathParameters['id']!),
///         ),
///       ],
///     ),
///     // The container-transform pair keeps the list still while the card flies.
///     AppRoute.create(
///       path: RoutePaths.orderSummary,
///       transition: AppPageTransition.containerTransform,
///       builder: (context, state) => AppContainerTransform.page(
///         context: context,
///         state: state,
///         id: state.pathParameters['id']!,
///         child: OrderSummaryScreen(id: state.pathParameters['id']!),
///       ),
///     ),
///   ],
/// )
/// ```
///
/// [AppRoute.create] is a thin wrapper: anything a route needs that it does
/// not expose (`onExit`, `metadata`, a `builder` instead of a page) is a plain
/// [GoRoute] whose `pageBuilder` calls [AppPageTransitions.page] directly.
abstract final class AppRoute {
  /// A [GoRoute] for [path] whose pages animate with [transition], or with
  /// [AppPageTransitions.defaultTransition] when [transition] is null.
  ///
  /// [builder] receives the same [GoRouterState] a `pageBuilder` would, so
  /// path and query parameters are read exactly as before.
  static GoRoute create({
    required String path,
    required GoRouterWidgetBuilder builder,
    AppPageTransition? transition,
    String? name,
    GlobalKey<NavigatorState>? parentNavigatorKey,
    GoRouterRedirect? redirect,
    List<RouteBase> routes = const <RouteBase>[],
    bool caseSensitive = true,
  }) {
    final AppPageTransition effective =
        transition ?? AppPageTransitions.defaultTransition;
    return GoRoute(
      path: path,
      name: name,
      parentNavigatorKey: parentNavigatorKey,
      redirect: redirect,
      routes: routes,
      caseSensitive: caseSensitive,
      pageBuilder: (BuildContext context, GoRouterState state) =>
          AppPageTransitions.page(
            transition: effective,
            context: context,
            state: state,
            child: builder(context, state),
          ),
    );
  }
}
