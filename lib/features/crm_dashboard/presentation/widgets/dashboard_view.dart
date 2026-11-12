import 'package:flutter/material.dart';
import 'package:orbit/core/animations/loading/animated_progress_bar.dart';
import 'package:orbit/core/animations/staggered/staggered_list_item.dart';
import 'package:orbit/core/animations/state/animated_visibility.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/widgets/empty_state.dart';

import '../../domain/entities/dashboard_overview_entity.dart';
import '../constants/dashboard_layout_constants.dart';
import '../pure/dashboard_insights.dart';
import 'dashboard_closings_card.dart';
import 'dashboard_hero_card.dart';
import 'dashboard_kpi_grid.dart';
import 'dashboard_pipeline_card.dart';
import 'dashboard_refresh_notice.dart';
import 'dashboard_team_card.dart';
import 'dashboard_win_ratio_card.dart';

/// The dashboard content: pull-to-refresh, a thin progress line while a
/// silent refresh runs, and the cards entering one after another.
class DashboardView extends StatefulWidget {
  const DashboardView({
    super.key,
    required this.overview,
    required this.isRefreshing,
    required this.refreshFailure,
    required this.onRefresh,
  });

  final DashboardOverview overview;
  final bool isRefreshing;
  final Failure? refreshFailure;
  final Future<void> Function() onRefresh;

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  Failure? _dismissed;

  @override
  Widget build(BuildContext context) {
    final overview = widget.overview;
    final failure = widget.refreshFailure;
    final showNotice = failure != null && failure != _dismissed;

    final sections = <Widget>[
      DashboardHeroCard(overview: overview),
      DashboardKpiGrid(overview: overview),
      DashboardWinRatioCard(winRatio: overview.winRatio),
      DashboardPipelineCard(
        stages: overview.stages,
        currency: overview.currency,
      ),
      DashboardClosingsCard(
        months: overview.months,
        currency: overview.currency,
      ),
      DashboardTeamCard(team: overview.salesTeam, currency: overview.currency),
    ];

    return RefreshIndicator(
      color: context.colors.primary,
      backgroundColor: context.colors.surface,
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: AnimatedVisibility(
              visible: widget.isRefreshing,
              child: const AnimatedProgressBar(),
            ),
          ),
          SliverPadding(
            padding: EdgeInsetsDirectional.only(
              start: DashboardLayoutConstants.pageGap,
              end: DashboardLayoutConstants.pageGap,
              top: AppSpacing.sm,
              bottom: DashboardLayoutConstants.listBottomPadding,
            ),
            sliver: SliverList.list(
              children: [
                AnimatedVisibility(
                  visible: showNotice,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      bottom: DashboardLayoutConstants.pageGap,
                    ),
                    child: DashboardRefreshNotice(
                      onDismiss: () => setState(() => _dismissed = failure),
                    ),
                  ),
                ),
                if (hasNoDashboardData(overview))
                  Padding(
                    padding: EdgeInsetsDirectional.only(top: AppSpacing.xl),
                    child: EmptyState(
                      title: context.t.crm.dashboard.empty.title,
                      message: context.t.crm.dashboard.empty.message,
                      icon: Icons.dashboard_customize_rounded,
                    ),
                  )
                else
                  for (final (i, section) in sections.indexed)
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        bottom: DashboardLayoutConstants.pageGap,
                      ),
                      child: StaggeredListItem(index: i, child: section),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
