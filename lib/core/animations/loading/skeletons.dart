import 'package:flutter/widgets.dart';

import 'package:orbit/core/animations/tokens/app_animation_constants.dart';
import 'package:orbit/core/responsive/responsive.dart';

import 'placeholder_colors.dart';
import 'shimmer_box.dart';

/// A paragraph-shaped skeleton: [lines] pill-shaped text lines, the tail ones
/// shorter than the full width, built from `ShimmerBox.textLine`.
///
/// Requires bounded width (e.g. inside a `Column`, `Expanded` or padded
/// screen) so the line fractions have something to fraction.
///
/// ```dart
/// SkeletonTextBlock()            // three lines
/// SkeletonTextBlock(lines: 5)
/// ```
class SkeletonTextBlock extends StatelessWidget {
  const SkeletonTextBlock({
    super.key,
    this.lines = AppAnimationConstants.skeletonTextBlockDefaultLines,
  }) : assert(lines > 0);

  /// Number of text lines to render.
  final int lines;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final widths = AppAnimationConstants.skeletonTextLineWidths;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines; i++) ...[
            if (i > 0)
              SizedBox(
                height: Responsive.adapt(
                  AppAnimationConstants.skeletonBlockSpacing,
                ),
              ),
            ShimmerBox.textLine(
              width: _fractionOf(
                constraints.maxWidth,
                widths[i % widths.length],
              ),
            ),
          ],
        ],
      );
    },
  );
}

/// The shape of a list row while it loads: a circular avatar next to a title
/// and a subtitle line, built from `ShimmerBox`.
///
/// ```dart
/// SkeletonListTile()
/// SkeletonListTile(titleWidth: 0.5, subtitleWidth: 0.3)
/// ```
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({
    super.key,
    this.titleWidth = AppAnimationConstants.skeletonTileTitleWidth,
    this.subtitleWidth = AppAnimationConstants.skeletonTileSubtitleWidth,
  });

  /// Title line width as a fraction of the space next to the avatar.
  final double titleWidth;

  /// Subtitle line width as a fraction of the space next to the avatar.
  final double subtitleWidth;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const ShimmerBox.circle(),
      SizedBox(
        width: Responsive.adapt(AppAnimationConstants.skeletonTileSpacing),
      ),
      Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox.textLine(
                width: _fractionOf(constraints.maxWidth, titleWidth),
              ),
              SizedBox(
                height: Responsive.adapt(
                  AppAnimationConstants.skeletonBlockSpacing,
                ),
              ),
              ShimmerBox.textLine(
                width: _fractionOf(constraints.maxWidth, subtitleWidth),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

/// A card-shaped skeleton: a rounded surface with a [SkeletonTextBlock]
/// inside.
///
/// The surface is painted at half placeholder emphasis so the text lines
/// stay visible through a `ShimmerScope` sweep, which flattens fully opaque
/// overlapping shapes into one tint.
///
/// ```dart
/// SkeletonCard()
/// SkeletonCard(lines: 4)
/// ```
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
    this.lines = AppAnimationConstants.skeletonTextBlockDefaultLines,
  }) : assert(lines > 0);

  /// Number of text lines inside the card.
  final int lines;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(
      Responsive.adapt(AppAnimationConstants.skeletonCardPadding),
    ),
    decoration: BoxDecoration(
      color: PlaceholderColors.sweepBaseOf(context)
          .withValues(alpha: AppAnimationConstants.skeletonCardFillOpacity),
      borderRadius: BorderRadius.circular(
        Responsive.radius(AppAnimationConstants.skeletonCardRadius),
      ),
    ),
    child: SkeletonTextBlock(lines: lines),
  );
}

double? _fractionOf(double? available, double fraction) =>
    available != null && available.isFinite ? available * fraction : null;
