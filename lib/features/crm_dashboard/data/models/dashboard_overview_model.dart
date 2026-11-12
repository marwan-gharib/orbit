import 'package:orbit/core/constants/api_keys.dart';

import '../../domain/entities/dashboard_overview_entity.dart';
import 'dashboard_json.dart';
import 'dashboard_metric_model.dart';
import 'dashboard_month_point_model.dart';
import 'dashboard_salesperson_model.dart';
import 'dashboard_stage_slice_model.dart';
import 'dashboard_win_ratio_model.dart';

/// The whole `GET /crm/overview/` body.
final class DashboardOverviewModel {
  const DashboardOverviewModel({
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

  final String currency;
  final DashboardMetricModel openPipeline;
  final double weightedForecast;
  final DashboardMetricModel won;
  final DashboardWinRatioModel winRatio;
  final int pastExpectedCloseCount;
  final List<DashboardStageSliceModel> stages;
  final List<DashboardMonthPointModel> months;
  final List<DashboardSalespersonModel> salesTeam;

  factory DashboardOverviewModel.fromJson(Map<String, dynamic> json) =>
      DashboardOverviewModel(
        currency: DashboardJson.readString(json[ApiKeys.currencyKey]),
        openPipeline: DashboardMetricModel.fromJson(
          DashboardJson.readMap(json[ApiKeys.openPipelineKey]),
        ),
        weightedForecast: DashboardJson.readDouble(
          DashboardJson.readMap(json[ApiKeys.weightedForecastKey])[ApiKeys
              .valueKey],
        ),
        won: DashboardMetricModel.fromJson(
          DashboardJson.readMap(json[ApiKeys.wonKey]),
        ),
        winRatio: DashboardWinRatioModel.fromJson(
          DashboardJson.readMap(json[ApiKeys.winRatioKey]),
        ),
        pastExpectedCloseCount: DashboardJson.readInt(
          DashboardJson.readMap(json[ApiKeys.pastExpectedCloseKey])[ApiKeys
              .countKey],
        ),
        stages: [
          for (final item in DashboardJson.readObjects(
            json[ApiKeys.pipelineByStageKey],
            ApiKeys.pipelineByStageKey,
          ))
            DashboardStageSliceModel.fromJson(item),
        ],
        months: [
          for (final item in DashboardJson.readObjects(
            json[ApiKeys.expectedClosingsByMonthKey],
            ApiKeys.expectedClosingsByMonthKey,
          ))
            DashboardMonthPointModel.fromJson(item),
        ],
        salesTeam: [
          for (final item in DashboardJson.readObjects(
            json[ApiKeys.salesTeamKey],
            ApiKeys.salesTeamKey,
          ))
            DashboardSalespersonModel.fromJson(item),
        ],
      );

  DashboardOverview toEntity() => DashboardOverview(
    currency: currency,
    openPipeline: openPipeline.toEntity(),
    weightedForecast: weightedForecast,
    won: won.toEntity(),
    winRatio: winRatio.toEntity(),
    pastExpectedCloseCount: pastExpectedCloseCount,
    stages: stages.map((m) => m.toEntity()).toList(),
    months: months.map((m) => m.toEntity()).toList(),
    salesTeam: salesTeam.map((m) => m.toEntity()).toList(),
  );
}
