import 'package:orbit/core/constants/api_keys.dart';

import '../../domain/entities/dashboard_month_point_entity.dart';
import 'dashboard_json.dart';

/// One `expected_closings_by_month` item.
final class DashboardMonthPointModel {
  const DashboardMonthPointModel({
    required this.month,
    required this.label,
    required this.dealValue,
    required this.weightedValue,
  });

  final String month;
  final String label;
  final double dealValue;
  final double weightedValue;

  factory DashboardMonthPointModel.fromJson(Map<String, dynamic> json) =>
      DashboardMonthPointModel(
        month: DashboardJson.readString(json[ApiKeys.monthKey]),
        label: DashboardJson.readString(json[ApiKeys.labelKey]),
        dealValue: DashboardJson.readDouble(json[ApiKeys.dealValueKey]),
        weightedValue: DashboardJson.readDouble(json[ApiKeys.weightedValueKey]),
      );

  DashboardMonthPoint toEntity() => DashboardMonthPoint(
    month: month,
    label: label,
    dealValue: dealValue,
    weightedValue: weightedValue,
  );
}
