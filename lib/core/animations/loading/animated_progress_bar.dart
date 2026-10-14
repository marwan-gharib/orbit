import 'package:flutter/material.dart';

import 'package:orbit/core/animations/tokens/app_animation_constants.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';

/// A progress bar that eases between values, determinate or indeterminate.
///
/// Pass [progress] (0.0..1.0) for a determinate bar: the fill starts at the
/// given value, then eases from its current width to each new one over
/// [duration] with [curve], filling from the leading edge (RTL mirrors it
/// automatically). Leave [progress] `null` for an indeterminate bar: a
/// segment travels the track once per [AppDurations.indeterminate] cycle,
/// from the leading edge in both text directions.
///
/// With `MediaQuery.disableAnimations` the determinate fill jumps straight to
/// its value and the indeterminate segment freezes centered — no ticks.
///
/// ```dart
/// AnimatedProgressBar(progress: report.progress)
/// AnimatedProgressBar()                              // indeterminate
/// AnimatedProgressBar(progress: 0.5, height: 8, radius: 4)
/// ```
///
/// Colors default to the theme: `AppColorsExtension.primary` on an
/// `onSurface`-derived track. The bar paints full width, so it needs a
/// bounded-width parent: an `Expanded`, a `SizedBox` or a padded screen
/// slot — never a bare `Row`. The bar is decoration only and announces
/// nothing on its own; wrap it in a localized `Semantics` if screen readers
/// should report progress (UI-4).
class AnimatedProgressBar extends StatefulWidget {
  const AnimatedProgressBar({
    super.key,
    this.progress,
    this.height = AppAnimationConstants.progressBarHeight,
    this.radius,
    this.color,
    this.backgroundColor,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.standard,
  }) : assert(
         progress == null ||
             (progress >= AppAnimationConstants.progressBarMin &&
                 progress <= AppAnimationConstants.progressBarMax),
         'progress must be between 0.0 and 1.0',
       );

  /// Target value in 0.0..1.0; `null` renders the indeterminate mode.
  final double? progress;

  /// Bar height in logical pixels.
  final double height;

  /// Corner radius in logical pixels; `null` renders a pill (half the
  /// height).
  final double? radius;

  /// Fill color; `null` uses the theme's primary color.
  final Color? color;

  /// Track color; `null` uses a theme-derived tint.
  final Color? backgroundColor;

  /// Duration of each determinate value change.
  final Duration duration;

  /// Easing of each determinate value change.
  final Curve curve;

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _drive;
  bool _repeating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _drive = _controller.drive(CurveTween(curve: AppCurves.linear));
    // Start at the given value instead of animating in from zero.
    _controller.value = _target;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.progress != oldWidget.progress) {
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _repeating = false;
      _controller.value = _target;
      return;
    }
    final progress = widget.progress;
    if (progress == null) {
      // The flag, not `isAnimating`, guards the repeat: a determinate tween
      // may still be in flight when the bar switches to indeterminate.
      if (!_repeating) {
        _repeating = true;
        _controller.repeat(period: AppDurations.indeterminate);
      }
      return;
    }
    _repeating = false;
    _controller.animateTo(_target, curve: widget.curve);
  }

  double get _target {
    final progress = widget.progress;
    if (progress == null) {
      return AppAnimationConstants.progressBarIndeterminateRest;
    }
    return progress
        .clamp(
          AppAnimationConstants.progressBarMin,
          AppAnimationConstants.progressBarMax,
        )
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<AppColorsExtension>();
    final fill = widget.color ?? colors?.primary ?? scheme.primary;
    final track =
        widget.backgroundColor ??
        scheme.onSurface.withValues(
          alpha: AppAnimationConstants.progressBarTrackOpacity,
        );
    final cornerRadius = widget.radius ?? widget.height / 2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(cornerRadius),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            // The bar needs a bounded width; this keeps the stack honest
            // about it instead of shrinking to zero.
            const SizedBox.expand(),
            Positioned.fill(child: ColoredBox(color: track)),
            AnimatedBuilder(
              animation: _drive,
              // The painted subtree is constant per mode; only the Align
              // around it is rebuilt on each tick.
              child: _buildFillSubtree(fill),
              builder: (context, child) => widget.progress == null
                  ? Align(
                      alignment: AlignmentDirectional(_segmentAlignment, 0),
                      child: child,
                    )
                  : Align(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: _drive.value,
                      child: child,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFillSubtree(Color fill) {
    final expandingFill = SizedBox.expand(child: ColoredBox(color: fill));
    if (widget.progress != null) {
      return expandingFill;
    }
    return FractionallySizedBox(
      widthFactor: AppAnimationConstants.progressBarSegmentWidth,
      child: expandingFill,
    );
  }

  // In Alignment.x space the track spans -1..1 and a child's free-space
  // placement is x -> (x + 1) / 2 of it, so a child of [segment] of the track
  // wide sits fully outside the start edge at -1 - 2s / (1 - s) and fully
  // outside the end edge at -1 + 2 / (1 - s); the midpoint centers it.
  double get _segmentAlignment {
    const segment = AppAnimationConstants.progressBarSegmentWidth;
    final free = 1.0 - segment;
    final hiddenStart = -1.0 - 2 * segment / free;
    final hiddenEnd = -1.0 + 2 / free;
    return hiddenStart + (hiddenEnd - hiddenStart) * _drive.value;
  }
}
