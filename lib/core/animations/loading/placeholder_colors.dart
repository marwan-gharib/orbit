import 'package:flutter/material.dart';

import 'package:orbit/core/animations/tokens/app_animation_constants.dart';

/// Theme-derived colors of every loading placeholder (skeleton boxes, pulses,
/// the shimmer sweep).
///
/// Everything is computed from `ColorScheme.onSurface` and `surface`, so
/// light and dark themes — and any custom scheme — read correctly without a
/// single hardcoded color (UI-1).
abstract final class PlaceholderColors {
  /// Opaque fill of a placeholder box: the shimmer's rest color painted over
  /// the surface. Identical with and without a `ShimmerScope`, which keeps
  /// reduced-motion rendering pixel-consistent with the shimmer's rest state.
  ///
  /// ```dart
  /// DecoratedBox(
  ///   decoration: BoxDecoration(color: PlaceholderColors.baseOf(context)),
  /// )
  /// ```
  static Color baseOf(BuildContext context) => Color.alphaBlend(
    sweepBaseOf(context),
    Theme.of(context).colorScheme.surface,
  );

  /// Rest color of the shimmer gradient: the band starts and ends at this
  /// tint before it sweeps through [sweepHighlightOf].
  static Color sweepBaseOf(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface
          .withValues(alpha: AppAnimationConstants.placeholderBaseOpacity);

  /// Bright band of the shimmer sweep, and the strongest tint any placeholder
  /// ever shows while loading.
  static Color sweepHighlightOf(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface
          .withValues(alpha: AppAnimationConstants.placeholderHighlightOpacity);
}
