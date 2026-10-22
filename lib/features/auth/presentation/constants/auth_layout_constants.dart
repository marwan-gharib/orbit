import 'package:orbit/core/responsive/responsive.dart';

/// Auth-only dimensions and opacity values that are not part of the shared
/// token scale (RESP-1). Every value runs through [Responsive] so the auth
/// screens scale like the rest of the app, in both orientations.
abstract final class AuthLayout {
  /// Widest the auth content may grow on tablets and in landscape.
  static double get contentMaxWidth => Responsive.width(420);

  /// Side of the square brand badge above the title.
  static double get brandMarkSize => Responsive.adapt(40);

  /// Glyph inside the brand badge.
  static double get brandMarkIconSize => Responsive.adapt(22);

  /// Diameter of a soft background glow.
  static double get glowSize => Responsive.adapt(320);

  /// Offset that pushes a glow half outside the nearest corner.
  static double get glowOffset => -glowSize / 2;

  /// Opacity of a glow at its centre.
  static const double glowStartOpacity = 0.45;

  /// Opacity of a glow at its edge.
  static const double glowEndOpacity = 0.2;

  /// Diameter of the pending-approval hero orbit stage.
  static double get heroSize => Responsive.adapt(180);

  /// Diameter of the employee dot orbiting the hero.
  static double get heroDotSize => Responsive.adapt(14);

  /// Diameter of the badge at the centre of the hero.
  static double get heroCenterSize => Responsive.adapt(96);

  /// Glyph inside the hero's centre badge.
  static double get heroCenterIconSize => Responsive.adapt(40);

  /// Stroke width of the hero's outer ring.
  static double get heroRingStroke => Responsive.adapt(2);

  /// Opacity of the hero's outer ring.
  static const double heroRingOpacity = 0.25;

  /// Opacity of the hero centre badge fill.
  static const double heroCenterFillOpacity = 0.12;

  /// Diameter of one approval-stepper dot.
  static double get stepperDotSize => Responsive.adapt(28);

  /// Thickness of the line connecting two stepper dots.
  static double get stepperLineThickness => Responsive.adapt(2);

  /// Glyph inside a completed stepper dot.
  static double get stepperIconSize => Responsive.adapt(16);

  /// Diameter of the active stepper dot's inner marker.
  static double get stepperActiveMarkerSize => Responsive.adapt(10);

  /// Diameter of a password-checklist marker.
  static double get checklistMarkerSize => Responsive.adapt(18);

  /// Height of the password-strength bar.
  static double get strengthBarHeight => Responsive.adapt(8);

  /// Thickness of the navigation-link underline.
  static double get linkUnderlineThickness => Responsive.adapt(2);

  /// Minimum touch height of an inline text link.
  static double get minTouchTarget => Responsive.adapt(48);

  /// Glyph inside the error banner.
  static double get errorIconSize => Responsive.adapt(20);

  /// Border width of the error banner.
  static double get errorBorderWidth => Responsive.adapt(1);

  /// Opacity of the error banner border.
  static const double errorBorderOpacity = 0.4;

  /// Glyph inside an informational pending notice.
  static double get noticeIconSize => Responsive.adapt(20);

  /// Diameter of the halo behind the terminal-moment glyph.
  static double get momentHaloSize => Responsive.adapt(72);

  /// Glyph inside the terminal-moment halo.
  static double get momentIconSize => Responsive.adapt(36);

  /// Opacity of the terminal-moment halo fill.
  static const double momentHaloOpacity = 0.18;

  /// Diameter of the approval-stepper decision icon.
  static double get decisionIconSize => Responsive.adapt(18);
}
