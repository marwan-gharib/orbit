import 'package:equatable/equatable.dart';

/// Employee summary shown inside a note; sent as `employee_details` on the
/// notes endpoint and never serialized back.
final class NoteEmployeeDetails extends Equatable {
  const NoteEmployeeDetails({
    required this.employeeId,
    required this.employeeCode,
    required this.name,
    required this.workEmail,
  });

  final int employeeId;
  final String employeeCode;
  final String name;
  final String workEmail;

  @override
  List<Object?> get props => [employeeId, employeeCode, name, workEmail];
}
