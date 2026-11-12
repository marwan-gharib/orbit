/// Defensive readers for the dashboard JSON: a missing or mistyped optional
/// field becomes a neutral value; a structurally wrong object throws a
/// [FormatException] that the repository maps to a failure.
abstract final class DashboardJson {
  static double readDouble(Object? raw) => raw is num ? raw.toDouble() : 0;

  static int readInt(Object? raw) => raw is num ? raw.toInt() : 0;

  static String readString(Object? raw) => raw is String ? raw : '';

  /// A nested JSON object, or an empty map when absent.
  static Map<String, dynamic> readMap(Object? raw) =>
      raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};

  /// A list of JSON objects, or an empty list when absent. An item that is
  /// not an object is a malformed response.
  static List<Map<String, dynamic>> readObjects(Object? raw, String what) {
    if (raw == null) return const [];
    if (raw is! List) {
      throw FormatException('Dashboard $what is not a list.');
    }
    return [
      for (final item in raw)
        item is Map
            ? Map<String, dynamic>.from(item)
            : throw FormatException('A dashboard $what item is not an object.'),
    ];
  }
}
