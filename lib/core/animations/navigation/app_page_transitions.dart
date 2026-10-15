import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:go_router/go_router.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';

/// Which of [AppPageTransitions]' page transitions a route uses.
enum AppPageTransition {
  /// Old page dims out first, the new one blooms in after it (Material
  /// fade-through); good for unrelated destinations.
  fadeThrough,

  /// Both pages slide across horizontally; the incoming page enters from the
  /// end side, so RTL mirrors the motion automatically.
  sharedAxisHorizontal,

  /// The incoming page rises from the bottom while the old one leaves upward;
  /// for hierarchies that advance vertically (wizards, report drill-downs).
  sharedAxisVertical,

  /// Directional stack push with parallax and a quick fade — the closest
  /// match to the iOS back-stack feel.
  slide,

  /// The new page settles in with a subtle zoom while the old one scales
  /// away; good for previews opening into details.
  scale,

  /// The new page fades in while the page it covers stays exactly where it
  /// is — the page half of a card-to-details container transform, which
  /// leaves the screen's only motion to the container flying between the two
  /// routes. Give *both* routes of the pair this transition so the covered
  /// page does not slide away under it (see [AppContainerTransform] for the
  /// recipe).
  containerTransform,

  /// No motion: the page swaps instantly and the back-swipe gesture is not
  /// installed.
  none,
}

/// Route transition builders for go_router: every builder returns a
/// [CustomTransitionPage] whose primary *and* secondary animations animate
/// both the incoming and the outgoing page.
///
/// Durations, curves and offsets come from the tokens only; on
/// `MediaQuery.disableAnimations` the page is built with a zero duration so
/// the final state renders immediately. Horizontal transitions mirror
/// themselves in RTL through [Directionality], and each build eases linearly
/// while the iOS back-swipe drives the route by hand.
///
/// Route paths come from `RoutePaths` (`lib/core/router/route_paths.dart`) —
/// one example per transition, never a path written inline:
///
/// ```dart
/// GoRoute(
///   path: RoutePaths.splash,
///   pageBuilder: (context, state) =>
///       AppPageTransitions.none(context: context, state: state, child: const SplashScreen()),
/// ),
/// GoRoute(
///   path: RoutePaths.login,
///   pageBuilder: (context, state) =>
///       AppPageTransitions.fadeThrough(context: context, state: state, child: const LoginScreen()),
/// ),
/// GoRoute(
///   path: RoutePaths.products,
///   pageBuilder: (context, state) => AppPageTransitions.sharedAxisHorizontal(
///     context: context,
///     state: state,
///     child: const ProductsScreen(),
///   ),
/// ),
/// GoRoute(
///   path: RoutePaths.reports,
///   pageBuilder: (context, state) => AppPageTransitions.sharedAxisVertical(
///     context: context,
///     state: state,
///     child: const ReportsScreen(),
///   ),
/// ),
/// GoRoute(
///   path: RoutePaths.orderDetails,
///   pageBuilder: (context, state) =>
///       AppPageTransitions.slide(context: context, state: state, child: const OrderDetailsScreen()),
/// ),
/// GoRoute(
///   path: RoutePaths.settings,
///   pageBuilder: (context, state) =>
///       AppPageTransitions.scale(context: context, state: state, child: const SettingsScreen()),
/// ),
/// GoRoute(
///   path: RoutePaths.catalogue,
///   pageBuilder: (context, state) => AppPageTransitions.containerTransform(
///     context: context,
///     state: state,
///     child: const CatalogueScreen(),
///   ),
/// ),
/// ```
///
/// Most routes should not repeat this boilerplate: use [AppRoute.create],
/// which applies [defaultTransition] unless a route overrides it.
abstract final class AppPageTransitions {
  /// The app-wide default applied by [AppRoute.create] when a route does not
  /// name a transition. Change it here to retune every route at once.
  static const AppPageTransition defaultTransition =
      AppPageTransition.sharedAxisHorizontal;

  /// Builds the page for [transition], reading duration, curves and
  /// `disableAnimations` from the tokens and [MediaQuery].
  ///
  /// Use this from a plain [GoRoute.pageBuilder] when the route needs
  /// [GoRoute] features that [AppRoute.create] does not expose.
  static CustomTransitionPage<T> page<T>({
    required AppPageTransition transition,
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    final Duration duration = _durationFor(transition, context);
    return CustomTransitionPage<T>(
      key: state.pageKey,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder:
          (routeContext, animation, secondaryAnimation, routeChild) => _build(
            transition: transition,
            context: routeContext,
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: routeChild,
          ),
      child: child,
    );
  }

  /// [AppPageTransition.fadeThrough] page — see [AppPageTransitions].
  static CustomTransitionPage<T> fadeThrough<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) => page<T>(
    transition: AppPageTransition.fadeThrough,
    context: context,
    state: state,
    child: child,
  );

  /// [AppPageTransition.sharedAxisHorizontal] page — see [AppPageTransitions].
  static CustomTransitionPage<T> sharedAxisHorizontal<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) => page<T>(
    transition: AppPageTransition.sharedAxisHorizontal,
    context: context,
    state: state,
    child: child,
  );

  /// [AppPageTransition.sharedAxisVertical] page — see [AppPageTransitions].
  static CustomTransitionPage<T> sharedAxisVertical<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) => page<T>(
    transition: AppPageTransition.sharedAxisVertical,
    context: context,
    state: state,
    child: child,
  );

  /// [AppPageTransition.slide] page — see [AppPageTransitions].
  static CustomTransitionPage<T> slide<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) => page<T>(
    transition: AppPageTransition.slide,
    context: context,
    state: state,
    child: child,
  );

  /// [AppPageTransition.scale] page — see [AppPageTransitions].
  static CustomTransitionPage<T> scale<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) => page<T>(
    transition: AppPageTransition.scale,
    context: context,
    state: state,
    child: child,
  );

  /// [AppPageTransition.containerTransform] page — the arriving page's half
  /// of a card-to-details transform. Wrap [child] in an `AppHero` yourself
  /// when only part of it flies, or use [AppContainerTransform.page], which
  /// does both steps.
  static CustomTransitionPage<T> containerTransform<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) => page<T>(
    transition: AppPageTransition.containerTransform,
    context: context,
    state: state,
    child: child,
  );

  /// [AppPageTransition.none] page — see [AppPageTransitions].
  static CustomTransitionPage<T> none<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) => page<T>(
    transition: AppPageTransition.none,
    context: context,
    state: state,
    child: child,
  );

  static Duration _durationFor(
    AppPageTransition transition,
    BuildContext context,
  ) {
    if (transition == AppPageTransition.none) return Duration.zero;
    if (MediaQuery.disableAnimationsOf(context)) return Duration.zero;
    return AppDurations.normal;
  }

  static Widget _build({
    required AppPageTransition transition,
    required BuildContext context,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    final Widget visual = switch (transition) {
      AppPageTransition.fadeThrough => _fadeThrough(
        context,
        animation,
        secondaryAnimation,
        child,
      ),
      AppPageTransition.sharedAxisHorizontal => _sharedAxis(
        context,
        animation,
        secondaryAnimation,
        child,
        incoming: AppAnimationConstants.slideFromEnd,
        outgoing: AppAnimationConstants.slideFromStart,
      ),
      AppPageTransition.sharedAxisVertical => _sharedAxis(
        context,
        animation,
        secondaryAnimation,
        child,
        incoming: AppAnimationConstants.slideFromBottom,
        outgoing: AppAnimationConstants.slideFromTop,
      ),
      AppPageTransition.slide => _slide(
        context,
        animation,
        secondaryAnimation,
        child,
      ),
      AppPageTransition.scale => _scale(
        context,
        animation,
        secondaryAnimation,
        child,
      ),
      AppPageTransition.containerTransform => _containerTransform(
        context,
        animation,
        child,
      ),
      AppPageTransition.none => child,
    };
    if (transition == AppPageTransition.none ||
        MediaQuery.disableAnimationsOf(context)) {
      return visual;
    }
    return _BackSwipeHost(child: visual);
  }

  /// Cross-fade with a deliberate gap: the covered page dims out fast
  /// ([AppCurves.enter]) while the entering page blooms late
  /// ([AppCurves.exit]), so a plain background shows between the two — the
  /// fade-through pattern.
  static Widget _fadeThrough(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final CurveTween Function(Curve) ease = _easingOf(context);
    return FadeTransition(
      opacity: animation.drive(
        Tween<double>(
          begin: AppAnimationConstants.fadeOpacityBegin,
          end: AppAnimationConstants.fadeOpacityEnd,
        ).chain(ease(AppCurves.exit)),
      ),
      child: FadeTransition(
        opacity: secondaryAnimation.drive(
          Tween<double>(
            begin: AppAnimationConstants.fadeOpacityEnd,
            end: AppAnimationConstants.fadeOpacityBegin,
          ).chain(ease(AppCurves.enter)),
        ),
        child: child,
      ),
    );
  }

  /// Shared-axis slide: the page entering from [incoming] fades and glides to
  /// rest while the covered page glides to [outgoing] and dims away.
  static Widget _sharedAxis(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child, {
    required Offset incoming,
    required Offset outgoing,
  }) {
    final CurveTween Function(Curve) ease = _easingOf(context);
    return FadeTransition(
      opacity: animation.drive(
        Tween<double>(
          begin: AppAnimationConstants.fadeOpacityBegin,
          end: AppAnimationConstants.fadeOpacityEnd,
        ).chain(ease(AppCurves.enter)),
      ),
      child: FadeTransition(
        opacity: secondaryAnimation.drive(
          Tween<double>(
            begin: AppAnimationConstants.fadeOpacityEnd,
            end: AppAnimationConstants.fadeOpacityBegin,
          ).chain(ease(AppCurves.exit)),
        ),
        child: SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: incoming,
              end: Offset.zero,
            ).chain(ease(AppCurves.standard)),
          ),
          textDirection: Directionality.of(context),
          child: SlideTransition(
            position: secondaryAnimation.drive(
              Tween<Offset>(
                begin: Offset.zero,
                end: outgoing,
              ).chain(ease(AppCurves.standard)),
            ),
            textDirection: Directionality.of(context),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Directional push: the incoming page slides in from the end with a quick
  /// fade, the covered page parallaxes toward the start and stays opaque.
  static Widget _slide(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final CurveTween Function(Curve) ease = _easingOf(context);
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: AppAnimationConstants.slideFromEnd,
          end: Offset.zero,
        ).chain(ease(AppCurves.enter)),
      ),
      textDirection: Directionality.of(context),
      child: FadeTransition(
        opacity: animation.drive(
          Tween<double>(
            begin: AppAnimationConstants.fadeOpacityBegin,
            end: AppAnimationConstants.fadeOpacityEnd,
          ).chain(ease(AppCurves.enter)),
        ),
        child: SlideTransition(
          position: secondaryAnimation.drive(
            Tween<Offset>(
              begin: Offset.zero,
              end: AppAnimationConstants.slideFromStart,
            ).chain(ease(AppCurves.exit)),
          ),
          textDirection: Directionality.of(context),
          child: child,
        ),
      ),
    );
  }

  /// Zoom: the incoming page rises from [AppAnimationConstants.scaleInBegin]
  /// with a fade while the covered page shrinks and dims away.
  static Widget _scale(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final CurveTween Function(Curve) ease = _easingOf(context);
    return FadeTransition(
      opacity: animation.drive(
        Tween<double>(
          begin: AppAnimationConstants.fadeOpacityBegin,
          end: AppAnimationConstants.fadeOpacityEnd,
        ).chain(ease(AppCurves.enter)),
      ),
      child: FadeTransition(
        opacity: secondaryAnimation.drive(
          Tween<double>(
            begin: AppAnimationConstants.fadeOpacityEnd,
            end: AppAnimationConstants.fadeOpacityBegin,
          ).chain(ease(AppCurves.exit)),
        ),
        child: ScaleTransition(
          scale: animation.drive(
            Tween<double>(
              begin: AppAnimationConstants.scaleInBegin,
              end: AppAnimationConstants.scaleInEnd,
            ).chain(ease(AppCurves.enter)),
          ),
          child: ScaleTransition(
            scale: secondaryAnimation.drive(
              Tween<double>(
                begin: AppAnimationConstants.scaleInEnd,
                end: AppAnimationConstants.scaleInBegin,
              ).chain(ease(AppCurves.exit)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Container transform: the arriving page fades in with [AppCurves.enter]
  /// while the page it covers is left untouched, so the container flying
  /// between the two routes (an `AppHero` on each side) is the only motion on
  /// screen. The covered page stays still because its own transitionsBuilder
  /// is this one too, and it ignores `secondaryAnimation`.
  static Widget _containerTransform(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    final CurveTween Function(Curve) ease = _easingOf(context);
    return FadeTransition(
      opacity: animation.drive(
        Tween<double>(
          begin: AppAnimationConstants.fadeOpacityBegin,
          end: AppAnimationConstants.fadeOpacityEnd,
        ).chain(ease(AppCurves.enter)),
      ),
      child: child,
    );
  }

  /// Returns the curve driver for one build: normally it applies [curve]
  /// to time, but while a back-swipe drives the route controller by hand it
  /// stays linear so the page tracks the finger (the Cupertino transition
  /// switches to linear for the same reason).
  static CurveTween Function(Curve) _easingOf(BuildContext context) {
    final ModalRoute<Object?>? route = ModalRoute.of(context);
    if (route == null ||
        route.navigator == null ||
        !route.popGestureInProgress) {
      return (Curve curve) => CurveTween(curve: curve);
    }
    return (Curve curve) => CurveTween(curve: AppCurves.linear);
  }
}

/// Wraps a transition with the framework's iOS edge-swipe detector.
///
/// [CustomTransitionPage]'s route ships no back-swipe support — the
/// detector lives in `CupertinoRouteTransitionMixin.buildTransitions` — so
/// this host calls the framework's `buildPageTransitions` with fixed
/// "at rest" animations: its Cupertino slide becomes a no-op and only its
/// `_CupertinoBackGestureDetector` remains around our own transition,
/// keeping native drag, velocity and cancel behaviour (and RTL edge
/// mirroring) for free.
class _BackSwipeHost extends StatelessWidget {
  const _BackSwipeHost({required this.child});

  /// The transition widgets this host wraps.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Accessibility setting: no interactive gesture that could animate.
    if (MediaQuery.disableAnimationsOf(context)) return child;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
      default:
        return child;
    }
    final ModalRoute<Object?>? route = ModalRoute.of(context);
    if (route is! PageRoute<Object?>) return child;
    return CupertinoRouteTransitionMixin.buildPageTransitions<Object?>(
      route,
      context,
      const AlwaysStoppedAnimation<double>(1.0),
      const AlwaysStoppedAnimation<double>(0.0),
      child,
    );
  }
}
