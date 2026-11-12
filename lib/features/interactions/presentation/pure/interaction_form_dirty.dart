import '../../domain/enums/interaction_type.dart';

/// Whether the add/edit form differs from its starting values.
///
/// Dates compare by calendar day only. [baseline*] are the values the form
/// opened with (the defaults in add mode, the stored values in edit mode).
bool isInteractionFormDirty({
  required String subject,
  required String description,
  required InteractionType type,
  required DateTime date,
  int? contactId,
  required String baselineSubject,
  required String baselineDescription,
  required InteractionType baselineType,
  required DateTime baselineDate,
  int? baselineContactId,
}) {
  return subject.trim() != baselineSubject.trim() ||
      description.trim() != baselineDescription.trim() ||
      type != baselineType ||
      contactId != baselineContactId ||
      !_sameDay(date, baselineDate);
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
