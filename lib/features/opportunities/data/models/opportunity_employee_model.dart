import 'package:orbit/core/constants/api_keys.dart';

import '../../domain/entities/opportunity_employee_entity.dart';

/// `{employee_id, employee_name}` nested in an opportunity — the owner, not
/// the signed-in employee.
final class OpportunityEmployeeModel {
  const OpportunityEmployeeModel({
    required this.employeeId,
    required this.employeeName,
  });

  final int employeeId;
  final String employeeName;

  factory OpportunityEmployeeModel.fromJson(Map<String, dynamic> json) =>
      OpportunityEmployeeModel(
        employeeId: json[ApiKeys.employeeIdKey] as int,
        employeeName: json[ApiKeys.employeeNameKey] as String? ?? '',
      );

  OpportunityEmployee toEntity() =>
      OpportunityEmployee(employeeId: employeeId, employeeName: employeeName);
}
