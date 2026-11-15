import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/animations/overlays/app_snackbar.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_bloc.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_state.dart';
import 'package:orbit/features/interactions/presentation/constants/interaction_layout_constants.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_event.dart'
    show InteractionsListRefreshed, InteractionsListStarted;
import 'package:orbit/features/interactions/presentation/cubits/interaction_form/interaction_form_cubit.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_form/interaction_form_state.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_delete/interaction_delete_cubit.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_delete/interaction_delete_state.dart';
import 'package:orbit/features/interactions/presentation/widgets/helpers.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';

import 'interactions_feed_header.dart';
import 'interactions_feed_state_body.dart';

/// Full tab body for the interactions feed: owns its Bloc, handles search,
/// filters, pull-to-refresh, and mutation snackbars.
class InteractionsFeedView extends StatefulWidget {
  const InteractionsFeedView({super.key, required this.onOpenOpportunity});

  final ValueChanged<int> onOpenOpportunity;

  @override
  State<InteractionsFeedView> createState() => _InteractionsFeedViewState();
}

class _InteractionsFeedViewState extends State<InteractionsFeedView> {
  @override
  void initState() {
    super.initState();
    context.read<InteractionsListBloc>().add(const InteractionsListStarted());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<InteractionsListBloc>();
    bloc.add(const InteractionsListRefreshed());
    try {
      await bloc.stream
          .firstWhere(_isSettled)
          .timeout(InteractionLayoutConstants.refreshTimeout);
    } on TimeoutException {
      // Keep what is on screen; the spinner just stops.
    } on StateError {
      // Bloc closed while refreshing (tab left): nothing to wait for.
    }
  }

  bool _isSettled(InteractionsListState state) => switch (state) {
    InteractionsListSuccess(:final isRefreshing) => !isRefreshing,
    InteractionsListEmpty(:final isRefreshing) => !isRefreshing,
    InteractionsListInitial() || InteractionsListLoading() => false,
    InteractionsListError() => true,
  };

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<InteractionFormCubit, InteractionFormState>(
          listener: _onFormStateChanged,
        ),
        BlocListener<InteractionDeleteCubit, InteractionDeleteState>(
          listener: _onDeleteStateChanged,
        ),
      ],
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.page,
                child: const InteractionsFeedHeader(),
              ),
            ),
            SliverPadding(
              padding: AppSpacing.pageHorizontal,
              sliver: InteractionsFeedStateBody(
                onEdit: _openEditSheet,
                onDelete: _openDeleteDialog,
                onOpenOpportunity: widget.onOpenOpportunity,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: InteractionLayoutConstants.feedBottomPadding),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditSheet(InteractionTileData tile) {
    final editData = InteractionEditData(
      interactionId: tile.id,
      type: tile.type,
      subject: tile.subject,
      description: tile.description,
      date: tile.date,
      customerId: tile.customerId,
      opportunityId: tile.opportunityId,
    );
    showEditInteractionSheet(context, data: editData);
  }

  void _openDeleteDialog(InteractionTileData tile) {
    showDeleteInteractionDialog(
      context,
      interactionId: tile.id,
      customerId: tile.customerId,
      opportunityId: tile.opportunityId,
    );
  }

  void _onFormStateChanged(BuildContext context, InteractionFormState state) {
    if (state is InteractionFormSuccess) {
      AppSnackbar.show(
        context,
        message: state.isEdit
            ? context.t.crm.common.updated
            : context.t.crm.common.saved,
        type: AppSnackbarType.success,
      );
    } else if (state is InteractionFormSubmitError) {
      AppSnackbar.show(
        context,
        message: context.failureText(state.failure),
        type: AppSnackbarType.error,
      );
    }
  }

  void _onDeleteStateChanged(
    BuildContext context,
    InteractionDeleteState state,
  ) {
    if (state is InteractionDeleteSuccess) {
      AppSnackbar.show(
        context,
        message: context.t.crm.common.deleted,
        type: AppSnackbarType.success,
      );
    } else if (state is InteractionDeleteFailure) {
      // Error is shown in the dialog itself
    }
  }
}
