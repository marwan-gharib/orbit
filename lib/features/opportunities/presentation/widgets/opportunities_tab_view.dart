import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit/core/animations/loading/animated_progress_bar.dart';
import 'package:orbit/core/animations/state/animated_visibility.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_stage.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_status.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_bloc.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_event.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_state.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunities_list_header.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunities_list_notices.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunities_list_sliver.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunities_stage_chips.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunities_status_filter.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_card_skeleton.dart';

/// The opportunities tab: header (count + search + filters), stage chips and
/// a lazy, pull-to-refresh list. Owns no AppBar (the shell does).
class OpportunitiesTabView extends StatefulWidget {
  const OpportunitiesTabView({super.key, required this.onOpenOpportunity});

  final ValueChanged<int> onOpenOpportunity;

  @override
  State<OpportunitiesTabView> createState() => _OpportunitiesTabViewState();
}

class _OpportunitiesTabViewState extends State<OpportunitiesTabView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Failure? _dismissedRefreshFailure;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<OpportunitiesListBloc>().add(OpportunitiesListStarted());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >=
        position.maxScrollExtent -
            OpportunityLayoutConstants.loadMoreThreshold) {
      context.read<OpportunitiesListBloc>().add(
        OpportunitiesListLoadMoreRequested(),
      );
    }
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<OpportunitiesListBloc>();
    bloc.add(OpportunitiesListRefreshed());
    try {
      await bloc.stream
          .firstWhere(_isSettled)
          .timeout(OpportunityLayoutConstants.refreshTimeout);
    } on TimeoutException {
      // The list keeps whatever it has; the spinner just stops.
    } on StateError {
      // Bloc closed while refreshing (page left): nothing to wait for.
    }
  }

  bool _isSettled(OpportunitiesListState state) => switch (state) {
    OpportunitiesListSuccess(:final isRefreshing) => !isRefreshing,
    OpportunitiesListEmpty(:final isRefreshing) => !isRefreshing,
    OpportunitiesListInitial() || OpportunitiesListLoading() => false,
    OpportunitiesListError() => true,
  };

  void _changeFilters(
    OpportunitiesListState state, {
    required OpportunityStage? stage,
    required OpportunityStatus? status,
  }) {
    // Filters use replace semantics: every dispatch carries both values.
    context.read<OpportunitiesListBloc>().add(
      OpportunitiesListFiltersChanged(stage: stage, status: status),
    );
  }

  /// Clears the stage, the status and the search text in one step.
  void _clearFilters() {
    _searchController.clear();
    context.read<OpportunitiesListBloc>().add(OpportunitiesListFiltersCleared());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpportunitiesListBloc, OpportunitiesListState>(
      builder: (context, state) {
        final criteria = state.criteria;
        final hasActiveFilters = _isFiltered(state);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OpportunitiesListHeader(
              totalCount: _totalCount(state),
              isLoading:
                  state is OpportunitiesListInitial ||
                  state is OpportunitiesListLoading,
              controller: _searchController,
              hasActiveFilters: hasActiveFilters,
              onSearchChanged: (text) => context
                  .read<OpportunitiesListBloc>()
                  .add(OpportunitiesListSearchChanged(text)),
              onClearFilters: _clearFilters,
            ),
            OpportunitiesStageChips(
              selected: criteria.stage,
              onChanged: (stage) =>
                  _changeFilters(state, stage: stage, status: criteria.status),
            ),
            OpportunitiesStatusFilter(
              selected: criteria.status,
              onChanged: (status) =>
                  _changeFilters(state, stage: criteria.stage, status: status),
            ),
            AnimatedVisibility(
              visible: _isBusy(state),
              child: const AnimatedProgressBar(),
            ),
            Expanded(
              child: RefreshIndicator(
                color: context.colors.primary,
                backgroundColor: context.colors.surface,
                onRefresh: _onRefresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: _slivers(state),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  int? _totalCount(OpportunitiesListState state) => switch (state) {
    OpportunitiesListSuccess(:final totalCount) => totalCount,
    OpportunitiesListEmpty(:final totalCount) => totalCount,
    _ => null,
  };

  bool _isBusy(OpportunitiesListState state) => switch (state) {
    OpportunitiesListSuccess(:final isRefreshing) => isRefreshing,
    OpportunitiesListEmpty(:final isRefreshing) => isRefreshing,
    _ => false,
  };

  bool _isFiltered(OpportunitiesListState state) {
    final c = state.criteria;
    return (c.title?.isNotEmpty ?? false) ||
        c.stage != null ||
        c.status != null ||
        c.customerId != null;
  }

  List<Widget> _slivers(OpportunitiesListState state) {
    return switch (state) {
      OpportunitiesListInitial() || OpportunitiesListLoading() => [
        const SliverToBoxAdapter(child: OpportunitiesListSkeleton()),
      ],
      final OpportunitiesListSuccess s => [
        _notice(s.refreshFailure),
        OpportunitiesListSliver(
          items: s.items,
          hasMore: s.hasMore,
          isLoadingMore: s.isLoadingMore,
          loadMoreFailure: s.loadMoreFailure,
          onOpen: widget.onOpenOpportunity,
          onRetryLoadMore: () => context.read<OpportunitiesListBloc>().add(
            OpportunitiesListLoadMoreRequested(),
          ),
        ),
      ],
      final OpportunitiesListEmpty e => [
        _notice(e.refreshFailure),
        SliverFillRemaining(
          hasScrollBody: false,
          child: OpportunitiesEmptyView(
            isFiltered: _isFiltered(state),
            onClearFilters: _clearFilters,
          ),
        ),
      ],
      OpportunitiesListError(:final failure) => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: OpportunitiesErrorView(
            failure: failure,
            onRetry: () => context.read<OpportunitiesListBloc>().add(
              OpportunitiesListRefreshed(),
            ),
          ),
        ),
      ],
    };
  }

  Widget _notice(Failure? failure) {
    final visible = failure != null && failure != _dismissedRefreshFailure;
    return SliverToBoxAdapter(
      child: AnimatedVisibility(
        visible: visible,
        child: RefreshFailedNotice(
          onDismiss: () => setState(() => _dismissedRefreshFailure = failure),
        ),
      ),
    );
  }
}
