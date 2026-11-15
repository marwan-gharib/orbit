/// Interaction kinds with the exact wire strings (OQ-5: lowercase on the
/// wire); anything unrecognized — including missing or blank values — falls
/// back to `unknown`, so a backend change can never crash the app.
///
/// Shared through `core/` (ARCH-1/ARCH-4): the interactions feature owns the
/// standalone interactions, and the opportunities feature shows the
/// opportunity's embedded interactions — one wire concept, one enum.
enum InteractionType {
  call('call'),
  email('email'),
  meeting('meeting'),
  unknown('unknown');

  const InteractionType(this.value);

  final String value;

  /// Maps a raw backend kind; falls back to [unknown] for null, blank or
  /// unrecognized values (case- and whitespace-tolerant).
  static InteractionType fromValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    return normalized == null || normalized.isEmpty
        ? unknown
        : values.firstWhere(
            (type) => type.value == normalized,
            orElse: () => unknown,
          );
  }
}
