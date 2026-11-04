import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';
import 'package:orbit/features/opportunities/domain/entities/embedded_customer_interaction_entity.dart';

/// Maps an embedded opportunity interaction to the shared [InteractionTileData]
/// used by [InteractionsTimeline].
InteractionTileData embeddedInteractionToTileData(
  EmbeddedCustomerInteraction interaction, {
  required int customerId,
  required int opportunityId,
}) =>
    InteractionTileData(
      id: interaction.interactionId,
      type: interaction.type,
      subject: interaction.subject,
      description: interaction.description,
      date: interaction.interactionDate,
      authorName: interaction.employeeName,
      customerId: customerId,
      contactId: interaction.contactId,
      opportunityId: interaction.opportunityId ?? opportunityId,
    );