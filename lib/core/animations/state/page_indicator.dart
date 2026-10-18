import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/extensions/colors_extension.dart';
import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';

/// Row of tappable page dots; the active dot morphs into a pill.
///
/// Each dot sits in a fixed tap-target-height box, so the morph never changes
/// the row's vertical rhythm, and the whole row is centered by the caller.
/// Taps report the dot index through [onTap]; a 48 dp minimum keeps every dot
/// comfortably tappable.
///
/// Dots are ordered by reading direction, so the first page sits at the
/// start edge in both directions. Reduced motion (`MediaQuery.disableAnimations`)
/// jumps the morph instantly instead of animating it.
///
/// ```dart
/// PageIndicator(
///   currentIndex: state.page,
///   pageCount: pages.length,
///   onTap: controller.jumpToPage,
///   semanticsLabel: t.a11y.pageOf,
/// )
/// ```
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.pageCount,
    required this.onTap,
    required this.semanticsLabel,
    this.dotSize,
    this.dotSpacing,
    this.activeDotWidthFactor =
        AppAnimationConstants.pageIndicatorActiveDotWidthFactor,
    this.tapBoxHeight,
    this.activeColor,
    this.inactiveColor,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.spring,
  }) : assert(pageCount >= 0),
       assert(currentIndex >= 0),
       assert(activeDotWidthFactor >= 1.0);

  /// Dot whose morph is completed.
  final int currentIndex;

  /// Number of dots.
  final int pageCount;

  /// Reports the tapped dot's index.
  final ValueChanged<int> onTap;

  /// Localized label per dot (`current`, `total`), one a11y node each.
  final String Function(int current, int total) semanticsLabel;

  /// Diameter of an inactive dot; null uses the small spacing token
  /// ([AppSpacing.sm]).
  final double? dotSize;

  /// Horizontal gap kept between dot tap boxes; null uses the extra-small
  /// spacing token ([AppSpacing.xs]).
  final double? dotSpacing;

  /// Active dot width as a multiple of [dotSize] (the pill).
  final double activeDotWidthFactor;

  /// Height of one dot's tap box; null uses the extra-large spacing token
  /// ([AppSpacing.xxl]), the shared 48 dp touch target.
  final double? tapBoxHeight;

  /// Color of the completed dot; defaults to the theme's primary color.
  final Color? activeColor;

  /// Color of a resting dot; defaults to the theme's surface variant.
  final Color? inactiveColor;

  /// How long one morph runs.
  final Duration duration;

  /// Easing of the morph's implicit chase.
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedDotSize = dotSize ?? AppSpacing.sm;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < pageCount; index++)
          _IndicatorDot(
            key: ValueKey(index),
            isActive: index == currentIndex,
            onTap: () => onTap(index),
            activeColor: activeColor ?? colors.primary,
            inactiveColor: inactiveColor ?? colors.surfaceVariant,
            semanticsLabel: semanticsLabel(index + 1, pageCount),
            dotSize: resolvedDotSize,
            dotSpacing: dotSpacing ?? AppSpacing.xs,
            activeDotWidth: resolvedDotSize * activeDotWidthFactor,
            tapBoxHeight: tapBoxHeight ?? AppSpacing.xxl,
            duration: duration,
            curve: curve,
          ),
      ],
    );
  }
}

class _IndicatorDot extends StatefulWidget {
  const _IndicatorDot({
    required this.isActive,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    required this.semanticsLabel,
    required this.dotSize,
    required this.dotSpacing,
    required this.activeDotWidth,
    required this.tapBoxHeight,
    required this.duration,
    required this.curve,
    super.key,
  });

  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;
  final String semanticsLabel;
  final double dotSize;
  final double dotSpacing;
  final double activeDotWidth;
  final double tapBoxHeight;
  final Duration duration;
  final Curve curve;

  @override
  State<_IndicatorDot> createState() => _IndicatorDotState();
}

class _IndicatorDotState extends State<_IndicatorDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.value = widget.isActive ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(covariant _IndicatorDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = widget.isActive ? 1.0 : 0.0;
    } else if (widget.isActive) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instant = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final p = _controller.value;
        final width = lerpDouble(widget.dotSize, widget.activeDotWidth, p)!;
        final color = Color.lerp(widget.inactiveColor, widget.activeColor, p)!;

        return Semantics(
          label: widget.semanticsLabel,
          button: true,
          selected: widget.isActive,
          child: SizedBox(
            // Full tap-target height; width hugs the pill so dots keep a
            // compact rhythm.
            height: widget.tapBoxHeight,
            width: width + 2 * widget.dotSpacing,
            child: GestureDetector(
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: AnimatedContainer(
                  duration: instant ? Duration.zero : widget.duration,
                  curve: widget.curve,
                  width: width,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(widget.dotSize / 2),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
