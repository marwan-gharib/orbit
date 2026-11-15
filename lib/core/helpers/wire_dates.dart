import 'package:orbit/core/constants/date_formats.dart';

/// Wire date handling for CRM date-only fields (`interaction_date`,
/// `expected_close_date`). Valid wire shapes: the bare `yyyy-MM-dd` string
/// ([DateFormats.apiDate]) or a full ISO instant starting with that shape.
///
/// The calendar day is always the wire value's OWN date components — the
/// time part and any offset are ignored, and values are normalized to
/// `DateTime.utc(y, m, d)`. No zone conversion ever happens, so `Z`-midnight
/// or offset instants cannot drift to the previous/next day on devices far
/// from UTC, and user-picked local dates keep their calendar day.
abstract final class WireDates {
  /// Shape gate: 4-digit year, padded month/day, then an optional time part
  /// (ISO `T…` or space + time). Rejects bare years or shifted parts so
  /// `2025` never slips through as January 1st.
  static final RegExp _shape = RegExp(r'^\d{4}-\d{2}-\d{2}([T\s].*)?$');

  /// Parses a wire date into a UTC-normalized date; `null`/blank/unparsable
  /// input yields `null` — for nullable fields.
  static DateTime? tryParseDateOnly(String? raw) => _parseOrNull(raw);

  /// Parses a required wire date or throws a [FormatException] — required
  /// fields must fail the whole response parse instead of showing a wrong
  /// value.
  static DateTime parseDateOnly(String raw) {
    final parsed = _parseOrNull(raw);
    if (parsed == null) {
      throw FormatException('Invalid wire date: "$raw"');
    }
    return parsed;
  }

  /// Formats a date's own calendar components as `yyyy-MM-dd` (the request
  /// wire shape). Works for both user-picked local dates and UTC-normalized
  /// parsed values: `DateTime.year/month/day` already are the components of
  /// the zone the instance represents — no zone conversion here either.
  static String formatDateOnly(DateTime date) {
    String pad(int value) => value.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return '$year-${pad(date.month)}-${pad(date.day)}';
  }

  static DateTime? _parseOrNull(String? raw) {
    final text = raw?.trim() ?? '';
    if (!_shape.hasMatch(text)) return null;
    final year = int.parse(text.substring(0, 4));
    final month = int.parse(text.substring(5, 7));
    final day = int.parse(text.substring(8, 10));
    // dart:core accepts overflowing components (June 31 -> July 1), so the
    // normal calendar construction must round-trip for the date to be real.
    final calendar = DateTime(year, month, day);
    if (calendar.year != year ||
        calendar.month != month ||
        calendar.day != day) {
      return null;
    }
    return DateTime.utc(year, month, day);
  }
}
