import 'package:orbit/core/constants/api_keys.dart';

import '../../domain/entities/dashboard_salesperson_entity.dart';
import 'dashboard_json.dart';

/// One `sales_team` item.
final class DashboardSalespersonModel {
  const DashboardSalespersonModel({
    required this.employeeId,
    required this.employeeName,
    required this.wonValue,
    required this.wonCount,
  });

  final int employeeId;
  final String employeeName;
  final double wonValue;
  final int wonCount;

  factory DashboardSalespersonModel.fromJson(Map<String, dynamic> json) =>
      DashboardSalespersonModel(
        employeeId: DashboardJson.readInt(json[ApiKeys.employeeIdKey]),
        employeeName: DashboardJson.readString(json[ApiKeys.employeeNameKey]),
        wonValue: DashboardJson.readDouble(json[ApiKeys.wonValueKey]),
        wonCount: DashboardJson.readInt(json[ApiKeys.wonCountKey]),
      );

  DashboardSalesperson toEntity() => DashboardSalesperson(
    employeeId: employeeId,
    employeeName: employeeName,
    wonValue: wonValue,
    wonCount: wonCount,
  );
}
