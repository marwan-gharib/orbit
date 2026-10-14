import 'package:flutter/widgets.dart';

import '../../constants/hero_tags.dart';
import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';

/// Tag namespace shared by both ends of a Hero flight in Orbit.
///
/// Two [Hero]s fly only when their tags are identical, so both ends have to
/// build the tag the same way: this is that one way. Ids stay plain feature
/// values (an order id, a product sku); the namespace keeps them from
/// colliding with the tag of a library widget that ships its own `Hero`.
///
/// ```dart
/// AppHeroTag.of(order.id); // 'orbit.hero.<the id>'
/// ```
abstract final class AppHeroTag {
  /// The flight tag Orbit uses for [id].
  static String of(Object id) => '${HeroTags.prefix}$id';
}

/// A [Hero] with Orbit's standard flight: namespaced tag, the app's enter and
/// exit curves, a cross-fading shuttle, and a flight that also runs while a
/// back swipe drags the route.
///
/// Wrap the *same* [id] on both sides of a navigation — the card in the list
/// and the container on the details screen — and the container grows from one
/// to the other. The page half of that move (the rest of the arriving screen
/// fading in behind the flying container, with the covered page held still)
/// is `AppPageTransition.containerTransform`.
///
/// ```dart
/// // List: the card that will grow.
/// AppHero(
///   id: order.id,
///   child: OrderCard(order: order),
/// )
///
/// // Details: the container it grows into.
/// AppHero(
///   id: order.id,
///   child: OrderSummary(order: order),
/// )
/// ```
///
/// How long the flight lasts belongs to the route: the flight runs on the
/// route's own animation, so it uses `transitionDuration`, eases with
/// [AppCurves.enter] on push and [AppCurves.exit] on pop, and collapses to
/// nothing under `MediaQuery.disableAnimations`. The shuttle is built in the
/// overlay, so it is wrapped in a [RepaintBoundary] to keep its per-frame
/// crossfade out of repainting the page underneath.
class AppHero extends StatelessWidget {
  /// Creates a Hero whose flight uses Orbit's standard profile.
  const AppHero({
    super.key,
    required this.id,
    required this.child,
    this.placeholderBuilder,
  });

  /// The value both ends of the flight share; the tag actually flown is
  /// [AppHeroTag.of] this id.
  final Object id;

  /// The content that flies — a card, a thumbnail, a summary panel.
  final Widget child;

  /// Optional stand-in shown in the route's layout while this Hero is in the
  /// air (its default is the framework's: the same size, empty). Use it to
  /// keep, say, a dimmed copy of the card visible where it used to sit.
  final HeroPlaceholderBuilder? placeholderBuilder;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Hero(
      tag: AppHeroTag.of(id),
      curve: AppCurves.enter,
      reverseCurve: AppCurves.exit,
      transitionOnUserGestures: true,
      flightShuttleBuilder: flightShuttle,
      placeholderBuilder: placeholderBuilder,
      child: child,
    ),
  );

  /// The shuttle every [AppHero] flight carries: the leaving container and
  /// the arriving one stacked and cross-faded across the whole flight, so the
  /// card's content hands over to the screen's instead of popping.
  ///
  /// Both layers are built at the size the flight currently has, which is the
  /// reason a container transform should fly a bounded surface (a card, a
  /// summary panel) rather than a screen whose layout cannot shrink.
  ///
  /// Safe-area padding follows the flight the way the framework's own shuttle
  /// does, so content that sat under an app bar or a notch does not jump as
  /// it changes sides.
  static Widget flightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final Hero fromHero = fromHeroContext.widget as Hero;
    final Hero toHero = toHeroContext.widget as Hero;
    // The animation reads 0→1 on a push and 1→0 on a pop, so `progress` is
    // "how far the arriving container has taken over" in both directions.
    final bool pushing = flightDirection == HeroFlightDirection.push;
    final Widget arriving = pushing ? toHero.child : fromHero.child;
    final Widget leaving = pushing ? fromHero.child : toHero.child;

    final EdgeInsets fromPadding =
        MediaQuery.maybeOf(fromHeroContext)?.padding ?? EdgeInsets.zero;
    final EdgeInsets toPadding =
        MediaQuery.maybeOf(toHeroContext)?.padding ?? EdgeInsets.zero;
    final EdgeInsetsTween padding = EdgeInsetsTween(
      begin: pushing ? fromPadding : toPadding,
      end: pushing ? toPadding : fromPadding,
    );
    final MediaQueryData? destinationMedia = MediaQuery.maybeOf(toHeroContext);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        child: arriving,
        builder: (BuildContext context, Widget? child) {
          final double progress = animation.value;
          final Widget layers = ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: AppAnimationConstants.fadeOpacityEnd - progress,
                  child: leaving,
                ),
                Opacity(opacity: progress, child: child!),
              ],
            ),
          );
          if (destinationMedia == null) return layers;
          return MediaQuery(
            data: destinationMedia.copyWith(
              padding: padding.evaluate(animation),
            ),
            child: layers,
          );
        },
      ),
    );
  }
}
