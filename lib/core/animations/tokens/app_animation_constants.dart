import 'dart:ui' show Offset;

/// Numeric tokens shared by the animation widgets (ARCH-10: values live here,
/// never inside a widget).
///
/// Slide offsets are fractions of the child's size, which keeps entrances
/// responsive: a small list row moves a few pixels, a full-screen surface
/// moves more, with one token.
abstract final class AppAnimationConstants {
  /// Scale of a surface while it is pressed (tap feedback).
  static const double tapScale = 0.96;

  /// [SlideIn] begin offsets in LTR space; `start`/`end` are mirrored
  /// automatically when the direction is RTL.
  static const Offset slideFromTop = Offset(0.0, -0.08);
  static const Offset slideFromBottom = Offset(0.0, 0.08);
  static const Offset slideFromStart = Offset(-0.08, 0.0);
  static const Offset slideFromEnd = Offset(0.08, 0.0);

  /// Opacity bounds of every fade: starts fully transparent, ends fully
  /// opaque.
  static const double fadeOpacityBegin = 0.0;
  static const double fadeOpacityEnd = 1.0;

  /// Scale bounds of [ScaleIn]: a subtle zoom that settles at natural size.
  static const double scaleInBegin = 0.95;
  static const double scaleInEnd = 1.0;

  /// Blur sigma in logical pixels that [BlurIn] starts from before the child
  /// resolves to sharp.
  static const double blurSigma = 8.0;

  /// A staggered entrance stops growing its delay after this item index so
  /// the tail of a long list is not kept waiting.
  static const int maxStaggerIndex = 10;

  /// Turns the arrow of an [ExpandableSection] sweeps between the collapsed
  /// and the expanded state: half a turn flips a down-facing chevron up.
  static const double expandArrowHalfTurn = 0.5;

  /// First-kick travel of [ShakeWidget] in logical pixels. Fixed, not a
  /// fraction of the child, so a small field shakes as visibly as a
  /// full-width card.
  static const double shakeAmplitude = 8.0;

  /// Oscillations of [ShakeWidget] before it settles; 4 reads as an error
  /// nudge without turning playful.
  static const int shakeOscillations = 4;

  /// Peak scale of [PulseWidget]'s breathing loop (1.0 is rest).
  static const double pulseScale = 1.06;

  /// Opacity [PulseWidget] fades to at the top of each breath (1.0 is rest).
  static const double pulseOpacityMin = 0.7;

  /// Width of an active [PageIndicator] dot as a multiple of the dot size:
  /// the pill the morph grows into (1.0 would be a plain circle).
  static const double pageIndicatorActiveDotWidthFactor = 3.0;

  /// Peak scale of [BounceWidget]'s one-shot pop (1.0 is rest).
  static const double bounceScale = 1.12;

  /// Phase split of [BounceWidget]'s one-shot as relative weights: the rise
  /// is quicker than the settle.
  static const double bounceRiseWeight = 2.0;
  static const double bounceSettleWeight = 3.0;

  /// Placeholder fills (skeleton boxes, pulses) and the shimmer's rest color
  /// sit this far toward `onSurface`, so light and dark themes — and any
  /// custom scheme — both read correctly without a hardcoded color.
  static const double placeholderBaseOpacity = 0.08;

  /// The shimmer's sweeping highlight band sits this far toward `onSurface`.
  static const double placeholderHighlightOpacity = 0.2;

  /// Width of the shimmer's bright band as a fraction of the box it sweeps
  /// across.
  static const double shimmerSweepBand = 0.4;

  /// Opacity bounds of [PulsingPlaceholder]: full strength at rest, dimmed
  /// at the trough of the pulse.
  static const double pulsingPlaceholderMaxOpacity = 1.0;
  static const double pulsingPlaceholderMinOpacity = 0.35;

  /// Height of one pill-shaped skeleton text line, in logical pixels.
  static const double skeletonTextLineHeight = 12.0;

  /// Diameter of a circular skeleton avatar when no size is given.
  static const double skeletonAvatarSize = 48.0;

  /// Vertical gap between the lines of a skeleton text block.
  static const double skeletonBlockSpacing = 12.0;

  /// Horizontal gap between a skeleton list tile's avatar and its lines.
  static const double skeletonTileSpacing = 16.0;

  /// Inner padding of [SkeletonCard].
  static const double skeletonCardPadding = 16.0;

  /// Corner radius of a plain rectangular skeleton box.
  static const double skeletonBoxRadius = 8.0;

  /// Corner radius of [SkeletonCard].
  static const double skeletonCardRadius = 12.0;

  /// Opacity of [SkeletonCard]'s surface: half of [placeholderBaseOpacity],
  /// so the card's text lines stay visible through the shimmer sweep, which
  /// flattens every fully opaque shape under it to one tint.
  static const double skeletonCardFillOpacity = 0.04;

  /// Default number of lines in [SkeletonTextBlock] and [SkeletonCard].
  static const int skeletonTextBlockDefaultLines = 3;

  /// Widths (fractions of the available width) cycled through by the lines of
  /// a [SkeletonTextBlock], so a paragraph skeleton never looks ruled.
  static const List<double> skeletonTextLineWidths = <double>[
    1.0,
    0.9,
    0.75,
    0.85,
  ];

  /// [SkeletonListTile] title and subtitle widths, as fractions of the space
  /// next to the avatar.
  static const double skeletonTileTitleWidth = 0.6;
  static const double skeletonTileSubtitleWidth = 0.4;

  /// Default height of [AnimatedProgressBar], in logical pixels.
  static const double progressBarHeight = 6.0;

  /// Bounds of a determinate [AnimatedProgressBar] value.
  static const double progressBarMin = 0.0;
  static const double progressBarMax = 1.0;

  /// Opacity of [AnimatedProgressBar]'s track color.
  static const double progressBarTrackOpacity = 0.08;

  /// Width of the traveling indeterminate segment as a fraction of the track.
  static const double progressBarSegmentWidth = 0.4;

  /// Controller value that freezes the indeterminate segment centered: the
  /// travel runs symmetrically from -segment past the track, so its midpoint
  /// is the center.
  static const double progressBarIndeterminateRest = 0.5;

  /// `scroll/` group: share of a child that must enter the viewport before
  /// its reveal entrance starts.
  static const double revealVisibleFraction = 0.15;

  /// `scroll/` group: how much of the scroll speed a parallax background
  /// gives up (0 = glued to the content, 1 = fixed to the viewport).
  static const double parallaxDefaultFactor = 0.35;

  /// `scroll/` group: scroll distance (logical pixels) over which the app
  /// bar fades in; roughly one toolbar height.
  static const double appBarFadeThreshold = 80.0;

  /// `scroll/` group: elevation (logical pixels) the app bar reaches once
  /// fully faded in.
  static const double appBarFadeElevation = 4.0;

  /// `scroll/` group: scale of a collapsing header's title while fully
  /// expanded; eases down to 1 at the toolbar. FlexibleSpaceBar's own 1.5
  /// default is too flashy for Orbit's speed profile.
  static const double collapsingTitleScale = 1.2;

  /// `scroll/` group: zoom of a collapsing header's background slot while
  /// fully expanded, easing back to 1 on collapse. Stays above 1 so the
  /// background never uncovers its edges while it fades out.
  static const double collapsingBackgroundScale = 1.08;

  /// `overlays/` group: gap between a leading icon and its text inside an
  /// overlay surface (`AppSnackbar`, icon rows of dialogs and sheets).
  static const double overlayIconGap = 12.0;
}
