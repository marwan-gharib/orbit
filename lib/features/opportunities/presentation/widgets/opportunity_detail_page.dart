import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/animations/state/app_animated_switcher.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/widgets/error_state.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_status.dart';
import 'package:orbit/features/opportunities/presentation/cubits/opportunity_details/opportunity_details_cubit.dart';
import 'package:orbit/features/opportunities/presentation/cubits/opportunity_details/opportunity_details_state.dart';
import 'package:orbit/features/opportunities/presentation/widgets/contacts_tab.dart';
import 'package:orbit/features/opportunities/presentation/widgets/interactions_tab.dart';
import 'package:orbit/features/opportunities/presentation/widgets/notes_tab.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_detail_skeleton.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_header.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_tab_bar.dart';
import 'package:orbit/features/opportunities/presentation/widgets/overview_tab.dart';
import 'package:orbit/features/opportunities/presentation/widgets/progress_card.dart';
import 'package:orbit/features/opportunities/presentation/widgets/status_banner.dart';

/// Full-screen opportunity detail page.
/// Owns its Scaffold, creates its cubit, and composes all detail sections.
class OpportunityDetailPage extends StatelessWidget {
  const OpportunityDetailPage({super.key, required this.opportunityId});

  final int opportunityId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          context.read<OpportunityDetailsCubit>()..load(opportunityId),
      child: _DetailPageContent(opportunityId: opportunityId),
    );
  }
}

class _DetailPageContent extends StatelessWidget {
  const _DetailPageContent({required this.opportunityId});

  final int opportunityId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpportunityDetailsCubit, OpportunityDetailsState>(
      builder: (context, state) {
        return AppAnimatedSwitcher(
          child: switch (state) {
            OpportunityDetailsInitial() || OpportunityDetailsLoading() =>
              const OpportunityDetailSkeleton(key: ValueKey('loading')),
            OpportunityDetailsSuccess(
              opportunity: final opportunity,
              isRefreshing: final isRefreshing,
              refreshFailure: final refreshFailure,
            ) =>
              _DetailPage(
                key: const ValueKey('success'),
                opportunity: opportunity,
                isRefreshing: isRefreshing,
                refreshFailure: refreshFailure,
              ),
            OpportunityDetailsError(failure: final failure) => _ErrorView(
              key: const ValueKey('error'),
              failure: failure,
              onRetry: () => context.read<OpportunityDetailsCubit>().refresh(),
            ),
          },
        );
      },
    );
  }
}

class _DetailPage extends StatefulWidget {
  const _DetailPage({
    super.key,
    required this.opportunity,
    required this.isRefreshing,
    this.refreshFailure,
  });

  final Opportunity opportunity;
  final bool isRefreshing;
  final dynamic refreshFailure;

  @override
  State<_DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<_DetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opportunity = widget.opportunity;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsing SliverAppBar with back button only
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: context.colors.surface,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: context.colors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: OpportunityHeader(opportunity: opportunity),
              collapseMode: CollapseMode.parallax,
            ),
            expandedHeight: 320,
          ),

          // Status banner (won/lost only)
          if (widget.opportunity.status != OpportunityStatus.open)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: StatusBanner(opportunity: widget.opportunity),
              ),
            ),

          // Progress card
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: ProgressCard(opportunity: widget.opportunity),
            ),
          ),

          // Sticky tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabBar: OpportunityTabBar(
                tabController: _tabController,
                contactsCount: widget.opportunity.customer.contacts.length,
                interactionsCount:
                    widget.opportunity.customer.interactions.length,
                notesCount: widget.opportunity.customer.notes.length,
              ),
            ),
          ),

          // Tab content with fade-through
          SliverFillRemaining(
            hasScrollBody: false,
            child: TabBarView(
              controller: _tabController,
              children: [
                OverviewTab(opportunity: widget.opportunity),
                ContactsTab(opportunity: widget.opportunity),
                InteractionsTab(opportunity: widget.opportunity),
                NotesTab(opportunity: widget.opportunity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate({required this.tabBar});

  final OpportunityTabBar tabBar;

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
      child: tabBar,
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({super.key, required this.failure, required this.onRetry});

  final dynamic failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
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
      ),
    );
  }
}
