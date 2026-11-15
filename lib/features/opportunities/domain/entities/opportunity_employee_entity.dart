import 'package:equatable/equatable.dart';

/// The opportunity owner (`{employee_id, employee_name}` on the wire), not
/// the signed-in employee. Never used for `employee_id` on writes.
final class OpportunityEmployee extends Equatable {
  const OpportunityEmployee({
    required this.employeeId,
    required this.employeeName,
  });

  final int employeeId;
  final String employeeName;

  @override
  List<Object?> get props => [employeeId, employeeName];
}
