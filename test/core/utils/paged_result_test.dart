import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/utils/paged_result.dart';

void main() {
  group('PagedResult', () {
    test('should carry items, paging and the envelope total together', () {
      const result = PagedResult<int>(
        items: [1, 2, 3],
        hasMore: true,
        nextPage: 2,
        totalItems: 30,
      );

      expect(result.items, [1, 2, 3]);
      expect(result.hasMore, isTrue);
      expect(result.nextPage, 2);
      expect(result.nextCursor, isNull);
      expect(result.totalItems, 30);
    });

    test('should compare equal when every field matches', () {
      const a = PagedResult<String>(
        items: ['x'],
        hasMore: false,
        nextCursor: 'abc',
        totalItems: 1,
      );
      const b = PagedResult<String>(
        items: ['x'],
        hasMore: false,
        nextCursor: 'abc',
        totalItems: 1,
      );

      expect(a, b);
      expect(
        a,
        isNot(
          const PagedResult<String>(
            items: ['x'],
            hasMore: true,
            nextCursor: 'abc',
          ),
        ),
      );
    });
  });
}
