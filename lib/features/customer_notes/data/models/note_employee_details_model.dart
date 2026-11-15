import 'package:orbit/core/constants/api_keys.dart';

import '../../domain/entities/note_employee_details_entity.dart';

/// `employee_details` inside a note.
final class NoteEmployeeDetailsModel {
  const NoteEmployeeDetailsModel({
    required this.employeeId,
    required this.employeeCode,
    required this.name,
    required this.workEmail,
  });

  final int employeeId;
  final String employeeCode;
  final String name;
  final String workEmail;

  factory NoteEmployeeDetailsModel.fromJson(Map<String, dynamic> json) =>
      NoteEmployeeDetailsModel(
        employeeId: json[ApiKeys.employeeIdKey] as int,
        employeeCode: json[ApiKeys.employeeCodeKey] as String? ?? '',
        name: json[ApiKeys.nameKey] as String? ?? '',
        workEmail: json[ApiKeys.workEmailKey] as String? ?? '',
      );

  NoteEmployeeDetails toEntity() => NoteEmployeeDetails(
    employeeId: employeeId,
    employeeCode: employeeCode,
    name: name,
    workEmail: workEmail,
  );
}
