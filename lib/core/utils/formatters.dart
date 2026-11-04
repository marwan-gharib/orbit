import 'package:intl/intl.dart';

/// Unit of a locale-free relative timestamp (see [Formatters.relativeParts]).
enum RelativeTimeUnit { justNow, minutes, hours, days }

/// Bucket returned by [Formatters.relativeParts]: [value] is the amount of
/// [unit] (`0` for [RelativeTimeUnit.justNow]).
typedef RelativeTimeParts = ({RelativeTimeUnit unit, int value});

/// Formatters shared across features.
///
/// Values come from `intl` so they respect the current locale; formats are
/// locale-aware by default.
final class Formatters {
  Formatters._();

  /// Formats [value] as a currency amount with [currencyCode], e.g. `EGP 250.000,00`.
  ///
  /// [currencyCode] is an ISO-4217 code such as `EGP` or `USD`. Falls back to
  /// the bare number when the code is unknown.
  static String currency(num value, String currencyCode) {
    try {
      final format = NumberFormat.currency(symbol: '', name: currencyCode);
      return format.format(value);
    } on Exception {
      return value.toStringAsFixed(2);
    }
  }

  /// Formats [value] as a grouped thousands amount with [currencyCode], without
  /// a currency symbol, e.g. `250,000 EGP` or `52,000 USD`. Decimals appear only
  /// when [value] is not an integer. Used as the single CRM money formatter so
  /// the value is never rendered as `$52000 USD` or similar.
  static String money(num value, String currencyCode) {
    if (currencyCode.isEmpty) {
      return _grouped(value);
    }
    final amount = _grouped(value);
    return '$amount $currencyCode';
  }

  /// Groups the integer part of [value] with thousands separators, keeping
  /// decimals only when [value] is not an integer.
  static String _grouped(num value) {
    final isInteger = value == value.truncate();
    final text = isInteger ? value.truncate().toString() : value.toString();
    final negative = text.startsWith('-');
    final digits = negative ? text.substring(1) : text;
    final dotIndex = digits.indexOf('.');
    final intPart = dotIndex < 0 ? digits : digits.substring(0, dotIndex);
    final fracPart = dotIndex < 0 ? '' : digits.substring(dotIndex);
    final groups = <String>[];
    for (var i = intPart.length; i > 0; i -= 3) {
      final start = i > 3 ? i - 3 : 0;
      groups.add(intPart.substring(start, i));
    }
    return (negative ? '-' : '') + groups.reversed.join(',') + fracPart;
  }

  /// Formats [date] as the single CRM display format, e.g. `19 Oct 2026`.
  /// Used in the opportunities list, the opportunity detail, interactions and
  /// notes so dates are consistent and unambiguous across the app.
  static String crmDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  /// Formats [date] relative to [now], e.g. `Today`, `Yesterday`, `3 days ago`.
  ///
  /// Returns `null` when [date] is null. Dates within the last 7 days get a
  /// day-relative label; older dates fall back to a short date.
  static String? relativeTime(DateTime? date, {DateTime? now}) {
    if (date == null) return null;
    final reference = now ?? DateTime.now();
    final difference = reference.difference(date);
    final absDays = difference.inDays.abs();

    if (absDays == 0) {
      return date.hour >= reference.hour || difference.inHours >= 0
          ? 'today'
          : 'today';
    }
    if (absDays == 1) {
      return difference.inHours > 0 ? 'yesterday' : 'yesterday';
    }
    if (absDays <= 7) {
      return '$absDays days ago';
    }
    return _shortDate(date);
  }

  /// Locale-free bucket of a relative timestamp.
  ///
  /// UI code turns the returned unit into localized copy (slang); the bucket
  /// itself carries no language. Future timestamps clamp to
  /// [RelativeTimeUnit.justNow].
  static RelativeTimeParts relativeParts(DateTime date, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final difference = reference.difference(date);
    if (difference.isNegative || difference.inMinutes < 1) {
      return (unit: RelativeTimeUnit.justNow, value: 0);
    }
    if (difference.inHours < 1) {
      return (unit: RelativeTimeUnit.minutes, value: difference.inMinutes);
    }
    if (difference.inDays < 1) {
      return (unit: RelativeTimeUnit.hours, value: difference.inHours);
    }
    return (unit: RelativeTimeUnit.days, value: difference.inDays);
  }

  static String _shortDate(DateTime date) {
    final month = _monthName(date.month);
    return '${date.day} $month';
  }

  static String _monthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return month.toString();
  }
}
