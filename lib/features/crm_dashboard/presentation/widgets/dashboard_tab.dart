import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit/core/animations/state/app_animated_switcher.dart';
import 'package:orbit/core/di/injection_container.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/widgets/error_state.dart';

import '../cubits/dashboard/dashboard_cubit.dart';
import '../cubits/dashboard/dashboard_state.dart';
import 'dashboard_skeleton.dart';
import 'dashboard_view.dart';

/// The CRM dashboard tab: loads on first display, shows a skeleton shaped
/// like the dashboard, the figures, or a retryable error. The cubit lives as
/// long as the tab (the shell keeps the tab alive).
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (_) => getIt<DashboardCubit>()..load(),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) => AppAnimatedSwitcher(
          child: switch (state) {
            DashboardInitial() || DashboardLoading() => const DashboardSkeleton(
              key: ValueKey('loading'),
            ),
            DashboardError(:final failure) => Center(
              key: const ValueKey('error'),
              child: Padding(
                padding: EdgeInsetsDirectional.all(AppSpacing.xl),
                child: ErrorState(
                  message: context.failureText(failure),
                  retryAction: (
                    label: context.t.crm.common.retry,
                    onPressed: () => context.read<DashboardCubit>().load(),
                  ),
                ),
              ),
            ),
            DashboardSuccess(
              :final overview,
              :final isRefreshing,
              :final refreshFailure,
            ) =>
              DashboardView(
                key: const ValueKey('content'),
                overview: overview,
                isRefreshing: isRefreshing,
                refreshFailure: refreshFailure,
                onRefresh: () => context.read<DashboardCubit>().refresh(),
              ),
          },
        ),
      ),
    );
  }
}
