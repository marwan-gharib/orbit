import 'package:equatable/equatable.dart';

/// Lighter note embedded inside an opportunity: no customer details, no
/// employee details — just `employee_name`. Not shared with the standalone
/// `CustomerNote` entity.
final class EmbeddedCustomerNote extends Equatable {
  const EmbeddedCustomerNote({
    required this.noteId,
    required this.employeeId,
    required this.employeeName,
    required this.noteText,
    required this.createdAt,
  });

  final int noteId;
  final int employeeId;
  final String employeeName;
  final String noteText;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    noteId,
    employeeId,
    employeeName,
    noteText,
    createdAt,
  ];
}
