import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/auth/data/models/google_sso_response_model.dart';
import 'package:orbit/features/auth/domain/entities/google_sign_in_result.dart';

void main() {
  group('GoogleSsoResponseModel', () {
    test('should parse login-shaped response into GoogleSsoLoginModel', () {
      final json = {
        ApiKeys.accessTokenKey: 'access_123',
        ApiKeys.refreshTokenKey: 'refresh_123',
        ApiKeys.userKey: {
          ApiKeys.firstNameKey: 'Marwan',
          ApiKeys.lastNameKey: 'Gharib',
          ApiKeys.codeKey: 'EMP001',
          ApiKeys.emailKey: 'marwan@orbit.app',
          ApiKeys.roleKey: {
            ApiKeys.roleNameKey: 'Admin',
            ApiKeys.permissionsKey: <Map<String, dynamic>>[],
          },
        },
      };

      final model = GoogleSsoResponseModel.fromJson(json);

      expect(model, isA<GoogleSsoLoginModel>());
      final entity = model.toEntity();
      expect(entity, isA<GoogleLoggedIn>());
      final session = (entity as GoogleLoggedIn).session;
      expect(session.accessToken, 'access_123');
      expect(session.user.firstName, 'Marwan');
    });

    test('should parse signup-shaped response into GoogleSsoSignupModel', () {
      final json = {
        ApiKeys.firstNameKey: 'Marwan',
        ApiKeys.lastNameKey: 'Gharib',
        ApiKeys.emailKey: 'marwan@orbit.app',
      };

      final model = GoogleSsoResponseModel.fromJson(json);

      expect(model, isA<GoogleSsoSignupModel>());
      final entity = model.toEntity();
      expect(entity, isA<GoogleRegistered>());
      final signup = (entity as GoogleRegistered).signupResult;
      expect(signup.firstName, 'Marwan');
      expect(signup.email, 'marwan@orbit.app');
    });

    test('should prioritize login model if both access_token and signup keys are present', () {
      final json = {
        ApiKeys.accessTokenKey: 'access_123',
        ApiKeys.refreshTokenKey: 'refresh_123',
        ApiKeys.firstNameKey: 'ExtraName',
        ApiKeys.emailKey: 'extra@orbit.app',
        ApiKeys.userKey: {
          ApiKeys.firstNameKey: 'Marwan',
          ApiKeys.lastNameKey: 'Gharib',
          ApiKeys.codeKey: 'EMP001',
          ApiKeys.emailKey: 'marwan@orbit.app',
          ApiKeys.roleKey: {
            ApiKeys.roleNameKey: 'Admin',
            ApiKeys.permissionsKey: <Map<String, dynamic>>[],
          },
        },
      };

      final model = GoogleSsoResponseModel.fromJson(json);

      expect(model, isA<GoogleSsoLoginModel>());
      expect(model.toEntity(), isA<GoogleLoggedIn>());
    });

    test('should throw FormatException for empty JSON or unrecognized shape', () {
      expect(
        () => GoogleSsoResponseModel.fromJson({}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => GoogleSsoResponseModel.fromJson({'random_key': 'random_value'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('should treat null access_token as signup if signup keys exist', () {
      final json = {
        ApiKeys.accessTokenKey: null,
        ApiKeys.firstNameKey: 'Marwan',
        ApiKeys.lastNameKey: 'Gharib',
        ApiKeys.emailKey: 'marwan@orbit.app',
      };

      final model = GoogleSsoResponseModel.fromJson(json);

      expect(model, isA<GoogleSsoSignupModel>());
      expect(model.toEntity(), isA<GoogleRegistered>());
    });

    test('verifies wire key constants for Google SSO', () {
      expect(ApiKeys.issKey, 'iss');
      expect(ApiKeys.subKey, 'sub');
      expect(ApiKeys.givenNameKey, 'given_name');
      expect(ApiKeys.familyNameKey, 'family_name');
      expect(ApiKeys.idTokenKey, 'id_token');
    });
  });
}
