import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/auth/data/models/user_model.dart';
import 'package:orbit/features/auth/domain/entities/user_entity.dart';
import 'package:orbit/features/auth/domain/enums/user_role.dart';

Map<String, dynamic> tUserJson({
  Object? role = 1,
  Object? roleName = 'Admin',
  bool withPermissions = true,
}) {
  final json = <String, dynamic>{
    ApiKeys.firstNameKey: 'Adam',
    ApiKeys.lastNameKey: 'Orbit',
    ApiKeys.codeKey: 'EMP-2026-9582',
    ApiKeys.emailKey: 'adam@orbit.app',
    ApiKeys.roleKey: role,
    ApiKeys.roleNameKey: roleName,
  };
  if (withPermissions) {
    json[ApiKeys.permissionsKey] = [
      <String, dynamic>{
        ApiKeys.moduleKey: 'projects',
        ApiKeys.permissionKey: 'view',
      },
    ];
  }
  return json;
}

void main() {
  group('UserModel.fromJson', () {
    test('should map every field including the typed role and permissions', () {
      final model = UserModel.fromJson(tUserJson());

      expect(model.firstName, 'Adam');
      expect(model.lastName, 'Orbit');
      expect(model.code, 'EMP-2026-9582');
      expect(model.email, 'adam@orbit.app');
      expect(model.role, UserRole.admin);
      expect(model.roleName, 'Admin');
      expect(model.permissions, hasLength(1));
    });

    test('should map every known role id to its enum value', () {
      expect(UserModel.fromJson(tUserJson(role: 2)).role, UserRole.hrManager);
      expect(UserModel.fromJson(tUserJson(role: 3)).role, UserRole.accountant);
      expect(
        UserModel.fromJson(tUserJson(role: 4)).role,
        UserRole.salesRepresentative,
      );
      expect(
        UserModel.fromJson(tUserJson(role: 5)).role,
        UserRole.regularStaff,
      );
      expect(
        UserModel.fromJson(tUserJson(role: 6)).role,
        UserRole.projectManager,
      );
      expect(
        UserModel.fromJson(tUserJson(role: 7)).role,
        UserRole.inventorySpecialist,
      );
    });

    test('should fall back to unknown for an unrecognized role id', () {
      expect(UserModel.fromJson(tUserJson(role: 99)).role, UserRole.unknown);
      expect(UserModel.fromJson(tUserJson(role: -5)).role, UserRole.unknown);
    });

    test('should fall back to unknown for a non-int role (B9)', () {
      expect(UserModel.fromJson(tUserJson(role: '1')).role, UserRole.unknown);
      expect(UserModel.fromJson(tUserJson(role: null)).role, UserRole.unknown);
    });

    test('should tolerate a missing roleName and permissions list', () {
      final model = UserModel.fromJson(
        tUserJson(roleName: null, withPermissions: false),
      );

      expect(model.roleName, '');
      expect(model.permissions, isEmpty);
    });
  });

  group('UserModel.toJson (cache write)', () {
    test('should round-trip through the same wire keys (no token fields)', () {
      final model = UserModel.fromJson(tUserJson());
      final json = model.toJson();

      expect(UserModel.fromJson(json), model);
      expect(json.containsKey(ApiKeys.accessTokenKey), isFalse);
      expect(json.containsKey(ApiKeys.refreshTokenKey), isFalse);
    });
  });

  group('UserModel.toEntity', () {
    test('should map field by field including the permission list', () {
      final entity = UserModel.fromJson(tUserJson()).toEntity();

      expect(entity, isA<User>());
      expect(entity.firstName, 'Adam');
      expect(entity.lastName, 'Orbit');
      expect(entity.code, 'EMP-2026-9582');
      expect(entity.email, 'adam@orbit.app');
      expect(entity.role, UserRole.admin);
      expect(entity.roleName, 'Admin');
      expect(entity.permissions.first.module, 'projects');
      expect(entity.permissions.first.permission, 'view');
    });
  });
}
