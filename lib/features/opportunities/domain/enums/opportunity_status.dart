/// Opportunity status: open, won, lost. Anything unrecognized falls back
/// to `unknown`; never throws.
enum OpportunityStatus {
  open('open'),
  won('won'),
  lost('lost'),
  unknown('unknown');

  const OpportunityStatus(this.value);

  final String value;

  /// Maps a raw backend status; falls back to [unknown] for null, blank or
  /// unrecognized values (case- and whitespace-tolerant).
  static OpportunityStatus fromValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    return normalized == null || normalized.isEmpty
        ? unknown
        : values.firstWhere(
            (status) => status.value == normalized,
            orElse: () => unknown,
          );
  }
}
