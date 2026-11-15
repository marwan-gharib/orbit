import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/presentation/pure/interaction_form_dirty.dart';

void main() {
  final baseDate = DateTime(2026, 11, 10, 14, 30);

  group('isInteractionFormDirty', () {
    test('should be clean when every field matches its baseline', () {
      final dirty = isInteractionFormDirty(
        subject: 'Kickoff',
        description: 'Agenda',
        type: InteractionType.call,
        date: baseDate,
        contactId: 3,
        baselineSubject: 'Kickoff',
        baselineDescription: 'Agenda',
        baselineType: InteractionType.call,
        baselineDate: baseDate,
        baselineContactId: 3,
      );

      expect(dirty, isFalse);
    });

    test('should ignore surrounding whitespace and be day-compare dates', () {
      final dirty = isInteractionFormDirty(
        subject: '  Kickoff  ',
        description: ' Agenda ',
        type: InteractionType.call,
        date: DateTime(2026, 11, 10, 23, 59),
        contactId: 3,
        baselineSubject: 'Kickoff',
        baselineDescription: 'Agenda',
        baselineType: InteractionType.call,
        baselineDate: DateTime(2026, 11, 10, 1, 0),
        baselineContactId: 3,
      );

      expect(dirty, isFalse);
    });

    test('should flag a changed subject', () {
      final dirty = isInteractionFormDirty(
        subject: 'Changed',
        description: 'Agenda',
        type: InteractionType.call,
        date: baseDate,
        baselineSubject: 'Kickoff',
        baselineDescription: 'Agenda',
        baselineType: InteractionType.call,
        baselineDate: baseDate,
      );

      expect(dirty, isTrue);
    });

    test('should flag a changed type, contact or date', () {
      bool changed({InteractionType? type, int? contactId, DateTime? date}) =>
          isInteractionFormDirty(
            subject: 'Kickoff',
            description: 'Agenda',
            type: type ?? InteractionType.call,
            date: date ?? baseDate,
            contactId: contactId ?? 3,
            baselineSubject: 'Kickoff',
            baselineDescription: 'Agenda',
            baselineType: InteractionType.call,
            baselineDate: baseDate,
            baselineContactId: 3,
          );

      expect(changed(type: InteractionType.meeting), isTrue);
      expect(changed(contactId: 4), isTrue);
      expect(changed(date: DateTime(2026, 11, 11)), isTrue);
    });

    test('should treat null and a contact id as different selections', () {
      final dirty = isInteractionFormDirty(
        subject: 'Kickoff',
        description: 'Agenda',
        type: InteractionType.call,
        date: baseDate,
        baselineSubject: 'Kickoff',
        baselineDescription: 'Agenda',
        baselineType: InteractionType.call,
        baselineDate: baseDate,
        baselineContactId: 3,
      );

      expect(dirty, isTrue);
    });
  });
}
