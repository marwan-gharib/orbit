/// Hero ids shared by the list card and the detail header so title, value and
/// status badge fly between the two screens (wrapped by `AppHero`).
abstract final class OpportunityHeroTag {
  static String title(int opportunityId) => 'opportunity-title-$opportunityId';
  static String value(int opportunityId) => 'opportunity-value-$opportunityId';
  static String status(int opportunityId) =>
      'opportunity-status-$opportunityId';
}
