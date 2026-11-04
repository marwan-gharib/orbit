import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/core/widgets/app_text_field.dart';
import 'package:orbit/core/widgets/empty_state.dart';
import 'package:orbit/core/widgets/error_state.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_stage.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_status.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_bloc.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_event.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_state.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_card.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_card_skeleton.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_filter_sheet.dart';

/// The opportunities list tab — scrolls itself, no AppBar (shell owns it).
class OpportunitiesTabView extends StatefulWidget {
  const OpportunitiesTabView({super.key, required this.onOpenOpportunity});

  final ValueChanged<int> onOpenOpportunity;

  @override
  State<OpportunitiesTabView> createState() => _OpportunitiesTabViewState();
}

class _OpportunitiesTabViewState extends State<OpportunitiesTabView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  OpportunityStage? _selectedStage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<OpportunitiesListBloc>().add(OpportunitiesListStarted());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      context.read<OpportunitiesListBloc>().add(
        OpportunitiesListLoadMoreRequested(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpportunitiesListBloc, OpportunitiesListState>(
      builder: (context, state) {
        final criteria = state.criteria;
        final hasActiveFilters = criteria.status != null;

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Pinned header: search + filter button
            SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedHeaderDelegate(
                searchController: _searchController,
                onSearchChanged: (text) {
                  context.read<OpportunitiesListBloc>().add(
                    OpportunitiesListSearchChanged(text),
                  );
                },
                onFilterTap: () => _showFilterSheet(context, criteria.status),
                activeFiltersCount: hasActiveFilters ? 1 : 0,
              ),
            ),
            // Stage chips
            SliverPersistentHeader(
              pinned: true,
              delegate: _StageChipsDelegate(
                selectedStage: _selectedStage,
                onStageSelected: (stage) {
                  setState(() => _selectedStage = stage);
                  context.read<OpportunitiesListBloc>().add(
                    OpportunitiesListFiltersChanged(stage: stage),
                  );
                },
              ),
            ),
            // Summary row
            SliverToBoxAdapter(
              child: _SummaryRow(
                totalCount: _getTotalCount(state),
                hasActiveFilters: hasActiveFilters,
                onClearFilters: hasActiveFilters
                    ? () => context.read<OpportunitiesListBloc>().add(
                        const OpportunitiesListFiltersChanged(),
                      )
                    : null,
              ),
            ),
            // List content
            SliverFillRemaining(
              hasScrollBody: false,
              child: _ListBody(
                state: state,
                onOpenOpportunity: widget.onOpenOpportunity,
                onRetry: () => context.read<OpportunitiesListBloc>().add(
                  OpportunitiesListRefreshed(),
                ),
                onLoadMore: () => context.read<OpportunitiesListBloc>().add(
                  OpportunitiesListLoadMoreRequested(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  int _getTotalCount(OpportunitiesListState state) => switch (state) {
    OpportunitiesListSuccess(:final totalCount) => totalCount,
    OpportunitiesListEmpty(:final totalCount) => totalCount,
    _ => 0,
  };

  void _showFilterSheet(
    BuildContext context,
    OpportunityStatus? currentStatus,
  ) {
    AppBottomSheet.show(
      context: context,
      isScrollControlled: true,
      builder: (_) => OpportunityFilterSheet(currentStatus: currentStatus),
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHeaderDelegate({
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.activeFiltersCount,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;
  final int activeFiltersCount;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.border,
            width: shrinkOffset > 0 ? 1 : 0,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: _SearchField(
            controller: searchController,
            onChanged: onSearchChanged,
            trailing: _FilterButton(
              activeCount: activeFiltersCount,
              onTap: onFilterTap,
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 72;

  @override
  double get minExtent => 72;

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) =>
      oldDelegate.activeFiltersCount != activeFiltersCount;
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.trailing,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.t.crm.crmOpportunities;
    final colors = context.colors;

    return AppTextField(
      controller: controller,
      label: t.searchHint,
      hint: t.searchHint,
      prefixIcon: Icon(Icons.search_rounded, color: colors.textSecondary),
      suffixIcon: trailing,
      onChanged: onChanged,
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.activeCount, required this.onTap});

  final int activeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.tune_rounded, size: 24, color: colors.textPrimary),
              if (activeCount > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: colors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$activeCount',
                      style: context.textStyles.labelSmall.copyWith(
                        color: colors.onError,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageChipsDelegate extends SliverPersistentHeaderDelegate {
  _StageChipsDelegate({
    required this.selectedStage,
    required this.onStageSelected,
  });

  final OpportunityStage? selectedStage;
  final ValueChanged<OpportunityStage?> onStageSelected;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final t = context.t.crm.crmOpportunities;
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.border,
            width: shrinkOffset > 0 ? 1 : 0,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: AnimatedChipSelector<OpportunityStage?>(
          items: [
            ChipItem<OpportunityStage?>(value: null, label: t.stage.all),
            ChipItem<OpportunityStage?>(
              value: OpportunityStage.lead,
              label: t.stage.lead,
            ),
            ChipItem<OpportunityStage?>(
              value: OpportunityStage.qualified,
              label: t.stage.qualified,
            ),
            ChipItem<OpportunityStage?>(
              value: OpportunityStage.proposal,
              label: t.stage.proposal,
            ),
            ChipItem<OpportunityStage?>(
              value: OpportunityStage.negotiation,
              label: t.stage.negotiation,
            ),
            ChipItem<OpportunityStage?>(
              value: OpportunityStage.closed,
              label: t.stage.closed,
            ),
          ],
          selectedValue: selectedStage,
          onChanged: onStageSelected,
          scrollable: true,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant _StageChipsDelegate oldDelegate) =>
      oldDelegate.selectedStage != selectedStage;
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.totalCount,
    required this.hasActiveFilters,
    this.onClearFilters,
  });

  final int totalCount;
  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedCounter(
            value: totalCount,
            duration: AppDurations.normal,
            style: context.textStyles.titleMedium.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (hasActiveFilters)
            Row(
              children: [
                _ActiveStatusChip(),
                SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: onClearFilters,
                  child: Text(context.t.crm.common.clearFilters),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ActiveStatusChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_alt_rounded,
            size: 14,
            color: colors.onPrimaryContainer,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            context.t.crm.common.activeFilters(n: 1),
            style: context.textStyles.labelSmall.copyWith(
              color: colors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListBody extends StatelessWidget {
  const _ListBody({
    required this.state,
    required this.onOpenOpportunity,
    required this.onRetry,
    required this.onLoadMore,
  });

  final OpportunitiesListState state;
  final ValueChanged<int> onOpenOpportunity;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return AppAnimatedSwitcher(
      child: switch (state) {
        OpportunitiesListInitial() ||
        OpportunitiesListLoading() => _SkeletonList(key: ValueKey('loading')),
        OpportunitiesListSuccess(
          items: final items,
          hasMore: final hasMore,
          isLoadingMore: final isLoadingMore,
          loadMoreFailure: final loadMoreFailure,
        ) =>
          _SuccessList(
            key: const ValueKey('success'),
            items: items,
            hasMore: hasMore,
            isLoadingMore: isLoadingMore,
            loadMoreFailure: loadMoreFailure,
            onOpenOpportunity: onOpenOpportunity,
            onLoadMore: onLoadMore,
          ),
        OpportunitiesListEmpty(
          totalCount: final totalCount,
          refreshFailure: final refreshFailure,
        ) =>
          _EmptyList(
            key: const ValueKey('empty'),
            totalCount: totalCount,
            refreshFailure: refreshFailure,
            onRetry: onRetry,
          ),
        OpportunitiesListError(failure: final failure) => _ErrorView(
          key: const ValueKey('error'),
          failure: failure,
          onRetry: onRetry,
        ),
      },
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: 3,
      itemBuilder: (_, _) => const OpportunityCardSkeleton(),
    );
  }
}

class _SuccessList extends StatelessWidget {
  const _SuccessList({
    super.key,
    required this.items,
    required this.hasMore,
    required this.isLoadingMore,
    required this.loadMoreFailure,
    required this.onOpenOpportunity,
    required this.onLoadMore,
  });

  final List items;
  final bool hasMore;
  final bool isLoadingMore;
  final dynamic loadMoreFailure;
  final ValueChanged<int> onOpenOpportunity;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      itemCount: items.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return _LoadMoreFooter(
            isLoading: isLoadingMore,
            failure: loadMoreFailure,
            onRetry: onLoadMore,
          );
        }
        final opportunity = items[index] as dynamic;
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: OpportunityCard(
            opportunity: opportunity,
            onTap: onOpenOpportunity,
          ),
        );
      },
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({
    required this.isLoading,
    this.failure,
    required this.onRetry,
  });

  final bool isLoading;
  final dynamic failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final t = context.t.crm.common;

    if (failure != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 20, color: colors.error),
            SizedBox(width: AppSpacing.sm),
            Text(
              context.failureText(failure as dynamic),
              style: context.textStyles.bodyMedium.copyWith(
                color: colors.error,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            AppButton.outlined(
              label: t.retry,
              onPressed: onRetry,
              isLoading: isLoading,
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: const AnimatedProgressBar(),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Text(
        t.endOfList,
        style: context.textStyles.bodySmall.copyWith(
          color: colors.textSecondary,
        ),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({
    super.key,
    required this.totalCount,
    required this.onRetry,
    this.refreshFailure,
  });

  final int totalCount;
  final VoidCallback onRetry;
  final dynamic refreshFailure;

  @override
  Widget build(BuildContext context) {
    final t = context.t.crm.crmOpportunities;
    final hasNoResults = totalCount == 0;

    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView(
        padding: EdgeInsets.all(AppSpacing.xl),
        children: [
          EmptyState(
            title: hasNoResults ? t.listEmpty : t.listNoResults,
            message: hasNoResults
                ? 'No opportunities found. Pull to refresh.'
                : null,
            icon: Icons.search_off_rounded,
            primaryAction: hasNoResults
                ? null
                : (
                    label: context.t.crm.common.clearFilters,
                    onPressed: onRetry,
                  ),
          ),
          if (refreshFailure != null) ...[
            SizedBox(height: AppSpacing.lg),
            _RefreshNotice(failure: refreshFailure!, onDismiss: () {}),
          ],
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({super.key, required this.failure, required this.onRetry});

  final dynamic failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView(
        padding: EdgeInsets.all(AppSpacing.xl),
        children: [
          ErrorState(
            message: context.failureText(failure),
            retryAction: (
              label: context.t.crm.common.retry,
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshNotice extends StatelessWidget {
  const _RefreshNotice({required this.failure, required this.onDismiss});

  final dynamic failure;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.warningContainer,
        borderRadius: AppRadius.borderMd,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.t.crm.common.refreshFailedNotice,
                style: context.textStyles.bodyMedium.copyWith(
                  color: colors.onWarningContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: onDismiss,
              child: Text(
                context.t.crm.common.dismiss,
                style: context.textStyles.labelLarge.copyWith(
                  color: colors.onWarningContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
