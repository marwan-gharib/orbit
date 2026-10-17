import 'package:flutter/widgets.dart';

/// Layer keys for the onboarding illustration stacks, so tests can assert
/// per-layer presence, opacity and geometry without hunting internals.
abstract final class OnboardingIllustrationKeys {
  // Slide 1 — Projects.
  static const Key s1Board = Key('onboarding_s1_board');
  static const Key s1CardA = Key('onboarding_s1_card_a');
  static const Key s1CardB = Key('onboarding_s1_card_b');
  static const Key s1CardC = Key('onboarding_s1_card_c');
  static const Key s1CardD = Key('onboarding_s1_card_d');
  static const Key s1CardMoving = Key('onboarding_s1_card_moving');
  static const Key s1RingTrack = Key('onboarding_s1_ring_track');
  static const Key s1RingProgress = Key('onboarding_s1_ring_progress');
  static const Key s1HealthText = Key('onboarding_s1_health_text');

  // Slide 2 — People.
  static const Key s2PulseRingA = Key('onboarding_s2_pulse_ring_a');
  static const Key s2PulseRingB = Key('onboarding_s2_pulse_ring_b');
  static const Key s2CheckinButton = Key('onboarding_s2_checkin_button');
  static const Key s2IconClock = Key('onboarding_s2_icon_clock');
  static const Key s2IconCheck = Key('onboarding_s2_icon_check');
  static const Key s2CardBg = Key('onboarding_s2_card_bg');
  static const Key s2Avatar = Key('onboarding_s2_avatar');
  static const Key s2Lines = Key('onboarding_s2_lines');
  static const Key s2PillPending = Key('onboarding_s2_pill_pending');
  static const Key s2PillApproved = Key('onboarding_s2_pill_approved');
  static const Key s2Stamp = Key('onboarding_s2_stamp');

  // Slide 3 — Finance.
  static const Key s3DealCard = Key('onboarding_s3_deal_card');
  static const Key s3ProjectCard = Key('onboarding_s3_project_card');
  static const Key s3Connector = Key('onboarding_s3_connector');
  static const Key s3FlowDot = Key('onboarding_s3_flow_dot');
  static const Key s3TrendBadge = Key('onboarding_s3_trend_badge');
  static const Key s3LabelPill = Key('onboarding_s3_label_pill');
  static const Key s3ProfitText = Key('onboarding_s3_profit_text');

  // Slide 4 — Insights.
  static const Key s4Frame = Key('onboarding_s4_frame');
  static const Key s4Bar1 = Key('onboarding_s4_bar_1');
  static const Key s4Bar2 = Key('onboarding_s4_bar_2');
  static const Key s4Bar3 = Key('onboarding_s4_bar_3');
  static const Key s4Bar4 = Key('onboarding_s4_bar_4');
  static const Key s4Bar5 = Key('onboarding_s4_bar_5');
  static const Key s4Line = Key('onboarding_s4_line');
  static const Key s4LineDots = Key('onboarding_s4_line_dots');
  static const Key s4AlertPulse = Key('onboarding_s4_alert_pulse');
  static const Key s4AlertBadge = Key('onboarding_s4_alert_badge');
  static const Key s4Legend = Key('onboarding_s4_legend');
}

/// Idle (settled-frame) motion: the settle pulse and the content-fit geometry
/// used to enlarge slides 1 and 3.
abstract final class OnboardingIllustrationSettle {
  /// The entrance progress at which the settle pulse starts.
  static const double settlePulseBegin = 0.88;

  /// The entrance progress at which the settle pulse ends, back to identity.
  static const double settlePulseEnd = 1.0;

  /// Peak scale of the settle pulse (1.012, i.e. a 1.2% overshoot), applied
  /// to the whole layer stack around its center during [0.88, 1.00].
  static const double settlePulseAmplitude = 0.012;
}

/// Fit-to-content constants, used by slides 1 and 3 only. The illustration
/// region is sized to the aspect ratio of the settled content instead of the
/// full 400x400 canvas, so the artwork fills the available width.
abstract final class OnboardingIllustrationFit {
  /// Inner margin as a fraction of the canvas side, added on each side of the
  /// union of settled ink bounds before the region is fitted.
  static const double contentFitInnerMargin = 0.02;

  /// Slide 1 — Projects: union of every settled layer's manifest `bbox_norm`
  /// plus the health text slot, with [contentFitInnerMargin] on each side.
  /// Recomputed from `assets/svgs/onboarding/manifest.json`: x 0.0525, y
  /// 0.1425, w 0.895, h 0.6975 before the margin.
  static const Rect s1ContentBounds = Rect.fromLTWH(
    0.0325,
    0.1225,
    0.935,
    0.7375,
  );

  /// Slide 3 — Finance and Clients: union of every settled layer's manifest
  /// `bbox_norm` (the flow dot is transient and excluded) plus the profit
  /// text slot, with [contentFitInnerMargin] on each side.
  /// Recomputed from the manifest: x 0.0775, y 0.1725, w 0.845, h 0.6825
  /// before the margin.
  static const Rect s3ContentBounds = Rect.fromLTWH(
    0.0575,
    0.1525,
    0.885,
    0.7225,
  );
}

/// The per-layer assembly entrance of the onboarding illustrations. Every
/// layer starts displaced, slightly rotated/scaled and transparent, fades in
/// over the first 45% of its window, then settles to identity at [end].
/// Intervals are fractions of the slide's entrance progress (0.0 → 1.0);
/// offsets are fractions of the canvas side. Target table: the assembly
/// choreography agreed for the SVG rework; pivots come from the layer
/// `bbox_norm` centers in `assets/svgs/onboarding/manifest.json`.
abstract final class OnboardingIllustrationMotion {
  /// Share of each layer's window over which opacity fades 0 → 1. The
  /// transform keeps easing until the window ends.
  static const double assemblyFadeFraction = 0.45;

  /// Bars grow from bottomCenter.
  static const Alignment barPivot = Alignment.bottomCenter;

  /// Slide 1 — Projects: pivots are the layer bbox centers (canvas ratios).
  static const Alignment s1BoardPivot = Alignment(0.47375, 0.29375);
  static const Alignment s1CardAPivot = Alignment(0.21, 0.3375);
  static const Alignment s1CardBPivot = Alignment(0.21, 0.4775);
  static const Alignment s1CardCPivot = Alignment(0.5, 0.3375);
  static const Alignment s1CardDPivot = Alignment(0.79, 0.3375);
  static const Alignment s1CardMovingPivot = Alignment(0.79, 0.4775);
  static const Alignment s1RingPivot = Alignment(0.5, 0.75);

  // ---- Slide 1: Projects -------------------------------------------------
  static const double s1BoardBegin = 0.00;
  static const double s1BoardEnd = 0.28;
  static const Offset s1BoardFrom = Offset(0.0, 0.05);
  static const double s1BoardFromDegrees = 0.0;
  static const double s1BoardFromScale = 0.92;

  static const double s1CardABegin = 0.18;
  static const double s1CardAEnd = 0.46;
  static const Offset s1CardAFrom = Offset(-0.05, -0.14);
  static const double s1CardAFromDegrees = -6;
  static const double s1CardsFromScale = 0.85;

  static const double s1CardBBegin = 0.24;
  static const double s1CardBEnd = 0.52;
  static const Offset s1CardBFrom = Offset(-0.05, 0.12);
  static const double s1CardBFromDegrees = 5;

  static const double s1CardCBegin = 0.30;
  static const double s1CardCEnd = 0.58;
  static const Offset s1CardCFrom = Offset(0.0, -0.16);
  static const double s1CardCFromDegrees = -4;

  static const double s1CardDBegin = 0.36;
  static const double s1CardDEnd = 0.64;
  static const Offset s1CardDFrom = Offset(0.05, -0.14);
  static const double s1CardDFromDegrees = 6;

  static const double s1CardMovingBegin = 0.55;
  static const double s1CardMovingEnd = 0.88;
  static const double s1CardMovingFromX = -0.29;
  static const double s1CardMovingFadeFraction = 0.15;
  static const double s1CardMovingLiftScale = 1.04;

  static const double s1RingTrackBegin = 0.42;
  static const double s1RingTrackEnd = 0.66;
  static const Offset s1RingTrackFrom = Offset(0.0, 0.07);
  static const double s1RingTrackFromScale = 0.6;

  static const double s1RingProgressBegin = 0.58;
  static const double s1RingProgressEnd = 1.00;
  static const Offset s1RingCenter = Offset(0.5, 0.75);
  static const double s1RingRadiusOfSide = 0.0775;
  static const double s1RingStrokeOfSide = 0.025;
  static const double s1RingStartAngleDegrees = -90;
  static const double s1RingSweepDegrees = 270;

  /// Angular half-width of the round stroke caps, derived from the stroke and
  /// the ring radius so the settled arc is never clipped at its ends.
  static const double s1RingCapAngleRadians =
      (s1RingStrokeOfSide / 2) / s1RingRadiusOfSide;

  static const Duration s1RingIdlePeriod = Duration(milliseconds: 2400);
  static const double s1RingIdleScaleTo = 1.03;

  static const double s1HealthTextBegin = 0.58;
  static const double s1HealthTextEnd = 1.00;

  // ---- Slide 2: People ---------------------------------------------------
  /// Pivots are the layer bbox centers (canvas ratios).
  static const Alignment s2ButtonPivot = Alignment(0.5, 0.28);
  static const Alignment s2IconPivot = Alignment(0.5, 0.28);
  static const Alignment s2CheckPivot = Alignment(0.5025, 0.27875);
  static const Alignment s2CardBgPivot = Alignment(0.5, 0.7225);
  static const Alignment s2AvatarPivot = Alignment(0.205, 0.675);
  static const Alignment s2LinesPivot = Alignment(0.43, 0.6725);
  static const Alignment s2PillPivot = Alignment(0.27, 0.82);
  static const Alignment s2StampPivot = Alignment(0.855, 0.58);

  static const double s2CheckinBegin = 0.00;
  static const double s2CheckinEnd = 0.30;
  static const Offset s2CheckinFrom = Offset(0.0, -0.08);
  static const double s2CheckinFromScale = 0.5;

  static const double s2ClockInBegin = 0.08;
  static const double s2ClockInEnd = 0.26;
  static const double s2ClockOutBegin = 0.46;
  static const double s2ClockOutEnd = 0.56;

  static const double s2CheckInBegin = 0.46;
  static const double s2CheckInEnd = 0.62;
  static const double s2CheckFromScale = 0.6;

  static const double s2CardBgBegin = 0.20;
  static const double s2CardBgEnd = 0.52;

  /// Adjusted from the proposed +0.14: at scale 0.94 the card's bottom edge
  /// already reaches y≈0.88 of the canvas, so +0.14 would paint off-canvas.
  /// Direction (down) kept, offset reduced proportionally.
  static const Offset s2CardBgFrom = Offset(0.0, 0.12);
  static const double s2CardBgFromScale = 0.94;

  static const double s2AvatarBegin = 0.38;
  static const double s2AvatarEnd = 0.60;
  static const Offset s2AvatarFrom = Offset(-0.10, 0.06);
  static const double s2AvatarFromDegrees = -10;
  static const double s2AvatarFromScale = 0.6;

  static const double s2LinesBegin = 0.46;
  static const double s2LinesEnd = 0.68;
  static const Offset s2LinesFrom = Offset(0.06, 0.01);
  static const double s2LinesFromScale = 1.0;

  static const double s2PillPendingInBegin = 0.54;
  static const double s2PillPendingInEnd = 0.68;
  static const Offset s2PillPendingFrom = Offset(0.0, 0.03);
  static const double s2PillPendingFromScale = 1.0;
  static const double s2PillPendingOutBegin = 0.82;
  static const double s2PillPendingOutEnd = 0.90;

  static const double s2PillApprovedBegin = 0.82;
  static const double s2PillApprovedEnd = 0.92;

  static const double s2StampBegin = 0.78;
  static const double s2StampEnd = 1.00;

  /// Adjusted from the proposed +0.02: at scale 1.4 with −25° rotation the
  /// stamp's rotated corner already reaches x≈0.999 of the canvas, so any
  /// positive dx would paint off-canvas. Direction (+x) kept, offset reduced
  /// to 0.
  static const Offset s2StampFrom = Offset(0.0, -0.08);
  static const double s2StampFromDegrees = -25;
  static const double s2StampFromScale = 1.4;

  /// The stamp's opacity reaches 1 at p = 0.84 while its transform keeps
  /// easing to identity at p = 1.00.
  static const double s2StampOpacityEnd = 0.84;

  static const Duration s2PulseIdlePeriod = Duration(milliseconds: 1800);
  static const double s2PulseIdleScaleTo = 1.6;

  /// Loop offset of the second pulse-ring copy: half a period behind the
  /// first, so ring echoes keep alternating.
  static const double s2PulseIdleSecondPhase = 0.5;

  // ---- Slide 3: Finance and Clients --------------------------------------
  /// Pivots are the layer bbox centers (canvas ratios).
  static const Alignment s3DealCardPivot = Alignment(0.23, 0.2775);
  static const Alignment s3ProjectCardPivot = Alignment(0.77, 0.2775);
  static const Alignment s3ConnectorPivot = Alignment(0.5012, 0.26815);
  static const Alignment s3FlowDotPivot = Alignment(0.4, 0.275);
  static const Alignment s3TrendBadgePivot = Alignment(0.285, 0.695);
  static const Alignment s3LabelPillPivot = Alignment(0.48, 0.83);

  static const double s3DealCardBegin = 0.00;
  static const double s3DealCardEnd = 0.30;
  static const double s3DealCardFromX = -0.07;
  static const double s3DealCardFromDegrees = -4;
  static const double s3DealCardFromScale = 0.9;

  static const double s3ConnectorBegin = 0.20;
  static const double s3ConnectorEnd = 0.42;

  static const double s3FlowDotInBegin = 0.26;
  static const double s3FlowDotInEnd = 0.50;
  static const double s3FlowDotOutBegin = 0.48;
  static const double s3FlowDotOutEnd = 0.52;
  static const Offset s3FlowDotP0 = Offset(0.4, 0.275);
  static const Offset s3FlowDotP1 = Offset(0.47, 0.205);
  static const Offset s3FlowDotP2 = Offset(0.53, 0.275);
  static const Offset s3FlowDotP3 = Offset(0.6, 0.275);
  static const Duration s3FlowDotIdlePeriod = Duration(milliseconds: 2200);

  /// Chosen detail (not fixed by the choreography table): the dot hides for
  /// the last 12% of each loop and fades in/out over 8% at both ends.
  static const double s3FlowDotIdlePauseFraction = 0.12;
  static const double s3FlowDotIdleFadeFraction = 0.08;

  static const double s3ProjectCardBegin = 0.42;
  static const double s3ProjectCardEnd = 0.72;
  static const Offset s3ProjectCardFrom = Offset(0.07, 0.02);
  static const double s3ProjectCardFromDegrees = 4;
  static const double s3ProjectCardFromScale = 0.9;

  static const double s3TrendBadgeBegin = 0.56;
  static const double s3TrendBadgeEnd = 0.80;
  static const Offset s3TrendBadgeFrom = Offset(-0.06, 0.08);
  static const double s3TrendBadgeFromDegrees = -15;
  static const double s3TrendBadgeFromScale = 0.5;
  static const Duration s3TrendBadgeFloatPeriod = Duration(milliseconds: 2600);
  static const double s3TrendBadgeFloatAmplitudeOfSide = 0.01;

  static const double s3LabelPillBegin = 0.74;
  static const double s3LabelPillEnd = 1.00;
  static const Offset s3LabelPillFrom = Offset(0.0, 0.06);
  static const double s3LabelPillFromScale = 0.9;

  static const double s3ProfitTextBegin = 0.60;
  static const double s3ProfitTextEnd = 1.00;

  // ---- Slide 4: Insights -------------------------------------------------
  /// Pivots are the layer bbox centers (canvas ratios); bars grow from
  /// bottomCenter.
  static const Alignment s4FramePivot = Alignment(0.5, 0.4625);
  static const Alignment s4LinePivot = Alignment(0.5, 0.4075);
  static const Alignment s4LineDotsPivot = Alignment(0.5019, 0.4056);
  static const Alignment s4AlertBadgePivot = Alignment(0.85, 0.16);
  static const Alignment s4LegendPivot = Alignment(0.5, 0.88);

  static const double s4FrameBegin = 0.00;
  static const double s4FrameEnd = 0.26;
  static const Offset s4FrameFrom = Offset(0.0, 0.06);
  static const double s4FrameFromScale = 0.94;

  static const double s4Bar1Begin = 0.20;
  static const double s4Bar1End = 0.45;
  static const double s4Bar2Begin = 0.27;
  static const double s4Bar2End = 0.52;
  static const double s4Bar3Begin = 0.34;
  static const double s4Bar3End = 0.59;
  static const double s4Bar4Begin = 0.41;
  static const double s4Bar4End = 0.66;
  static const double s4Bar5Begin = 0.48;
  static const double s4Bar5End = 0.73;

  static const double s4LineRevealBegin = 0.50;
  static const double s4LineRevealEnd = 0.85;

  /// Clip window of the line reveal: starts before the first data point and
  /// ends after the last one, so nothing shows at 0 and everything at 1.
  static const double s4LineRevealFromX = 0.13;
  static const double s4LineRevealToX = 0.87;

  static const double s4AlertBadgeBegin = 0.84;
  static const double s4AlertBadgeEnd = 1.00;
  static const Offset s4AlertBadgeFrom = Offset(0.02, -0.08);
  static const double s4AlertBadgeFromDegrees = 20;
  static const double s4AlertBadgeFromScale = 0.3;

  static const double s4LegendBegin = 0.86;
  static const double s4LegendEnd = 1.00;
  static const Offset s4LegendFrom = Offset(0.0, 0.04);
  static const double s4LegendFromScale = 1.0;

  static const Duration s4AlertPulseIdlePeriod = Duration(milliseconds: 1600);
  static const double s4AlertPulseIdleScaleTo = 1.43;
}

/// The Flutter-rendered text slots of the illustrations (numbers are not part
/// of the SVGs). Rects are normalized to the square side, authored LTR; the
/// stage mirrors them with `PositionedDirectional` in RTL.
abstract final class OnboardingIllustrationText {
  /// Slide 1: percent label centered inside the health ring.
  static const Rect healthRect = Rect.fromLTWH(0.44, 0.72, 0.12, 0.06);
  static const double healthFontOfSide = 0.045;

  /// Count-up target as a fraction: `NumberFormat.percentPattern` multiplies
  /// by 100, so 0.75 renders as "75%".
  static const double healthCountTarget = 0.75;

  /// Slide 3: profit number, start-aligned above the label pill.
  static const Rect profitRect = Rect.fromLTWH(0.375, 0.635, 0.39, 0.12);
  static const double profitFontOfSide = 0.06;

  /// Count-up target of the compact profit number (illustration demo value).
  static const int profitCountTarget = 128000;
}
