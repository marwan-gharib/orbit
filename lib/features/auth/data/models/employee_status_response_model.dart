import 'package:orbit/core/constants/api_keys.dart';

import 'package:orbit/features/auth/domain/entities/employee_status_info_entity.dart';
import 'package:orbit/features/auth/domain/enums/employment_status.dart';

/// The employee-status response: `{ user: { first_name, last_name, status } }`.
final class EmployeeStatusResponseModel {
  const EmployeeStatusResponseModel({
    required this.firstName,
    required this.lastName,
    required this.status,
  });

  final String firstName;
  final String lastName;
  final EmploymentStatus status;

  factory EmployeeStatusResponseModel.fromJson(Map<String, dynamic> json) {
    final user = json[ApiKeys.userKey];
    if (user is! Map) {
      throw const FormatException(
        'Employee status response is missing the user object.',
      );
    }
    final userMap = Map<String, dynamic>.from(user);
    return EmployeeStatusResponseModel(
      firstName: userMap[ApiKeys.firstNameKey] as String,
      lastName: userMap[ApiKeys.lastNameKey] as String,
      status: EmploymentStatus.fromValue(userMap[ApiKeys.statusKey] as String?),
    );
  }

  EmployeeStatusInfo toEntity() => EmployeeStatusInfo(
    firstName: firstName,
    lastName: lastName,
    status: status,
  );
}
