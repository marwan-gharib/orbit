import 'package:flutter/material.dart';
import 'package:orbit/core/animations/state/animated_counter.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_card.dart';

import '../constants/dashboard_layout_constants.dart';

/// One KPI tile: tinted icon, label, a value that counts up, and a caption.
class DashboardKpiCard extends StatelessWidget {
  const DashboardKpiCard({
    super.key,
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
    required this.formatter,
    required this.caption,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final num value;
  final String Function(num value) formatter;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: DashboardLayoutConstants.kpiMinHeight,
      ),
      child: AppCard(
        padding: EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: DashboardLayoutConstants.kpiIconBox,
                  height: DashboardLayoutConstants.kpiIconBox,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Icon(
                    icon,
                    size: DashboardLayoutConstants.kpiIconSize,
                    color: accent,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: textStyles.labelMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            AnimatedCounter(
              value: value,
              formatter: formatter,
              style: textStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSpacing.xxs),
            Text(
              caption,
              style: textStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
