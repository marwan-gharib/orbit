import 'package:flutter/material.dart';
import 'package:orbit/core/animations/loading/animated_progress_bar.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// End of the list: loader while a page loads, inline retry row when the page
/// failed (loaded items stay), "end of list" marker once nothing is left.
class OpportunitiesListFooter extends StatelessWidget {
  const OpportunitiesListFooter({
    super.key,
    required this.hasMore,
    required this.isLoadingMore,
    required this.failure,
    required this.onRetry,
  });

  final bool hasMore;
  final bool isLoadingMore;
  final Failure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final common = context.t.crm.common;
    final textStyles = context.textStyles;
    final error = failure;

    final Widget content;
    if (error != null) {
      content = Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colors.error),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.failureText(error),
              style: textStyles.bodyMedium.copyWith(color: colors.error),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          AppButton.outlined(
            label: common.retry,
            onPressed: onRetry,
            isLoading: isLoadingMore,
          ),
        ],
      );
    } else if (isLoadingMore) {
      content = const AnimatedProgressBar();
    } else if (!hasMore) {
      content = Center(
        child: Text(
          common.endOfList,
          style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
        ),
      );
    } else {
      content = const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: AppSpacing.sm,
        bottom: OpportunityLayoutConstants.listBottomPadding,
      ),
      child: content,
    );
  }
}
