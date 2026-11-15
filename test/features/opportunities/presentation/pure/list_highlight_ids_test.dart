import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/opportunities/presentation/pure/list_highlight_ids.dart';

void main() {
  group('listHighlightIds', () {
    test('should return nothing on the first load (previous empty)', () {
      expect(
        listHighlightIds(previous: const [], next: const [1, 2, 3]),
        isEmpty,
      );
    });

    test('should return nothing on a pure append (load-more)', () {
      expect(
        listHighlightIds(previous: const [1, 2], next: const [1, 2, 3, 4]),
        isEmpty,
      );
    });

    test('should return nothing when the list did not change', () {
      expect(
        listHighlightIds(previous: const [1, 2], next: const [1, 2]),
        isEmpty,
      );
    });

    test('should return the newly added ids on a silent refresh', () {
      expect(
        listHighlightIds(previous: const [1, 2], next: const [2, 1, 5, 3]),
        unorderedEquals({5, 3}),
      );
    });

    test('should return nothing when the refresh only removed ids', () {
      expect(
        listHighlightIds(previous: const [1, 2, 3], next: const [1]),
        isEmpty,
      );
    });

    test('should not treat a prepend as an append', () {
      // A different first item means the earlier rows moved — highlight the
      // new one.
      expect(
        listHighlightIds(previous: const [1, 2], next: const [9, 1, 2]),
        unorderedEquals({9}),
      );
    });
  });
}
