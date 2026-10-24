import 'package:equatable/equatable.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/features/auth/domain/entities/auth_session_entity.dart';
import 'package:orbit/features/auth/domain/entities/signup_result_entity.dart';

sealed class GoogleSignInState extends Equatable {
  const GoogleSignInState();

  @override
  List<Object?> get props => [];
}

/// Initial resting state, or returned to after cancellation.
final class GoogleSignInIdle extends GoogleSignInState {
  const GoogleSignInIdle();
}

/// Authentication attempt is in flight.
final class GoogleSignInLoading extends GoogleSignInState {
  const GoogleSignInLoading();
}

/// Google sign-in completed successfully for an existing user session.
final class GoogleSignInAuthenticated extends GoogleSignInState {
  const GoogleSignInAuthenticated(this.session);

  final AuthSession session;

  @override
  List<Object?> get props => [session];
}

/// Google sign-in created a new account awaiting employee review.
final class GoogleSignInPending extends GoogleSignInState {
  const GoogleSignInPending(this.result);

  final SignupResult result;

  @override
  List<Object?> get props => [result];
}

/// An error occurred during the Google sign-in flow.
final class GoogleSignInError extends GoogleSignInState {
  const GoogleSignInError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
