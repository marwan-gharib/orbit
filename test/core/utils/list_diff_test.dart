import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/utils/list_diff.dart';

void main() {
  group('diffList', () {
    test('should report every added, removed and common item', () {
      final diff = diffList<int>(
        previous: [1, 2, 3],
        next: [2, 3, 4],
        keyOf: (item) => item,
      );

      expect(diff.added, [4]);
      expect(diff.removed, [1]);
      expect(diff.common, [2, 3]);
      expect(diff.isEmpty, isFalse);
    });

    test('should report nothing changed for identical lists', () {
      final diff = diffList<String>(
        previous: ['a', 'b'],
        next: ['a', 'b'],
        keyOf: (item) => item,
      );

      expect(diff.added, isEmpty);
      expect(diff.removed, isEmpty);
      expect(diff.isEmpty, isTrue);
    });

    test('should follow the next-list order for common items', () {
      final diff = diffList<String>(
        previous: ['a', 'b', 'c'],
        next: ['c', 'a'],
        keyOf: (item) => item,
      );

      expect(diff.common, ['c', 'a']);
      expect(diff.removed, ['b']);
      expect(diff.added, isEmpty);
    });

    test(
      'should treat a reused key as common even when the payload changed',
      () {
        // Keys, not payloads, decide identity: previous items 10 and 11 share
        // key 1, and next item 12 reuses key 1 — so it stays "common".
        final diff = diffList<int>(
          previous: [10, 11],
          next: [12],
          keyOf: (item) => item ~/ 10,
        );

        expect(diff.common, [12]);
        expect(diff.added, isEmpty);
        expect(diff.removed, isEmpty);
        expect(diff.isEmpty, isTrue);
      },
    );

    test('should add every next item whose key is new, in next order', () {
      final diff = diffList<int>(
        previous: [1, 2],
        next: [10, 11],
        keyOf: (item) => item ~/ 10,
      );

      expect(diff.added, [10, 11]);
      expect(diff.removed, [1, 2]);
      expect(diff.common, isEmpty);
    });
  });
}
