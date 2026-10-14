import 'package:flutter/widgets.dart';

import 'package:orbit/core/animations/tokens/app_animation_constants.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';

import 'shimmer_box.dart';

/// A placeholder that gently pulses in opacity: the lighter, cheaper
/// alternative to a `ShimmerScope` of `ShimmerBox`es.
///
/// **Shimmer or pulse?** Use shimmer (`ShimmerScope` + `ShimmerBox`) when a
/// screen shows a handful of shapes and the sweep helps them read as "the
/// content is loading". Use this pulse inside long scrolling lists or large
/// skeletons: it is one composited opacity fade the GPU interpolates, with
/// no per-frame re-rasterization, at the cost of a quieter effect.
///
/// Like `ShimmerBox`, the fill is theme-derived and adapts to light/dark.
///
/// ```dart
/// PulsingPlaceholder.circle(width: 40)
/// PulsingPlaceholder.textLine(width: 200)
/// PulsingPlaceholder(height: 120)
/// ```
///
/// With `MediaQuery.disableAnimations` it holds full opacity (the pulse's
/// final state) and never ticks.
class PulsingPlaceholder extends StatefulWidget {
  /// A rounded rectangle of [AppAnimationConstants.skeletonBoxRadius].
  const PulsingPlaceholder({super.key, this.width, this.height, this.color})
    : _shape = PlaceholderShape.rectangle;

  /// A circle; defaults to [AppAnimationConstants.skeletonAvatarSize].
  const PulsingPlaceholder.circle({
    super.key,
    this.width,
    this.height,
    this.color,
  }) : _shape = PlaceholderShape.circle;

  /// A pill-shaped line; defaults to [AppAnimationConstants.skeletonTextLineHeight].
  const PulsingPlaceholder.textLine({
    super.key,
    this.width,
    this.height,
    this.color,
  }) : _shape = PlaceholderShape.textLine;

  /// Optional width in logical pixels; `null` follows the parent constraints.
  final double? width;

  /// Optional height in logical pixels; `null` follows the shape's default or
  /// the parent constraints.
  final double? height;

  /// Optional override of the theme-derived placeholder fill.
  final Color? color;

  final PlaceholderShape _shape;

  @override
  State<PulsingPlaceholder> createState() => _PulsingPlaceholderState();
}

class _PulsingPlaceholderState extends State<PulsingPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.pulse,
    );
    _pulse = Tween<double>(
      begin: AppAnimationConstants.pulsingPlaceholderMaxOpacity,
      end: AppAnimationConstants.pulsingPlaceholderMinOpacity,
    ).chain(CurveTween(curve: AppCurves.pulse)).animate(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      // Freeze on the tween's start value: full opacity, the pulse's rest
      // and final state.
      _controller.stop();
      _controller.value = 0.0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = switch (widget._shape) {
      PlaceholderShape.rectangle => ShimmerBox(
        width: widget.width,
        height: widget.height,
        color: widget.color,
      ),
      PlaceholderShape.circle => ShimmerBox.circle(
        width: widget.width,
        height: widget.height,
        color: widget.color,
      ),
      PlaceholderShape.textLine => ShimmerBox.textLine(
        width: widget.width,
        height: widget.height,
        color: widget.color,
      ),
    };
    return FadeTransition(opacity: _pulse, child: box);
  }
}
