import 'package:equatable/equatable.dart';

import 'package:orbit/core/errors/failures.dart';

import '../../../domain/entities/employee_status_info_entity.dart';

/// Sealed state hierarchy for the employee-status check.
sealed class EmployeeStatusState extends Equatable {
  const EmployeeStatusState();

  @override
  List<Object?> get props => [];
}

/// Initial — no check in flight.
final class EmployeeStatusInitial extends EmployeeStatusState {
  const EmployeeStatusInitial();
}

/// A check is in flight.
final class EmployeeStatusLoading extends EmployeeStatusState {
  const EmployeeStatusLoading();
}

/// The account's status was resolved (enum covers pending/approved/rejected
/// plus the `unknown` fallback).
final class EmployeeStatusSuccess extends EmployeeStatusState {
  const EmployeeStatusSuccess(this.info);

  final EmployeeStatusInfo info;

  @override
  List<Object?> get props => [info];
}

/// Check failed; copy comes from `context.failureText` (ERR-4).
final class EmployeeStatusError extends EmployeeStatusState {
  const EmployeeStatusError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
