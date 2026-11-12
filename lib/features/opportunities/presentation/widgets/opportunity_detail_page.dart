import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit/core/animations/state/animated_visibility.dart';
import 'package:orbit/core/animations/state/app_animated_switcher.dart';
import 'package:orbit/core/di/injection_container.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_notes_list/customer_notes_list_cubit.dart';
import 'package:orbit/features/customer_notes/presentation/widgets/customer_note_composer.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_bloc.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_event.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_state.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_status.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';
import 'package:orbit/features/opportunities/presentation/cubits/opportunity_details/opportunity_details_cubit.dart';
import 'package:orbit/features/opportunities/presentation/cubits/opportunity_details/opportunity_details_state.dart';
import 'package:orbit/features/opportunities/presentation/widgets/contacts_tab.dart';
import 'package:orbit/features/opportunities/presentation/widgets/interactions_tab.dart';
import 'package:orbit/features/opportunities/presentation/widgets/notes_tab.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_detail_app_bar.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_detail_error_view.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_detail_skeleton.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_tab_bar.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_tab_bar_delegate.dart';
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
            OpportunityDetailsError(failure: final failure) =>
              OpportunityDetailErrorView(
                key: const ValueKey('error'),
                failure: failure,
                onRetry: () =>
                    context.read<OpportunityDetailsCubit>().refresh(),
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
  final Failure? refreshFailure;

  @override
  State<_DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<_DetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  /// Page-scoped sources for the tabs: they live as long as the page, so a
  /// tab keeps its loaded data while the user visits other tabs.
  late final CustomerNotesListCubit _notesCubit;
  late final InteractionsListBloc _interactionsBloc;

  /// 0 = header fully visible, 1 = scrolled past it (compact title shown).
  final ValueNotifier<double> _collapse = ValueNotifier<double>(0);
  int _selectedTab = 0;

  /// Tabs opened at least once; the rest are not built (and not loaded) yet.
  final Set<int> _visitedTabs = {0};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_syncCollapse);

    final opportunity = widget.opportunity;
    _notesCubit = getIt<CustomerNotesListCubit>()
      ..load(opportunity.customer.customerId);
    _interactionsBloc = getIt<InteractionsListBloc>()
      ..add(
        InteractionsListFiltersChanged(
          opportunityId: opportunity.opportunityId,
        ),
      );
  }

  void _syncCollapse() {
    if (!_scrollController.hasClients) return;
    _collapse.value =
        (_scrollController.offset /
                OpportunityLayoutConstants.headerFadeDistance)
            .clamp(0.0, 1.0);
  }

  /// The scroll position is clamped without a scroll event when the content
  /// gets shorter (e.g. switching to a shorter tab); re-read it afterwards.
  bool _onMetricsChanged(ScrollMetricsNotification notification) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncCollapse();
    });
    return false;
  }

  void _onTabChanged() {
    if (_tabController.index != _selectedTab) {
      setState(() {
        _selectedTab = _tabController.index;
        _visitedTabs.add(_selectedTab);
      });
    }
  }

  /// Tapping the tab that is already open refreshes its data.
  void _onTabTap(int index) {
    if (_tabController.indexIsChanging) return;
    switch (index) {
      case 0 || 1:
        context.read<OpportunityDetailsCubit>().refresh();
      case 2:
        _interactionsBloc.add(const InteractionsListRefreshed());
      default:
        _notesCubit.refresh();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController
      ..removeListener(_syncCollapse)
      ..dispose();
    _collapse.dispose();
    _notesCubit.close();
    _interactionsBloc.close();
    super.dispose();
  }

  Widget _tabBody(int index, Opportunity opportunity) => switch (index) {
    0 => OverviewTab(opportunity: opportunity),
    1 => ContactsTab(opportunity: opportunity),
    2 => InteractionsTab(opportunity: opportunity),
    _ => NotesTab(opportunity: opportunity, cubit: _notesCubit),
  };

  @override
  Widget build(BuildContext context) {
    final opportunity = widget.opportunity;
    final colors = context.colors;

    return MultiBlocProvider(
      providers: [
        BlocProvider<CustomerNotesListCubit>.value(value: _notesCubit),
        BlocProvider<InteractionsListBloc>.value(value: _interactionsBloc),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: NotificationListener<ScrollMetricsNotification>(
          onNotification: _onMetricsChanged,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              DetailAppBar(collapse: _collapse, title: opportunity.title),
              DetailHeaderSliver(collapse: _collapse, opportunity: opportunity),
              if (opportunity.status != OpportunityStatus.open)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: StatusBanner(opportunity: opportunity),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: ProgressCard(opportunity: opportunity),
                ),
              ),
              BlocBuilder<InteractionsListBloc, InteractionsListState>(
                builder: (context, interactionsState) {
                  final interactionsCount = switch (interactionsState) {
                    InteractionsListSuccess(:final interactions) =>
                      interactions.length,
                    _ => 0,
                  };
                  return SliverPersistentHeader(
                    pinned: true,
                    delegate: OpportunityTabBarDelegate(
                      tabBar: OpportunityTabBar(
                        tabController: _tabController,
                        onTap: _onTabTap,
                        contactsCount: opportunity.customer.contacts.length,
                        interactionsCount: interactionsCount,
                        notesCount: opportunity.customer.notes.length,
                      ),
                    ),
                  );
                },
              ),
              // Every visited tab stays mounted (state + data kept); only the
              // selected one takes space.
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < 4; i++)
                      AnimatedVisibility(
                        visible: i == _selectedTab,
                        maintainState: true,
                        child: _visitedTabs.contains(i)
                            ? _tabBody(i, opportunity)
                            : const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AnimatedVisibility(
          visible: _selectedTab == 3,
          axis: Axis.vertical,
          collapseSize: true,
          child: ColoredBox(
            color: colors.surface,
            child: CustomerNoteComposer(
              customerId: opportunity.customer.customerId,
            ),
          ),
        ),
      ),
    );
  }
}
