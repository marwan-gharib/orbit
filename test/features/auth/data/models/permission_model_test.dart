import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/auth/data/models/permission_model.dart';
import 'package:orbit/features/auth/domain/entities/permission_entity.dart';

void main() {
  const tPermission = PermissionModel(module: 'projects', permission: 'view');

  group('PermissionModel.fromJson', () {
    test('should map module and permission from the wire keys', () {
      final model = PermissionModel.fromJson(const {
        ApiKeys.moduleKey: 'projects',
        ApiKeys.permissionKey: 'view',
      });

      expect(model.module, 'projects');
      expect(model.permission, 'view');
    });

    test('should throw when a required key is missing', () {
      expect(
        () => PermissionModel.fromJson(const {ApiKeys.moduleKey: 'projects'}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('PermissionModel.toJson', () {
    test('should round-trip through its own wire keys', () {
      final json = tPermission.toJson();

      expect(PermissionModel.fromJson(json), tPermission);
      expect(json[ApiKeys.moduleKey], 'projects');
      expect(json[ApiKeys.permissionKey], 'view');
    });
  });

  group('PermissionModel.toEntity', () {
    test('should map field by field', () {
      final entity = tPermission.toEntity();

      expect(entity, isA<Permission>());
      expect(entity.module, 'projects');
      expect(entity.permission, 'view');
    });
  });
}
