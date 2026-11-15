import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/interactions/presentation/pure/timeline_ordering.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';

void main() {
  group('sortInteractionsForTimeline', () {
    const type = InteractionType.call;

    InteractionTileData tile({required int id, required DateTime date}) {
      return InteractionTileData(
        id: id,
        type: type,
        subject: 'Subject $id',
        description: 'Description',
        date: date,
      );
    }

    test('empty list returns empty list', () {
      final result = sortInteractionsForTimeline([]);
      expect(result, isEmpty);
    });

    test('single item returns same item', () {
      final input = [tile(id: 1, date: DateTime(2026, 10, 19))];
      final result = sortInteractionsForTimeline(input);
      expect(result.length, 1);
      expect(result.first.id, 1);
    });

    test('sorts by date descending', () {
      final input = [
        tile(id: 1, date: DateTime(2026, 10, 15)),
        tile(id: 2, date: DateTime(2026, 10, 19)),
        tile(id: 3, date: DateTime(2026, 10, 17)),
      ];

      final result = sortInteractionsForTimeline(input);

      expect(result.map((e) => e.id).toList(), [2, 3, 1]);
    });

    test('same date sorts by id descending', () {
      final input = [
        tile(id: 1, date: DateTime(2026, 10, 19)),
        tile(id: 3, date: DateTime(2026, 10, 19)),
        tile(id: 2, date: DateTime(2026, 10, 19)),
      ];

      final result = sortInteractionsForTimeline(input);

      expect(result.map((e) => e.id).toList(), [3, 2, 1]);
    });

    test('combined: date desc then id desc', () {
      final input = [
        tile(id: 1, date: DateTime(2026, 10, 18)),
        tile(id: 5, date: DateTime(2026, 10, 19)),
        tile(id: 3, date: DateTime(2026, 10, 19)),
        tile(id: 2, date: DateTime(2026, 10, 17)),
        tile(id: 4, date: DateTime(2026, 10, 19)),
      ];

      final result = sortInteractionsForTimeline(input);

      // 19 Oct: ids 5, 4, 3; 18 Oct: id 1; 17 Oct: id 2
      expect(result.map((e) => e.id).toList(), [5, 4, 3, 1, 2]);
    });

    test('does not mutate original list', () {
      final input = [
        tile(id: 1, date: DateTime(2026, 10, 15)),
        tile(id: 2, date: DateTime(2026, 10, 19)),
      ];

      sortInteractionsForTimeline(input);

      expect(input.map((e) => e.id).toList(), [1, 2]);
    });

    test('stable sort for equal date and id (not possible but safe)', () {
      final input = [
        tile(id: 1, date: DateTime(2026, 10, 19)),
        tile(id: 1, date: DateTime(2026, 10, 19)),
      ];

      final result = sortInteractionsForTimeline(input);

      expect(result.length, 2);
    });
  });
}
