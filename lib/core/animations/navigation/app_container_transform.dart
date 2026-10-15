import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_hero.dart';
import 'app_page_transitions.dart';

/// Card-to-details container transform (Material): the card the user tapped
/// grows into the container of the screen it opened, while the rest of that
/// screen fades in behind it and the list underneath stays exactly where it
/// is.
///
/// Two parts, both required for the effect:
///
///  * the container — a card, a thumbnail, a summary panel — is an [AppHero]
///    with one id on each side, and
///  * both routes of the pair are built with
///    [AppPageTransition.containerTransform], so the covered route ignores
///    `secondaryAnimation` instead of sliding away.
///
/// ```dart
/// // List route: the card that will grow. Every path literal lives in
/// // `RoutePaths` (lib/core/router/route_paths.dart), never inline.
/// AppRoute.create(
///   path: RoutePaths.orders,
///   transition: AppPageTransition.containerTransform,
///   builder: (_, _) => const OrdersScreen(),
/// )
///
/// // Details route: the page the card grows into.
/// AppRoute.create(
///   path: RoutePaths.orderDetails,
///   transition: AppPageTransition.containerTransform,
///   builder: (context, state) => AppContainerTransform.page(
///     context: context,
///     state: state,
///     id: state.pathParameters['id']!,
///     child: OrderDetailsScreen(id: state.pathParameters['id']!),
///   ),
/// )
///
/// // …and inside the list screen, the source of that flight.
/// AppHero(
///   id: order.id,
///   child: OrderCard(order: order),
/// )
/// ```
///
/// [child] here is laid out at the card's size while it flies, so it should
/// be (or contain) a surface that survives being small for the first frames —
/// a scrollable details screen does, a tall `Column` of fixed rows may not.
/// When only part of the screen should take part in the transform, leave the
/// hero out of [page] and place [AppHero]s inside both screens yourself,
/// building the routes with [AppPageTransitions.containerTransform].
abstract final class AppContainerTransform {
  /// The details half of a container transform: [child] becomes the
  /// container that flies in from the source card, and the rest of it — every
  /// widget outside the hero — fades in on [AppCurves.enter] as the page
  /// arrives.
  ///
  /// [id] must be the same value the source card passes to [AppHero], since
  /// it is what pairs the two ends. Do not wrap [child] in a second
  /// [AppHero]: a Hero cannot nest inside another.
  static CustomTransitionPage<T> page<T>({
    required BuildContext context,
    required GoRouterState state,
    required Object id,
    required Widget child,
  }) => AppPageTransitions.containerTransform<T>(
    context: context,
    state: state,
    child: AppHero(id: id, child: child),
  );
}
