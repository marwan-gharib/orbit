import 'package:orbit/features/interactions/domain/entities/interaction_entity.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';

/// Maps an [Interaction] entity to the plain [InteractionTileData] used by
/// the feed and timeline widgets.
InteractionTileData buildInteractionTileData(
  Interaction interaction, {
  String? authorName,
}) {
  return InteractionTileData(
    id: interaction.interactionId,
    type: interaction.type,
    subject: interaction.subject,
    description: interaction.description,
    date: interaction.interactionDate,
    authorName: authorName,
    customerId: interaction.customerId,
    contactId: interaction.contactId,
    opportunityId: interaction.opportunityId,
  );
}
