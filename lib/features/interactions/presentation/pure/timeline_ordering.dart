import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';

/// Sorts interactions for the timeline: newest first.
///
/// The repository already returns interactions sorted by date desc then id desc.
/// This function applies the same ordering for safety and testability.
///
/// Order: [date] descending, then [id] descending.
List<InteractionTileData> sortInteractionsForTimeline(
  List<InteractionTileData> interactions,
) {
  final sorted = List<InteractionTileData>.from(interactions);
  sorted.sort((a, b) {
    final dateCompare = b.date.compareTo(a.date);
    if (dateCompare != 0) return dateCompare;
    return b.id.compareTo(a.id);
  });
  return sorted;
}
