import 'package:orbit/core/constants/api_keys.dart';

import '../../domain/entities/dashboard_metric_entity.dart';
import 'dashboard_json.dart';

/// `{value, count}`.
final class DashboardMetricModel {
  const DashboardMetricModel({required this.value, required this.count});

  final double value;
  final int count;

  factory DashboardMetricModel.fromJson(Map<String, dynamic> json) =>
      DashboardMetricModel(
        value: DashboardJson.readDouble(json[ApiKeys.valueKey]),
        count: DashboardJson.readInt(json[ApiKeys.countKey]),
      );

  DashboardMetric toEntity() => DashboardMetric(value: value, count: count);
}
