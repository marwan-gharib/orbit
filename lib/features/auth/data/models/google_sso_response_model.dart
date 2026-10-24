import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/auth/data/models/login_response_model.dart';
import 'package:orbit/features/auth/data/models/signup_response_model.dart';
import 'package:orbit/features/auth/domain/entities/google_sign_in_result.dart';

/// Discriminated model representing the server's response to a Google SSO request.
///
/// If `access_token` is present, the backend treated the user as an existing user
/// and signed them in. Otherwise, if `first_name` or `email` is present, a new
/// registration was created awaiting employee approval.
sealed class GoogleSsoResponseModel {
  const GoogleSsoResponseModel();

  /// Flag controlling whether the raw `id_token` is transmitted in the SSO request.
  /// Defaults to `false` until backend verification is active.
  static const bool sendIdToken = false;

  factory GoogleSsoResponseModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey(ApiKeys.accessTokenKey) &&
        json[ApiKeys.accessTokenKey] is String) {
      return GoogleSsoLoginModel(LoginResponseModel.fromJson(json));
    } else if (json.containsKey(ApiKeys.firstNameKey) ||
        json.containsKey(ApiKeys.emailKey)) {
      return GoogleSsoSignupModel(SignupResponseModel.fromJson(json));
    }
    throw const FormatException('Unrecognized SSO 200 response body format.');
  }

  GoogleSignInResult toEntity();
}

final class GoogleSsoLoginModel extends GoogleSsoResponseModel {
  const GoogleSsoLoginModel(this.loginResponse);

  final LoginResponseModel loginResponse;

  @override
  GoogleSignInResult toEntity() => GoogleLoggedIn(loginResponse.toEntity());
}

final class GoogleSsoSignupModel extends GoogleSsoResponseModel {
  const GoogleSsoSignupModel(this.signupResponse);

  final SignupResponseModel signupResponse;

  @override
  GoogleSignInResult toEntity() => GoogleRegistered(signupResponse.toEntity());
}
