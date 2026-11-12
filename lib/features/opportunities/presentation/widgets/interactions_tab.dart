import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit/core/animations/loading/shimmer_box.dart';
import 'package:orbit/core/animations/loading/shimmer_scope.dart';
import 'package:orbit/core/animations/state/app_animated_switcher.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/core/widgets/empty_state.dart';
import 'package:orbit/core/widgets/error_state.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_bloc.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_event.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_state.dart';
import 'package:orbit/features/interactions/presentation/mappers/interaction_tile_mapper.dart';
import 'package:orbit/features/interactions/presentation/pure/timeline_ordering.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';
import 'package:orbit/features/interactions/presentation/widgets/helpers.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_tile_skeleton.dart';
import 'package:orbit/features/interactions/presentation/widgets/interactions_timeline.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/presentation/pure/contact_to_interaction_option.dart';

/// Interactions of this opportunity only (server-side filtered), with add,
/// edit and delete. Reads the page's [InteractionsListBloc], so the loaded
/// list survives tab switches and refreshes itself after any change.
class InteractionsTab extends StatelessWidget {
  const InteractionsTab({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InteractionsListBloc, InteractionsListState>(
      builder: (context, state) => AppAnimatedSwitcher(
        child: switch (state) {
          InteractionsListInitial() || InteractionsListLoading() =>
            const _InteractionsTabSkeleton(key: ValueKey('loading')),
          InteractionsListError(:final failure) => Padding(
            key: const ValueKey('error'),
            padding: EdgeInsetsDirectional.all(AppSpacing.lg),
            child: ErrorState(
              message: context.failureText(failure),
              retryAction: (
                label: context.t.crm.common.retry,
                onPressed: () => context.read<InteractionsListBloc>().add(
                  const InteractionsListRefreshed(),
                ),
              ),
            ),
          ),
          InteractionsListEmpty(:final isRefreshing) => _Content(
            key: const ValueKey('content'),
            opportunity: opportunity,
            items: const [],
            isRefreshing: isRefreshing,
          ),
          InteractionsListSuccess(:final interactions, :final isRefreshing) =>
            _Content(
              key: const ValueKey('content'),
              opportunity: opportunity,
              items: sortInteractionsForTimeline(
                interactions.map(buildInteractionTileData).toList(),
              ),
              isRefreshing: isRefreshing,
            ),
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    super.key,
    required this.opportunity,
    required this.items,
    required this.isRefreshing,
  });

  final Opportunity opportunity;
  final List<InteractionTileData> items;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final contacts = contactsToInteractionOptions(
      opportunity.customer.contacts,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.all(AppSpacing.md),
          child: AppButton.filled(
            label: context.t.crm.editor.titleAdd,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => showAddInteractionSheet(
              context,
              customerId: opportunity.customer.customerId,
              opportunityId: opportunity.opportunityId,
              contacts: contacts,
              contextLabel:
                  '${opportunity.title} \u00b7 ${opportunity.customer.firstName} ${opportunity.customer.lastName}',
            ),
          ),
        ),
        // if (isRefreshing)
        //   Padding(
        //     padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
        //     child: const AnimatedProgressBar(),
        //   ),
        if (items.isEmpty)
          Padding(
            padding: EdgeInsetsDirectional.all(AppSpacing.xl),
            child: EmptyState(
              title: context.t.crm.crmOpportunities.detail.interactionsEmpty,
              icon: Icons.chat_bubble_outline_rounded,
            ),
          )
        else
          InteractionsTimeline(
            items: items,
            isRefreshing: isRefreshing,
            onEdit: (tile) => showEditInteractionSheet(
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
            ),
            onDelete: (tile) => showDeleteInteractionDialog(
              context,
              interactionId: tile.id,
              customerId: tile.customerId,
              opportunityId: tile.opportunityId,
            ),
          ),
      ],
    );
  }
}

/// Add-button placeholder + interaction card skeletons.
class _InteractionsTabSkeleton extends StatelessWidget {
  const _InteractionsTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShimmerScope(child: ShimmerBox(height: Responsive.adapt(48))),
          SizedBox(height: AppSpacing.lg),
          const InteractionTileSkeletonList(),
        ],
      ),
    );
  }
}
