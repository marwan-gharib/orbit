/// Domain entity representing a single onboarding page.
/// Pure Dart — no Flutter dependencies.
class OnboardingPage {
  const OnboardingPage({
    required this.id,
    required this.illustrationType,
  });

  /// Page index (0-based).
  final int id;

  /// Type of illustration to render for this page.
  final OnboardingIllustrationType illustrationType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingPage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          illustrationType == other.illustrationType;

  @override
  int get hashCode =>
      id.hashCode ^
      illustrationType.hashCode;
}

/// Which built-in illustration to show for a page.
enum OnboardingIllustrationType {
  /// Kanban board with task cards and health ring.
  projects,

  /// Check-in button + leave approval card.
  people,

  /// Deal → project → profit flow.
  finance,

  /// Dashboard bars, line chart, alert badge.
  insights,
}
