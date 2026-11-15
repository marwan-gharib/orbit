import 'package:flutter/material.dart';
import 'package:orbit/core/animations/selection/selection.dart';
import 'package:orbit/core/animations/state/app_animated_switcher.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/utils/formatters.dart';
import 'package:orbit/core/widgets/app_card.dart';

import '../../domain/entities/dashboard_stage_slice_entity.dart';
import '../constants/dashboard_layout_constants.dart';
import 'dashboard_card_header.dart';
import 'pipeline_bars_view.dart';
import 'pipeline_donut_view.dart';
import 'pipeline_funnel_view.dart';

enum _PipelineView { funnel, donut, bars }

/// The pipeline by stage in three views of the same data (funnel, donut,
/// bars) and two metrics (value, count), switched with sliding selectors.
class DashboardPipelineCard extends StatefulWidget {
  const DashboardPipelineCard({
    super.key,
    required this.stages,
    required this.currency,
  });

  final List<DashboardStageSlice> stages;
  final String currency;

  @override
  State<DashboardPipelineCard> createState() => _DashboardPipelineCardState();
}

class _DashboardPipelineCardState extends State<DashboardPipelineCard> {
  _PipelineView _view = _PipelineView.funnel;
  bool _byValue = true;

  @override
  Widget build(BuildContext context) {
    final t = context.t.crm.dashboard.pipeline;
    final stages = widget.stages;

    String format(double v) => _byValue
        ? Formatters.compact(v)
        : t.dealsCount(count: v.round());

    return AppCard(
      padding: EdgeInsetsDirectional.all(DashboardLayoutConstants.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardCardHeader(
            title: t.title,
            subtitle: _byValue ? widget.currency : t.metricCount,
          ),
          SizedBox(height: AppSpacing.md),
          AnimatedChipSelector<_PipelineView>(
            selectedValue: _view,
            onChanged: (v) => setState(() => _view = v),
            items: [
              ChipItem(
                value: _PipelineView.funnel,
                label: t.viewFunnel,
                icon: Icons.filter_alt_rounded,
              ),
              ChipItem(
                value: _PipelineView.donut,
                label: t.viewDonut,
                icon: Icons.donut_large_rounded,
              ),
              ChipItem(
                value: _PipelineView.bars,
                label: t.viewBars,
                icon: Icons.bar_chart_rounded,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          AnimatedChipSelector<bool>(
            selectedValue: _byValue,
            onChanged: (v) => setState(() => _byValue = v),
            items: [
              ChipItem(value: true, label: t.metricValue),
              ChipItem(value: false, label: t.metricCount),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          if (stages.isEmpty)
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                vertical: AppSpacing.lg,
              ),
              child: Center(
                child: Text(
                  t.empty,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            )
          else
            AppAnimatedSwitcher(
              child: KeyedSubtree(
                key: ValueKey('$_view-$_byValue'),
                child: switch (_view) {
                  _PipelineView.funnel => PipelineFunnelView(
                    stages: stages,
                    byValue: _byValue,
                    format: format,
                  ),
                  _PipelineView.donut => PipelineDonutView(
                    stages: stages,
                    byValue: _byValue,
                    format: format,
                  ),
                  _PipelineView.bars => PipelineBarsView(
                    stages: stages,
                    byValue: _byValue,
                    format: format,
                  ),
                },
              ),
            ),
        ],
      ),
    );
  }
}
