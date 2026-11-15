/// Pipeline stage of a dashboard slice, parsed from the API `stage` value.
enum DashboardStage {
  lead('lead'),
  qualified('qualified'),
  proposal('proposal'),
  negotiation('negotiation'),
  closed('closed'),
  unknown('');

  const DashboardStage(this.value);

  /// Wire value sent by the API.
  final String value;

  /// Never throws: an unrecognised value becomes [unknown].
  static DashboardStage fromValue(String? raw) {
    for (final stage in DashboardStage.values) {
      if (stage.value == raw && stage != DashboardStage.unknown) return stage;
    }
    return DashboardStage.unknown;
  }
}
