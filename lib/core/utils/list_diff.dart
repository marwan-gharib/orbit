/// Pure diff between two lists keyed by `keyOf`.
///
/// Used by [DiffListView] to animate inserts, removals and flashes while
/// keeping untouched items stable. The diff itself has no UI logic.
final class DiffResult<T> {
  const DiffResult({
    required this.added,
    required this.removed,
    required this.common,
  });

  /// Items in [next] that were not in [previous].
  final List<T> added;

  /// Items in [previous] that were not in [next].
  final List<T> removed;

  /// Items present in both, in [next] order.
  final List<T> common;

  /// Whether nothing changed.
  bool get isEmpty => added.isEmpty && removed.isEmpty;
}

/// Computes an id-based diff between two lists.
///
/// Items are matched by [keyOf]; items with the same key are "common", items
// only in [previous] are "removed", items only in [next] are "added".
DiffResult<T> diffList<T>({
  required List<T> previous,
  required List<T> next,
  required T Function(T item) keyOf,
}) {
  final previousByKey = <T, T>{};
  for (final item in previous) {
    previousByKey[keyOf(item)] = item;
  }

  final nextByKey = <T, T>{};
  for (final item in next) {
    nextByKey[keyOf(item)] = item;
  }

  final removed = <T>[];
  for (final item in previous) {
    if (!nextByKey.containsKey(keyOf(item))) {
      removed.add(item);
    }
  }

  final added = <T>[];
  final common = <T>[];
  for (final item in next) {
    final key = keyOf(item);
    if (previousByKey.containsKey(key)) {
      common.add(item);
    } else {
      added.add(item);
    }
  }

  return DiffResult<T>(added: added, removed: removed, common: common);
}
