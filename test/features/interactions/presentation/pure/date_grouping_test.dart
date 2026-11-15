import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/interactions/presentation/pure/date_grouping.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';

void main() {
  group('groupInteractionsByDate', () {
    const type = InteractionType.call;

    InteractionTileData tile({
      required int id,
      required DateTime date,
      String subject = 'Subject',
      String description = 'Description',
    }) {
      return InteractionTileData(
        id: id,
        type: type,
        subject: subject,
        description: description,
        date: date,
      );
    }

    test('empty list returns empty map', () {
      final today = DateTime(2026, 10, 19);
      final result = groupInteractionsByDate([], today: today);
      expect(result, isEmpty);
    });

    test('single interaction today', () {
      final today = DateTime(2026, 10, 19);
      final interactions = [tile(id: 1, date: DateTime(2026, 10, 19))];

      final result = groupInteractionsByDate(interactions, today: today);

      expect(result.length, 1);
      expect(result.containsKey('crm.common.today'), isTrue);
      expect(result['crm.common.today']!.length, 1);
    });

    test('single interaction yesterday', () {
      final today = DateTime(2026, 10, 19);
      final interactions = [tile(id: 1, date: DateTime(2026, 10, 18))];

      final result = groupInteractionsByDate(interactions, today: today);

      expect(result.length, 1);
      expect(result.containsKey('crm.common.yesterday'), isTrue);
    });

    test('single interaction older date uses crmDate format', () {
      final today = DateTime(2026, 10, 19);
      final interactions = [tile(id: 1, date: DateTime(2026, 10, 10))];

      final result = groupInteractionsByDate(interactions, today: today);

      expect(result.length, 1);
      expect(result.keys.first, '10 Oct 2026');
    });

    test('multiple interactions same day grouped together', () {
      final today = DateTime(2026, 10, 19);
      final interactions = [
        tile(id: 1, date: DateTime(2026, 10, 19)),
        tile(id: 2, date: DateTime(2026, 10, 19)),
      ];

      final result = groupInteractionsByDate(interactions, today: today);

      expect(result.length, 1);
      expect(result['crm.common.today']!.length, 2);
    });

    test('multiple days create multiple groups in order', () {
      final today = DateTime(2026, 10, 19);
      final interactions = [
        tile(id: 1, date: DateTime(2026, 10, 19)), // today
        tile(id: 2, date: DateTime(2026, 10, 18)), // yesterday
        tile(id: 3, date: DateTime(2026, 10, 15)), // older
      ];

      final result = groupInteractionsByDate(interactions, today: today);

      expect(result.length, 3);
      expect(result.keys.toList(), [
        'crm.common.today',
        'crm.common.yesterday',
        '15 Oct 2026',
      ]);
    });

    test('month boundary: Jan 1 today, Dec 31 yesterday', () {
      final today = DateTime(2027, 1, 1);
      final interactions = [
        tile(id: 1, date: DateTime(2027, 1, 1)),
        tile(id: 2, date: DateTime(2026, 12, 31)),
      ];

      final result = groupInteractionsByDate(interactions, today: today);

      expect(result.length, 2);
      expect(result.containsKey('crm.common.today'), isTrue);
      expect(result.containsKey('crm.common.yesterday'), isTrue);
    });

    test('year boundary: Jan 1 today, Dec 31 previous year is yesterday', () {
      final today = DateTime(2027, 1, 1);
      final interactions = [
        tile(id: 1, date: DateTime(2027, 1, 1)),
        tile(id: 2, date: DateTime(2026, 12, 31)),
      ];

      final result = groupInteractionsByDate(interactions, today: today);

      expect(result.length, 2);
      expect(result['crm.common.today']!.first.id, 1);
      expect(result['crm.common.yesterday']!.first.id, 2);
    });

    test('date that would shift in negative-offset zone does not shift', () {
      // Date: 2026-10-19. If interpreted as UTC midnight and converted to
      // America/New_York (UTC-4 in Oct), it would become 2026-10-18 20:00.
      // Our grouping must use calendar components only, so it stays 19 Oct.
      final today = DateTime(2026, 10, 19);
      final interactions = [tile(id: 1, date: DateTime.utc(2026, 10, 19))];

      final result = groupInteractionsByDate(interactions, today: today);

      expect(result.length, 1);
      expect(result.containsKey('crm.common.today'), isTrue);
    });

    test(
      'order within a group preserves input order (repository already sorts)',
      () {
        final today = DateTime(2026, 10, 19);
        final interactions = [
          tile(id: 2, date: DateTime(2026, 10, 19)), // newer id
          tile(id: 1, date: DateTime(2026, 10, 19)), // older id
        ];

        final result = groupInteractionsByDate(interactions, today: today);

        expect(result['crm.common.today']!.map((e) => e.id).toList(), [2, 1]);
      },
    );
  });
}
