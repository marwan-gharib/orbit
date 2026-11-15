import 'package:flutter/material.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/empty_state.dart';
import 'package:orbit/core/widgets/error_state.dart';

/// Non-blocking, dismissible notice shown above the list when a silent
/// refresh failed. Loaded items stay on screen.
class RefreshFailedNotice extends StatelessWidget {
  const RefreshFailedNotice({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final common = context.t.crm.common;

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.warningContainer,
          borderRadius: AppRadius.borderMd,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: AppSpacing.md,
            end: AppSpacing.xs,
            top: AppSpacing.xs,
            bottom: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  common.refreshFailedNotice,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: colors.onWarningContainer,
                  ),
                ),
              ),
              TextButton(
                onPressed: onDismiss,
                child: Text(
                  common.dismiss,
                  style: context.textStyles.labelLarge.copyWith(
                    color: colors.onWarningContainer,
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

/// Empty list: "nothing yet" vs "nothing matches the current filters".
class OpportunitiesEmptyView extends StatelessWidget {
  const OpportunitiesEmptyView({
    super.key,
    required this.isFiltered,
    required this.onClearFilters,
  });

  final bool isFiltered;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final t = context.t.crm.crmOpportunities;

    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.all(AppSpacing.xl),
        child: EmptyState(
          title: isFiltered ? t.listNoResults : t.listEmpty,
          icon: isFiltered
              ? Icons.search_off_rounded
              : Icons.work_outline_rounded,
          primaryAction: isFiltered
              ? (
                  label: context.t.crm.common.clearFilters,
                  onPressed: onClearFilters,
                )
              : null,
        ),
      ),
    );
  }
}

/// Full error view with retry.
class OpportunitiesErrorView extends StatelessWidget {
  const OpportunitiesErrorView({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.all(AppSpacing.xl),
        child: ErrorState(
          message: context.failureText(failure),
          retryAction: (
            label: context.t.crm.common.retry,
            onPressed: onRetry,
          ),
        ),
      ),
    );
  }
}
