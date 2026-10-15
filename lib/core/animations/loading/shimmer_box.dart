import 'package:flutter/widgets.dart';

import 'package:orbit/core/animations/tokens/app_animation_constants.dart';
import 'package:orbit/core/responsive/responsive.dart';

import 'placeholder_colors.dart';

/// Shape variants shared by [ShimmerBox] and [PulsingPlaceholder].
enum PlaceholderShape {
  /// A rounded rectangle. Size it with `width` / `height`; unconstrained uses
  /// fall back to the parent's constraints.
  rectangle,

  /// A circle of `width ?? height ?? ` [AppAnimationConstants.skeletonAvatarSize].
  circle,

  /// A pill-shaped text line of height
  /// `height ?? ` [AppAnimationConstants.skeletonTextLineHeight].
  textLine,
}

/// A single placeholder box used to compose skeleton screens.
///
/// Alone it paints the static, theme-derived placeholder color. Inside a
/// `ShimmerScope` it is recolored by the scope's one shared sweep gradient,
/// so a whole screen of boxes shimmers from a single animation controller —
/// [ShimmerBox] itself never owns a ticker.
///
/// ```dart
/// ShimmerScope(
///   child: Column(
///     children: [
///       const ShimmerBox.circle(width: 40),
///       const ShimmerBox.textLine(width: 200),
///       const ShimmerBox(height: 120),
///     ],
///   ),
/// )
/// ```
///
/// Note that the sweep flattens fully opaque shapes that overlap into one
/// tint; keep skeleton boxes beside each other, not stacked, or use
/// `PulsingPlaceholder` for layered compositions.
class ShimmerBox extends StatelessWidget {
  /// A rounded rectangle of [AppAnimationConstants.skeletonBoxRadius].
  const ShimmerBox({super.key, this.width, this.height, this.color})
    : _shape = PlaceholderShape.rectangle;

  /// A circle; defaults to [AppAnimationConstants.skeletonAvatarSize].
  const ShimmerBox.circle({super.key, this.width, this.height, this.color})
    : _shape = PlaceholderShape.circle;

  /// A pill-shaped line; defaults to [AppAnimationConstants.skeletonTextLineHeight].
  const ShimmerBox.textLine({super.key, this.width, this.height, this.color})
    : _shape = PlaceholderShape.textLine;

  /// Optional width in logical pixels; `null` follows the parent constraints.
  final double? width;

  /// Optional height in logical pixels; `null` follows the shape's default or
  /// the parent constraints.
  final double? height;

  /// Optional override of the theme-derived [PlaceholderColors.baseOf] fill.
  final Color? color;

  /// The rendered shape variant.
  PlaceholderShape get shape => _shape;
  final PlaceholderShape _shape;

  @override
  Widget build(BuildContext context) {
    final fill = color ?? PlaceholderColors.baseOf(context);
    switch (_shape) {
      case PlaceholderShape.rectangle:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(
              Responsive.radius(AppAnimationConstants.skeletonBoxRadius),
            ),
          ),
        );
      case PlaceholderShape.circle:
        final size =
            width ??
            height ??
            Responsive.adapt(AppAnimationConstants.skeletonAvatarSize);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
        );
      case PlaceholderShape.textLine:
        final lineHeight =
            height ??
            Responsive.adapt(AppAnimationConstants.skeletonTextLineHeight);
        return Container(
          width: width,
          height: lineHeight,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(lineHeight / 2),
          ),
        );
    }
  }
}
