import 'package:orbit/core/constants/api_keys.dart';

import '../../domain/entities/dashboard_stage_slice_entity.dart';
import '../../domain/enums/dashboard_stage.dart';
import 'dashboard_json.dart';

/// One `pipeline_by_stage` item: `{stage, label, value, count}`.
final class DashboardStageSliceModel {
  const DashboardStageSliceModel({
    required this.stage,
    required this.label,
    required this.value,
    required this.count,
  });

  final String stage;
  final String label;
  final double value;
  final int count;

  factory DashboardStageSliceModel.fromJson(Map<String, dynamic> json) =>
      DashboardStageSliceModel(
        stage: DashboardJson.readString(json[ApiKeys.stageKey]),
        label: DashboardJson.readString(json[ApiKeys.labelKey]),
        value: DashboardJson.readDouble(json[ApiKeys.valueKey]),
        count: DashboardJson.readInt(json[ApiKeys.countKey]),
      );

  DashboardStageSlice toEntity() => DashboardStageSlice(
    stage: DashboardStage.fromValue(stage),
    label: label,
    value: value,
    count: count,
  );
}
