import 'package:equatable/equatable.dart';

import 'package:orbit/core/constants/api_keys.dart';

import 'package:orbit/features/auth/domain/entities/user_entity.dart';
import 'package:orbit/features/auth/domain/enums/user_role.dart';

import 'permission_model.dart';

/// The signed-in employee profile on the wire (login response `user`
/// object, and the shape cached in `auth_cached_user`).
final class UserModel extends Equatable {
  const UserModel({
    required this.firstName,
    required this.lastName,
    required this.code,
    required this.email,
    required this.role,
    required this.roleName,
    required this.permissions,
  });

  final String firstName;
  final String lastName;
  final String code;
  final String email;
  final UserRole role;
  final String roleName;
  final List<PermissionModel> permissions;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    firstName: json[ApiKeys.firstNameKey] as String,
    lastName: json[ApiKeys.lastNameKey] as String,
    code: json[ApiKeys.codeKey] as String,
    email: json[ApiKeys.emailKey] as String,
    // B9: role is always an int on the wire; anything else (a String, a
    // double, null) parses as `unknown` — never coerced.
    role: json[ApiKeys.roleKey] is int
        ? UserRole.fromId(json[ApiKeys.roleKey] as int)
        : UserRole.unknown,
    roleName: json[ApiKeys.roleNameKey] as String? ?? '',
    permissions: _permissions(json[ApiKeys.permissionsKey]),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    ApiKeys.firstNameKey: firstName,
    ApiKeys.lastNameKey: lastName,
    ApiKeys.codeKey: code,
    ApiKeys.emailKey: email,
    ApiKeys.roleKey: role.id,
    ApiKeys.roleNameKey: roleName,
    ApiKeys.permissionsKey: [
      for (final permission in permissions) permission.toJson(),
    ],
  };

  User toEntity() => User(
    firstName: firstName,
    lastName: lastName,
    code: code,
    email: email,
    role: role,
    roleName: roleName,
    permissions: [for (final permission in permissions) permission.toEntity()],
  );

  static List<PermissionModel> _permissions(Object? raw) {
    if (raw is! List) return const <PermissionModel>[];
    return [
      for (final item in raw)
        if (item is Map)
          PermissionModel.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    code,
    email,
    role,
    roleName,
    permissions,
  ];
}
