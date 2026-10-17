import 'package:flutter/widgets.dart';

/// Base contract for all onboarding illustrations.
/// Driven by [progress] (0.0 = entrance start, 1.0 = entrance complete)
/// and [isActive] (true = slide is center, runs idle loop).
abstract class OnboardingIllustration extends Widget {
  const OnboardingIllustration({
    required this.progress,
    required this.isActive,
    required this.size,
    super.key,
  });

  /// Entrance progress: 0.0 → 1.0 during the slide's entrance animation.
  final double progress;

  /// Whether this slide is currently the active (center) page.
  /// When true, idle loops run; when false, all animation pauses.
  final bool isActive;

  /// Allocated size from the layout (for responsive painting).
  final Size size;
}
