import 'package:equatable/equatable.dart';

import 'note_customer_details_entity.dart';
import 'note_employee_details_entity.dart';

/// A customer note as the standalone notes list shows it (the opportunity
/// embedded shape is lighter and lives in the opportunities feature).
final class CustomerNote extends Equatable {
  const CustomerNote({
    required this.noteId,
    required this.customerId,
    required this.employeeId,
    required this.noteText,
    required this.createdAt,
    required this.customerDetails,
    required this.employeeDetails,
  });

  final int noteId;
  final int customerId;
  final int employeeId;
  final String noteText;
  final DateTime createdAt;
  final NoteCustomerDetails customerDetails;
  final NoteEmployeeDetails employeeDetails;

  @override
  List<Object?> get props => [
    noteId,
    customerId,
    employeeId,
    noteText,
    createdAt,
    customerDetails,
    employeeDetails,
  ];
}
