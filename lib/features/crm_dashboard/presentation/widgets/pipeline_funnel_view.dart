import 'package:flutter/material.dart';
import 'package:orbit/core/animations/state/progress_driver.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import '../../domain/entities/dashboard_stage_slice_entity.dart';
import '../constants/dashboard_layout_constants.dart';
import '../pure/dashboard_insights.dart';
import '../pure/dashboard_palette.dart';

/// One centred bar per stage whose width follows the chosen metric, so the
/// pipeline reads as a funnel. Bars widen one after another on display.
class PipelineFunnelView extends StatelessWidget {
  const PipelineFunnelView({
    super.key,
    required this.stages,
    required this.byValue,
    required this.format,
  });

  final List<DashboardStageSlice> stages;
  final bool byValue;
  final String Function(double value) format;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final metrics = [for (final s in stages) stageMetric(s, byValue: byValue)];
    final max = metrics.fold<double>(0, (m, v) => v > m ? v : m);

    return Column(
      children: [
        for (final (i, stage) in stages.indexed)
          Padding(
            padding: EdgeInsetsDirectional.only(
              bottom: i < stages.length - 1 ? AppSpacing.md : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stage.label,
                        style: textStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      format(metrics[i]),
                      style: textStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                ProgressDriver(
                  duration: AppDurations.extraSlow,
                  active: true,
                  delayFraction: i * 0.1,
                  builder: (context, progress, _) => DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: AppRadius.borderFull,
                    ),
                    child: SizedBox(
                      height: DashboardLayoutConstants.funnelBarHeight,
                      child: FractionallySizedBox(
                        alignment: Alignment.center,
                        widthFactor: (shareOf(metrics[i], max) *
                                AppCurves.standard.transform(progress))
                            .clamp(0.0, 1.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: dashboardStageColor(context, stage.stage),
                            borderRadius: AppRadius.borderFull,
                          ),
                        ),
                      ),
                    ),
                  ),
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
