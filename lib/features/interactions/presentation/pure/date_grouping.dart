import 'package:orbit/core/utils/formatters.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';

/// Groups interactions by calendar date for the feed.
///
/// Compares calendar components (year, month, day) only — no time or zone
/// conversion. The [today] parameter is injected so tests control the clock.
///
/// Returns a map from group label to interactions in that group. Labels are:
/// - "Today" (from slang) when the interaction's date matches [today]
/// - "Yesterday" (from slang) when the interaction's date matches [today] - 1 day
/// - `Formatters.crmDate` (e.g. "19 Oct 2026") for older dates
///
/// The groups are ordered from newest to oldest (same order as the input list
/// which comes from the repository already sorted date desc, id desc).
Map<String, List<InteractionTileData>> groupInteractionsByDate(
  List<InteractionTileData> interactions, {
  required DateTime today,
}) {
  if (interactions.isEmpty) return {};

  final groups = <String, List<InteractionTileData>>{};
  final todayNormalized = DateTime(today.year, today.month, today.day);
  final yesterdayNormalized = todayNormalized.subtract(const Duration(days: 1));

  for (final interaction in interactions) {
    final date = interaction.date;
    final dateNormalized = DateTime(date.year, date.month, date.day);

    String label;
    if (dateNormalized == todayNormalized) {
      label = 'crm.common.today';
    } else if (dateNormalized == yesterdayNormalized) {
      label = 'crm.common.yesterday';
    } else {
      label = Formatters.crmDate(date);
    }

    groups.putIfAbsent(label, () => []).add(interaction);
  }

  return groups;
}
