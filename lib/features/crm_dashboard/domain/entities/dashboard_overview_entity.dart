import 'package:equatable/equatable.dart';

import 'dashboard_metric_entity.dart';
import 'dashboard_month_point_entity.dart';
import 'dashboard_salesperson_entity.dart';
import 'dashboard_stage_slice_entity.dart';
import 'dashboard_win_ratio_entity.dart';

/// Everything the CRM dashboard shows, from one `GET /crm/overview/`.
final class DashboardOverview extends Equatable {
  const DashboardOverview({
    required this.currency,
    required this.openPipeline,
    required this.weightedForecast,
    required this.won,
    required this.winRatio,
    required this.pastExpectedCloseCount,
    required this.stages,
    required this.months,
    required this.salesTeam,
  });

  /// ISO code every money value is expressed in.
  final String currency;
  final DashboardMetric openPipeline;
  final double weightedForecast;
  final DashboardMetric won;
  final DashboardWinRatio winRatio;

  /// Open opportunities whose expected close date has passed.
  final int pastExpectedCloseCount;
  final List<DashboardStageSlice> stages;
  final List<DashboardMonthPoint> months;
  final List<DashboardSalesperson> salesTeam;

  @override
  List<Object?> get props => [
    currency,
    openPipeline,
    weightedForecast,
    won,
    winRatio,
    pastExpectedCloseCount,
    stages,
    months,
    salesTeam,
  ];
}
