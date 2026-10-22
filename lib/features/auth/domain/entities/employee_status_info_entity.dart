import 'package:equatable/equatable.dart';

import '../enums/employment_status.dart';

/// A person's employment status, queried by their work email.
final class EmployeeStatusInfo extends Equatable {
  const EmployeeStatusInfo({
    required this.firstName,
    required this.lastName,
    required this.status,
  });

  final String firstName;
  final String lastName;
  final EmploymentStatus status;

  @override
  List<Object?> get props => [firstName, lastName, status];
}
