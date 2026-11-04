import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/widgets/empty_state.dart';
import 'package:orbit/core/widgets/error_state.dart';
import 'package:orbit/features/interactions/domain/params/interactions_criteria.dart';

import '../blocs/interactions_list/interactions_list_bloc.dart';
import '../blocs/interactions_list/interactions_list_event.dart';
import '../blocs/interactions_list/interactions_list_state.dart';
import '../view_models/interaction_tile_data.dart';
import 'interaction_refresh_notice.dart';
import 'interactions_feed_content.dart';

/// The state-driven body of the interactions feed: switches between skeleton,
/// content, empty (no data), empty (no results), and error.
class InteractionsFeedStateBody extends StatefulWidget {
  const InteractionsFeedStateBody({
    super.key,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenOpportunity,
  });

  final ValueChanged<InteractionTileData> onEdit;
  final ValueChanged<InteractionTileData> onDelete;
  final ValueChanged<int> onOpenOpportunity;

  @override
  State<InteractionsFeedStateBody> createState() =>
      _InteractionsFeedStateBodyState();
}

class _InteractionsFeedStateBodyState extends State<InteractionsFeedStateBody> {
  /// Dismissal is UI-local: the cubit keeps the last failure so a rebuild
  /// cannot resurrect a notice the user closed. Identity, not equality, so a
  /// new failure with the same text shows again.
  Failure? _dismissedFailure;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InteractionsListBloc, InteractionsListState>(
      builder: (context, state) {
        final failure = _refreshFailure(state);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (failure != null && !identical(failure, _dismissedFailure)) ...[
              InteractionRefreshNotice(
                message: context.t.crm.common.refreshFailedNotice,
                dismissLabel: context.t.crm.common.dismiss,
                onDismiss: () => setState(() => _dismissedFailure = failure),
              ),
              SizedBox(height: AppSpacing.sm),
            ],
            AppAnimatedSwitcher(child: _body(context, state)),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context, InteractionsListState state) {
    return switch (state) {
      InteractionsListInitial() ||
      InteractionsListLoading() => InteractionsFeedContent(
        key: const ValueKey('feed-skeleton'),
        interactions: const [],
        isRefreshing: false,
        isSkeleton: true,
        onEdit: widget.onEdit,
        onDelete: widget.onDelete,
        onOpenOpportunity: widget.onOpenOpportunity,
      ),
      InteractionsListSuccess(:final interactions, :final isRefreshing) =>
        InteractionsFeedContent(
          key: const ValueKey('feed-content'),
          interactions: interactions
              .map(
                (e) => InteractionTileData(
                  id: e.interactionId,
                  type: e.type,
                  subject: e.subject,
                  description: e.description,
                  date: e.interactionDate,
                  customerId: e.customerId,
                  contactId: e.contactId,
                  opportunityId: e.opportunityId,
                ),
              )
              .toList(),
          isRefreshing: isRefreshing,
          onEdit: widget.onEdit,
          onDelete: widget.onDelete,
          onOpenOpportunity: widget.onOpenOpportunity,
        ),
      InteractionsListEmpty(:final criteria, :final isRefreshing) =>
        _buildEmpty(context, criteria, isRefreshing),
      InteractionsListError(:final failure) => ErrorState(
        key: const ValueKey('feed-error'),
        message: context.failureText(failure),
        retryAction: (
          label: context.t.crm.common.retry,
          onPressed: () => context.read<InteractionsListBloc>().add(
            const InteractionsListRefreshed(),
          ),
        ),
      ),
    };
  }

  Widget _buildEmpty(
    BuildContext context,
    InteractionsCriteria criteria,
    bool isRefreshing,
  ) {
    final labels = context.t.crm.crmInteractions;
    final hasActiveFilters =
        criteria.searchText?.isNotEmpty == true || criteria.type != null;

    if (hasActiveFilters) {
      return EmptyState(
        key: const ValueKey('feed-empty-no-results'),
        title: labels.feedNoResults,
        icon: Icons.search_off_rounded,
        primaryAction: (
          label: context.t.crm.common.clearFilters,
          onPressed: () {
            context.read<InteractionsListBloc>().add(
              const InteractionsListSearchChanged(''),
            );
            context.read<InteractionsListBloc>().add(
              const InteractionsListFiltersChanged(type: null),
            );
          },
        ),
      );
    }

    return EmptyState(
      key: const ValueKey('feed-empty-no-data'),
      title: labels.feedEmpty,
      message: labels.feedEmptyMessage,
      icon: Icons.chat_bubble_outline_rounded,
    );
  }

  Failure? _refreshFailure(InteractionsListState state) => switch (state) {
    InteractionsListSuccess(:final refreshFailure) => refreshFailure,
    InteractionsListEmpty(:final refreshFailure) => refreshFailure,
    _ => null,
  };
}
