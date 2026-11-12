import 'package:flutter/material.dart';
import 'package:orbit/core/animations/loading/animated_progress_bar.dart';
import 'package:orbit/core/animations/state/animated_counter.dart';
import 'package:orbit/core/animations/state/progress_driver.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/utils/formatters.dart';

import '../../domain/entities/dashboard_salesperson_entity.dart';
import '../constants/dashboard_layout_constants.dart';

/// One leaderboard row: rank, initials avatar, name, deals won, a bar relative
/// to the top performer, and the won value counting up.
class DashboardTeamRow extends StatelessWidget {
  const DashboardTeamRow({
    super.key,
    required this.rank,
    required this.person,
    required this.share,
    required this.currency,
  });

  /// 1-based position in the ranking.
  final int rank;
  final DashboardSalesperson person;

  /// Won value as a share (0..1) of the top performer's.
  final double share;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final isTop = rank == 1;
    final accent = isTop ? colors.warning : colors.primary;

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: DashboardLayoutConstants.rankBadge,
            height: DashboardLayoutConstants.rankBadge,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isTop ? colors.warningContainer : colors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: isTop
                ? Icon(
                    Icons.workspace_premium_rounded,
                    size: DashboardLayoutConstants.kpiIconSize * 0.7,
                    color: colors.onWarningContainer,
                  )
                : Text('$rank', style: textStyles.labelSmall),
          ),
          SizedBox(width: AppSpacing.sm),
          CircleAvatar(
            radius: DashboardLayoutConstants.avatarSize / 2,
            backgroundColor: colors.primaryContainer,
            child: Text(
              _initials(person.employeeName),
              style: textStyles.labelLarge.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.employeeName,
                  style: textStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  context.t.crm.dashboard.team.wonDeals(count: person.wonCount),
                  style: textStyles.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                ProgressDriver(
                  duration: AppDurations.extraSlow,
                  active: true,
                  delayFraction: (rank - 1) * 0.08,
                  builder: (context, progress, _) => SizedBox(
                    width: double.infinity,
                    child: AnimatedProgressBar(
                      progress: share * AppCurves.standard.transform(progress),
                      height: DashboardLayoutConstants.teamBarHeight,
                      color: accent,
                      backgroundColor: colors.surfaceContainerHighest,
                    ),
                  ),
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          AnimatedCounter(
            value: person.wonValue,
            formatter: (n) => Formatters.compact(n),
            style: textStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final list = parts.toList();
    if (list.isEmpty) return '?';
    if (list.length == 1) return list.first[0].toUpperCase();
    return (list.first[0] + list.last[0]).toUpperCase();
  }
}
