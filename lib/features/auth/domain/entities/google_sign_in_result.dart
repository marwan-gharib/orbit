import 'package:equatable/equatable.dart';
import 'package:orbit/features/auth/domain/entities/auth_session_entity.dart';
import 'package:orbit/features/auth/domain/entities/signup_result_entity.dart';

/// Result entity for Google Sign-In, representing either an existing user
/// session or a newly registered user awaiting employee verification.
sealed class GoogleSignInResult extends Equatable {
  const GoogleSignInResult();
}

final class GoogleLoggedIn extends GoogleSignInResult {
  const GoogleLoggedIn(this.session);

  final AuthSession session;

  @override
  List<Object?> get props => [session];
}

final class GoogleRegistered extends GoogleSignInResult {
  const GoogleRegistered(this.signupResult);

  final SignupResult signupResult;

  @override
  List<Object?> get props => [signupResult];
}
