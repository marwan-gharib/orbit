import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/auth/data/models/login_response_model.dart';
import 'package:orbit/features/auth/domain/entities/auth_session_entity.dart';
import 'package:orbit/features/auth/domain/enums/user_role.dart';

Map<String, dynamic> tLoginJson() => <String, dynamic>{
  ApiKeys.accessTokenKey: 'access-1',
  ApiKeys.refreshTokenKey: 'refresh-1',
  ApiKeys.userKey: <String, dynamic>{
    ApiKeys.firstNameKey: 'Adam',
    ApiKeys.lastNameKey: 'Orbit',
    ApiKeys.codeKey: 'EMP-2026-9582',
    ApiKeys.emailKey: 'adam@orbit.app',
    ApiKeys.roleKey: 6,
    ApiKeys.roleNameKey: 'PM',
    ApiKeys.permissionsKey: <Object?>[],
  },
};

void main() {
  group('LoginResponseModel.fromJson', () {
    test('should map both tokens and the nested user', () {
      final model = LoginResponseModel.fromJson(tLoginJson());

      expect(model.accessToken, 'access-1');
      expect(model.refreshToken, 'refresh-1');
      expect(model.user.role, UserRole.projectManager);
    });

    test('should throw when the user object is missing', () {
      final json = tLoginJson()..remove(ApiKeys.userKey);

      expect(() => LoginResponseModel.fromJson(json), throwsFormatException);
    });

    test('should throw when a token key is missing', () {
      final json = tLoginJson()..remove(ApiKeys.refreshTokenKey);

      expect(
        () => LoginResponseModel.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('LoginResponseModel.toEntity', () {
    test('should map tokens and the user entity field by field', () {
      final entity = LoginResponseModel.fromJson(tLoginJson()).toEntity();

      expect(entity, isA<AuthSession>());
      expect(entity.accessToken, 'access-1');
      expect(entity.refreshToken, 'refresh-1');
      expect(entity.user.role, UserRole.projectManager);
      expect(entity.user.email, 'adam@orbit.app');
    });
  });
}
