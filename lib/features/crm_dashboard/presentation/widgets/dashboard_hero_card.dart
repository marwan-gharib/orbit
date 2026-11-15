import 'package:flutter/material.dart';
import 'package:orbit/core/animations/state/animated_counter.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/utils/formatters.dart';

import '../../domain/entities/dashboard_overview_entity.dart';
import '../constants/dashboard_layout_constants.dart';
import '../pure/dashboard_insights.dart';
import 'dashboard_ring.dart';

/// Top card: the open pipeline value (counts up) next to a ring showing how
/// much of it the weighted forecast covers.
class DashboardHeroCard extends StatelessWidget {
  const DashboardHeroCard({super.key, required this.overview});

  final DashboardOverview overview;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final t = context.t.crm.dashboard.hero;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: AppRadius.borderXl,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(
          DashboardLayoutConstants.cardPadding,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.openPipeline,
                    style: textStyles.labelLarge.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  AnimatedCounter(
                    value: overview.openPipeline.value,
                    formatter: (n) =>
                        Formatters.money(n.round(), overview.currency),
                    style: textStyles.headlineSmall.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    t.opportunities(count: overview.openPipeline.count),
                    style: textStyles.bodySmall.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DashboardRing(
                  fraction: forecastCoverage(overview),
                  color: colors.primary,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  t.forecastCoverage,
                  style: textStyles.labelSmall.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
