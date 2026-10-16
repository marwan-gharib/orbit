/// Holds asset path constants so asset names are never scattered as strings.
abstract final class Assets {
  /// Splash screen logo (transparent background PNG).
  static const String splashLogo =
      'assets/images/orbit_logo_whiting_backround.png';
}

/// Layered onboarding illustration assets (400x400 SVG layers, one element per
/// file, stacked at identical size — see `assets/svgs/onboarding/README.md`).
abstract final class OnboardingSvgs {
  // Slide 1 — Projects (z order).
  static const String s1Board =
      'assets/svgs/onboarding/slide_1_projects/01_board.svg';
  static const String s1CardA =
      'assets/svgs/onboarding/slide_1_projects/02_card_a.svg';
  static const String s1CardB =
      'assets/svgs/onboarding/slide_1_projects/03_card_b.svg';
  static const String s1CardC =
      'assets/svgs/onboarding/slide_1_projects/04_card_c.svg';
  static const String s1CardD =
      'assets/svgs/onboarding/slide_1_projects/05_card_d.svg';
  static const String s1CardMoving =
      'assets/svgs/onboarding/slide_1_projects/06_card_moving.svg';
  static const String s1RingTrack =
      'assets/svgs/onboarding/slide_1_projects/07_ring_track.svg';
  static const String s1RingProgress =
      'assets/svgs/onboarding/slide_1_projects/08_ring_progress.svg';

  // Slide 2 — People (z order).
  static const String s2PulseRing =
      'assets/svgs/onboarding/slide_2_people/01_pulse_ring.svg';
  static const String s2CheckinButton =
      'assets/svgs/onboarding/slide_2_people/02_checkin_button.svg';
  static const String s2IconClock =
      'assets/svgs/onboarding/slide_2_people/03_icon_clock.svg';
  static const String s2IconCheck =
      'assets/svgs/onboarding/slide_2_people/04_icon_check.svg';
  static const String s2CardBg =
      'assets/svgs/onboarding/slide_2_people/05_card_bg.svg';
  static const String s2Avatar =
      'assets/svgs/onboarding/slide_2_people/06_avatar.svg';
  static const String s2Lines =
      'assets/svgs/onboarding/slide_2_people/07_lines.svg';
  static const String s2PillPending =
      'assets/svgs/onboarding/slide_2_people/08_pill_pending.svg';
  static const String s2PillApproved =
      'assets/svgs/onboarding/slide_2_people/09_pill_approved.svg';
  static const String s2Stamp =
      'assets/svgs/onboarding/slide_2_people/10_stamp.svg';

  // Slide 3 — Finance (z order).
  static const String s3DealCard =
      'assets/svgs/onboarding/slide_3_finance/01_deal_card.svg';
  static const String s3ProjectCard =
      'assets/svgs/onboarding/slide_3_finance/02_project_card.svg';
  static const String s3Connector =
      'assets/svgs/onboarding/slide_3_finance/03_connector.svg';
  static const String s3FlowDot =
      'assets/svgs/onboarding/slide_3_finance/04_flow_dot.svg';
  static const String s3TrendBadge =
      'assets/svgs/onboarding/slide_3_finance/05_trend_badge.svg';
  static const String s3LabelPill =
      'assets/svgs/onboarding/slide_3_finance/06_label_pill.svg';

  // Slide 4 — Insights (z order).
  static const String s4Frame =
      'assets/svgs/onboarding/slide_4_insights/01_frame.svg';
  static const String s4Bar1 =
      'assets/svgs/onboarding/slide_4_insights/02_bar_1.svg';
  static const String s4Bar2 =
      'assets/svgs/onboarding/slide_4_insights/03_bar_2.svg';
  static const String s4Bar3 =
      'assets/svgs/onboarding/slide_4_insights/04_bar_3.svg';
  static const String s4Bar4 =
      'assets/svgs/onboarding/slide_4_insights/05_bar_4.svg';
  static const String s4Bar5 =
      'assets/svgs/onboarding/slide_4_insights/06_bar_5.svg';
  static const String s4Line =
      'assets/svgs/onboarding/slide_4_insights/07_line.svg';
  static const String s4LineDots =
      'assets/svgs/onboarding/slide_4_insights/08_line_dots.svg';
  static const String s4AlertPulse =
      'assets/svgs/onboarding/slide_4_insights/09_alert_pulse.svg';
  static const String s4AlertBadge =
      'assets/svgs/onboarding/slide_4_insights/10_alert_badge.svg';
  static const String s4Legend =
      'assets/svgs/onboarding/slide_4_insights/11_legend.svg';
}
