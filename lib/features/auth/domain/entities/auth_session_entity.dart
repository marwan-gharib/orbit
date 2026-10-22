import 'package:equatable/equatable.dart';

import 'user_entity.dart';

/// The login response as the app keeps it: tokens plus the signed-in user.
final class AuthSession extends Equatable {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final User user;

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
