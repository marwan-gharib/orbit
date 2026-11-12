import 'package:orbit/core/utils/list_diff.dart';

/// Ids that should flash after a list changed from [previous] to [next].
///
/// - First load ([previous] empty): nothing flashes, the entrance owns it.
/// - Pure append (load-more keeps every earlier item in place): nothing
///   flashes.
/// - Anything else (silent refresh): the ids that are new in [next].
Set<int> listHighlightIds({
  required List<int> previous,
  required List<int> next,
}) {
  if (previous.isEmpty || _isAppend(previous, next)) return const {};
  final diff = diffList<int>(
    previous: previous,
    next: next,
    keyOf: (id) => id,
  );
  return diff.added.toSet();
}

bool _isAppend(List<int> previous, List<int> next) {
  if (next.length < previous.length) return false;
  for (var i = 0; i < previous.length; i++) {
    if (previous[i] != next[i]) return false;
  }
  return true;
}
