/// Wire date format patterns in one place (ARCH-10: format literals live
/// only here — matching behavior lives in `core/helpers/wire_dates.dart`).
abstract final class DateFormats {
  /// Date-only wire shape (`interaction_date`, `expected_close_date`).
  static const String apiDate = 'yyyy-MM-dd';
}
