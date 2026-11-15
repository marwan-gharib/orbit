import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit/core/animations/selection/selection.dart';
import 'package:orbit/core/animations/state/animated_visibility.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/di/injection_container.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/features/crm_dashboard/presentation/widgets/dashboard_tab.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_bloc.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_delete/interaction_delete_cubit.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_form/interaction_form_cubit.dart';
import 'package:orbit/features/interactions/presentation/widgets/interactions_feed_view.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunities_tab_view.dart';

/// The CRM shell: Dashboard, Opportunities and Interactions tabs (state kept alive)
/// with a floating navigation bar that hides while the user scrolls down.
class CrmShell extends StatefulWidget {
  const CrmShell({super.key});

  @override
  State<CrmShell> createState() => _CrmShellState();
}

class _CrmShellState extends State<CrmShell>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _navVisible = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _pushDetail(int opportunityId) {
    context.push('/crm/opportunities/$opportunityId');
  }

  bool _onScroll(UserScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final show = switch (notification.direction) {
      ScrollDirection.reverse => false,
      ScrollDirection.forward => true,
      ScrollDirection.idle => _navVisible,
    };
    if (show != _navVisible) setState(() => _navVisible = show);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final labels = context.t.crm;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: context.colors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(labels.title),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.textPrimary,
      ),
      body: Stack(
        children: [
          NotificationListener<UserScrollNotification>(
            onNotification: _onScroll,
            child: TabBarView(
              controller: _tabController,
              children: [
                const _KeepAlive(child: DashboardTab()),
                _KeepAlive(
                  child: OpportunitiesTabView(onOpenOpportunity: _pushDetail),
                ),
                _KeepAlive(
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => getIt<InteractionFormCubit>(),
                      ),
                      BlocProvider(
                        create: (context) => getIt<InteractionDeleteCubit>(),
                      ),
                      BlocProvider(
                        create: (context) => getIt<InteractionsListBloc>(),
                      ),
                    ],
                    child: InteractionsFeedView(
                      onOpenOpportunity: _pushDetail,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedVisibility(
              visible: _navVisible,
              collapseSize: false,
              offset: const Offset(0, 1),
              scaleBegin: 0.9,
              child: ListenableBuilder(
                listenable: _tabController,
                builder: (context, _) => FloatingNavBar(
                  selectedIndex: _tabController.index,
                  position: _tabController.animation,
                  onSelected: (index) {
                    setState(() => _navVisible = true);
                    _tabController.animateTo(
                      index,
                      duration: AppDurations.normal,
                      curve: AppCurves.standard,
                    );
                  },
                  items: [
                    FloatingNavItem(
                      label: labels.tabs.dashboard,
                      icon: Icons.dashboard_outlined,
                      selectedIcon: Icons.dashboard_rounded,
                    ),
                    FloatingNavItem(
                      label: labels.tabs.opportunities,
                      icon: Icons.work_outline_rounded,
                      selectedIcon: Icons.work_rounded,
                    ),
                    FloatingNavItem(
                      label: labels.tabs.interactions,
                      icon: Icons.forum_outlined,
                      selectedIcon: Icons.forum_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Keeps a tab's state (scroll position, blocs) alive while it is off-screen.
class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});

  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
