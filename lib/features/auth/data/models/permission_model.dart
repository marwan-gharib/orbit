import 'package:equatable/equatable.dart';

import 'package:orbit/core/constants/api_keys.dart';

import 'package:orbit/features/auth/domain/entities/permission_entity.dart';

/// A backend-driven permission pair, mirrored one-to-one from the wire.
final class PermissionModel extends Equatable {
  const PermissionModel({required this.module, required this.permission});

  final String module;
  final String permission;

  factory PermissionModel.fromJson(Map<String, dynamic> json) =>
      PermissionModel(
        module: json[ApiKeys.moduleKey] as String,
        permission: json[ApiKeys.permissionKey] as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    ApiKeys.moduleKey: module,
    ApiKeys.permissionKey: permission,
  };

  Permission toEntity() => Permission(module: module, permission: permission);

  @override
  List<Object?> get props => [module, permission];
}
