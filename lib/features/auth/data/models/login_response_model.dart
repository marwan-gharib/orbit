import 'package:orbit/core/constants/api_keys.dart';

import 'package:orbit/features/auth/domain/entities/auth_session_entity.dart';

import 'user_model.dart';

/// The login response body: tokens plus the signed-in user.
final class LoginResponseModel {
  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserModel user;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final user = json[ApiKeys.userKey];
    if (user is! Map) {
      throw const FormatException('Login response is missing the user object.');
    }
    return LoginResponseModel(
      accessToken: json[ApiKeys.accessTokenKey] as String,
      refreshToken: json[ApiKeys.refreshTokenKey] as String,
      user: UserModel.fromJson(Map<String, dynamic>.from(user)),
    );
  }

  AuthSession toEntity() => AuthSession(
    accessToken: accessToken,
    refreshToken: refreshToken,
    user: user.toEntity(),
  );
}
