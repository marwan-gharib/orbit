import 'package:flutter/material.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/features/interactions/presentation/pure/timeline_ordering.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';
import 'package:orbit/features/interactions/presentation/widgets/helpers.dart';
import 'package:orbit/features/interactions/presentation/widgets/interactions_timeline.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/presentation/pure/contact_to_interaction_option.dart';
import 'package:orbit/features/opportunities/presentation/pure/embedded_interaction_to_tile_data.dart';

/// Interactions tab with add button and timeline.
class InteractionsTab extends StatelessWidget {
  const InteractionsTab({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final interactions = opportunity.customer.interactions;
    final contacts = opportunity.customer.contacts;

    // Map embedded interactions to tile data
    final tileData = interactions
        .map(
          (e) => embeddedInteractionToTileData(
            e,
            customerId: opportunity.customer.customerId,
            opportunityId: opportunity.opportunityId,
          ),
        )
        .toList();

    // Sort newest first
    final sortedTileData = sortInteractionsForTimeline(tileData);

    // Map contacts to contact options
    final contactOptions = contacts.map(contactToInteractionOption).toList();

    return Column(
      children: [
        // Add interaction button
        Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: SizedBox(
            width: double.infinity,
            child: AppButton.filled(
              label: context.t.crm.editor.titleAdd,
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _showAddSheet(context, contactOptions),
            ),
          ),
        ),
        // Timeline
        Expanded(
          child: InteractionsTimeline(
            items: sortedTileData,
            onEdit: (tile) => _showEditSheet(context, tile, contactOptions),
            onDelete: (tile) => _showDeleteDialog(context, tile),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddSheet(
    BuildContext context,
    List<InteractionContactOption> contactOptions,
  ) async {
    await showAddInteractionSheet(
      context,
      customerId: opportunity.customer.customerId,
      opportunityId: opportunity.opportunityId,
      contacts: contactOptions,
      contextLabel:
          '${opportunity.title} \u00b7 ${opportunity.customer.firstName} ${opportunity.customer.lastName}',
    );
  }

  Future<void> _showEditSheet(
    BuildContext context,
    InteractionTileData tile,
    List<InteractionContactOption> contactOptions,
  ) async {
    await showEditInteractionSheet(
      context,
      data: InteractionEditData(
        interactionId: tile.id,
        type: tile.type,
        subject: tile.subject,
        description: tile.description,
        date: tile.date,
        customerId: tile.customerId,
        opportunityId: tile.opportunityId,
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    InteractionTileData tile,
  ) async {
    await showDeleteInteractionDialog(
      context,
      interactionId: tile.id,
      customerId: tile.customerId,
      opportunityId: tile.opportunityId,
    );
  }
}
