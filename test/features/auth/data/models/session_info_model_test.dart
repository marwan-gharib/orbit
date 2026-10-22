import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/auth/data/models/session_info_model.dart';
import 'package:orbit/features/auth/data/models/user_model.dart';
import 'package:orbit/features/auth/domain/entities/session_info_entity.dart';

Map<String, dynamic> tUserJson() => <String, dynamic>{
  ApiKeys.firstNameKey: 'Adam',
  ApiKeys.lastNameKey: 'Orbit',
  ApiKeys.codeKey: 'EMP-2026-9582',
  ApiKeys.emailKey: 'adam@orbit.app',
  ApiKeys.roleKey: 1,
  ApiKeys.roleNameKey: 'Admin',
  ApiKeys.permissionsKey: <Object?>[],
};

void main() {
  group('SessionInfoModel.toEntity', () {
    test('should map authentication and the user field by field', () {
      final model = SessionInfoModel(
        isAuthenticated: true,
        user: UserModel.fromJson(tUserJson()),
      );

      final entity = model.toEntity();

      expect(entity, isA<SessionInfo>());
      expect(entity.isAuthenticated, isTrue);
      expect(entity.user?.email, 'adam@orbit.app');
      expect(entity.user?.role.id, 1);
    });

    test('should keep user null when no profile was cached', () {
      final entity = const SessionInfoModel(isAuthenticated: true).toEntity();

      expect(entity.isAuthenticated, isTrue);
      expect(entity.user, isNull);
    });

    test('should map the signed-out snapshot', () {
      final entity = const SessionInfoModel(isAuthenticated: false).toEntity();

      expect(entity.isAuthenticated, isFalse);
      expect(entity.user, isNull);
    });
  });
}
