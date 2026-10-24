/// A closed employment-status set with the exact wire strings; anything
/// unrecognized (including missing or blank values) falls back to `unknown`,
/// so a backend change can never crash the app.
enum EmploymentStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  unknown('unknown');

  const EmploymentStatus(this.value);

  final String value;

  /// Maps a raw backend status; falls back to [unknown] for null, blank or
  /// unrecognized values (case- and whitespace-tolerant).
  static EmploymentStatus fromValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    return normalized == null || normalized.isEmpty
        ? unknown
        : values.firstWhere(
            (status) => status.value == normalized,
            orElse: () => unknown,
          );
  }
}
