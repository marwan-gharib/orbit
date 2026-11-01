/// Opportunity stage in pipeline order: lead, qualified, proposal,
/// negotiation, closed. Anything the backend hasn't told us about falls
/// back to `unknown`; never throws.
enum OpportunityStage {
  lead('lead'),
  qualified('qualified'),
  proposal('proposal'),
  negotiation('negotiation'),
  closed('closed'),
  unknown('unknown');

  const OpportunityStage(this.value);

  final String value;

  /// Maps a raw backend stage; falls back to [unknown] for null, blank or
  /// unrecognized values (case- and whitespace-tolerant).
  static OpportunityStage fromValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    return normalized == null || normalized.isEmpty
        ? unknown
        : values.firstWhere(
            (stage) => stage.value == normalized,
            orElse: () => unknown,
          );
  }
}
