import 'package:equatable/equatable.dart';

import 'package:orbit/core/errors/failures.dart';

import '../../../domain/entities/auth_session_entity.dart';

/// Sealed state hierarchy for the login flow.
sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

/// Initial — no submission in flight.
final class LoginInitial extends LoginState {
  const LoginInitial();
}

/// A submission is in flight.
final class LoginLoading extends LoginState {
  const LoginLoading();
}

/// Sign-in succeeded; [session] was already persisted by the repository.
final class LoginSuccess extends LoginState {
  const LoginSuccess(this.session);

  final AuthSession session;

  @override
  List<Object?> get props => [session];
}

/// Sign-in failed (may be an `InvalidCredentialsFailure` on a login 401);
/// copy comes from `context.failureText` (ERR-4).
final class LoginError extends LoginState {
  const LoginError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
