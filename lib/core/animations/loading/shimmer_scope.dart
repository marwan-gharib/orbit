import 'package:flutter/widgets.dart';

import 'package:orbit/core/animations/tokens/app_animation_constants.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';

import 'placeholder_colors.dart';

/// Geometry of the sliding highlight band that `ShimmerScope` paints.
///
/// The gradient spans one box width in `Alignment.x` space (-1..1); [sweep]
/// slides its bright band from fully outside the leading edge to fully
/// outside the trailing edge. Public mainly so the geometry is unit-testable.
///
/// ```dart
/// final gradient = ShimmerGradient.build(
///   sweep: 0.5,
///   base: PlaceholderColors.sweepBaseOf(context),
///   highlight: PlaceholderColors.sweepHighlightOf(context),
///   band: AppAnimationConstants.shimmerSweepBand,
///   mirrored: Directionality.of(context) == TextDirection.rtl,
/// );
/// ```
abstract final class ShimmerGradient {
  /// Builds the sweep gradient for progress [sweep] (0..1) of the cycle.
  ///
  /// [band] is the bright band's width as a fraction of the swept area.
  /// [mirrored] reverses the travel so RTL text direction sweeps from the
  /// right edge, which is its leading edge.
  static LinearGradient build({
    required double sweep,
    required Color base,
    required Color highlight,
    required double band,
    required bool mirrored,
  }) {
    // Alignment.x spans -1..1 across the box, so the band's center travels
    // from -(1 + band/2) to +(1 + band/2) to fully enter and exit.
    const halfSpan = 1.0;
    final halfBand = band / 2;
    final travel = halfSpan + halfBand;
    final peak = mirrored
        ? travel - sweep * 2 * travel
        : -travel + sweep * 2 * travel;
    // Center of the 0..1 gradient stop axis.
    const midpoint = 0.5;
    return LinearGradient(
      colors: <Color>[base, highlight, base],
      stops: <double>[midpoint - halfBand, midpoint, midpoint + halfBand],
      begin: Alignment(peak - halfSpan, 0),
      end: Alignment(peak + halfSpan, 0),
    );
  }
}

/// Owns the single sweep animation of a skeleton screen and applies one
/// shared shimmer gradient to everything underneath it.
///
/// Wrap a whole skeleton screen once; every `ShimmerBox` inside follows the
/// same controller, so N boxes cost one ticker and one shader layer instead
/// of N of each:
///
/// ```dart
/// ShimmerScope(
///   child: Column(
///     children: [const SkeletonListTile(), const SkeletonCard()],
///   ),
/// )
/// ```
///
/// Only placeholder widgets belong inside: the gradient repaints the whole
/// subtree, so real content placed there would be tinted too. One scope per
/// screen; nesting scopes only stacks layers. The sweep mirrors automatically
/// in RTL, and with `MediaQuery.disableAnimations` the child renders directly
/// in its static placeholder colors.
///
/// **Shimmer or pulse?** The sweep re-rasterizes one layer per frame: it
/// shines on a handful of shapes and reads as "content is loading". Inside
/// long scrolling lists or large skeletons prefer `PulsingPlaceholder`,
/// whose opacity fade is composited by the GPU and never re-rasterizes.
class ShimmerScope extends StatefulWidget {
  const ShimmerScope({super.key, required this.child});

  /// The skeleton subtree to sweep; rebuilt only when the scope rebuilds, not
  /// on animation ticks.
  final Widget child;

  @override
  State<ShimmerScope> createState() => _ShimmerScopeState();
}

class _ShimmerScopeState extends State<ShimmerScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sweep;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _sweep = _controller.drive(CurveTween(curve: AppCurves.linear));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSweep();
  }

  void _syncSweep() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(period: AppDurations.shimmer);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }
    final mirrored = Directionality.of(context) == TextDirection.rtl;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _sweep,
        child: widget.child,
        builder: (context, child) {
          final gradient = ShimmerGradient.build(
            sweep: _sweep.value,
            base: PlaceholderColors.sweepBaseOf(context),
            highlight: PlaceholderColors.sweepHighlightOf(context),
            band: AppAnimationConstants.shimmerSweepBand,
            mirrored: mirrored,
          );
          return ShaderMask(
            // The boxes paint opaque; the gradient carries the alphas, so the
            // sweep tints them without hiding their shapes or their gaps.
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => gradient.createShader(bounds),
            child: child!,
          );
        },
      ),
    );
  }
}
