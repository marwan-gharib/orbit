import 'package:equatable/equatable.dart';

import 'package:orbit/core/errors/failures.dart';

import '../../../domain/entities/signup_result_entity.dart';

/// Sealed state hierarchy for the sign-up flow.
sealed class SignupState extends Equatable {
  const SignupState();

  @override
  List<Object?> get props => [];
}

/// Initial — no submission in flight.
final class SignupInitial extends SignupState {
  const SignupInitial();
}

/// A submission is in flight.
final class SignupLoading extends SignupState {
  const SignupLoading();
}

/// Account created; it starts implicitly as `pending` (no tokens arrive).
final class SignupSuccess extends SignupState {
  const SignupSuccess(this.result);

  final SignupResult result;

  @override
  List<Object?> get props => [result];
}

/// Sign-up failed; copy comes from `context.failureText` (ERR-4).
final class SignupError extends SignupState {
  const SignupError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
