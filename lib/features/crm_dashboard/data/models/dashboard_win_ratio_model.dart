import 'package:orbit/core/constants/api_keys.dart';

import '../../domain/entities/dashboard_win_ratio_entity.dart';
import 'dashboard_json.dart';

/// `{percentage, won_count, lost_count}`.
final class DashboardWinRatioModel {
  const DashboardWinRatioModel({
    required this.percentage,
    required this.wonCount,
    required this.lostCount,
  });

  final double percentage;
  final int wonCount;
  final int lostCount;

  factory DashboardWinRatioModel.fromJson(Map<String, dynamic> json) =>
      DashboardWinRatioModel(
        percentage: DashboardJson.readDouble(json[ApiKeys.percentageKey]),
        wonCount: DashboardJson.readInt(json[ApiKeys.wonCountKey]),
        lostCount: DashboardJson.readInt(json[ApiKeys.lostCountKey]),
      );

  DashboardWinRatio toEntity() => DashboardWinRatio(
    percentage: percentage,
    wonCount: wonCount,
    lostCount: lostCount,
  );
}
