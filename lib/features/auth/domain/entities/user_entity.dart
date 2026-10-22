import 'package:equatable/equatable.dart';

import 'permission_entity.dart';
import '../enums/user_role.dart';

/// The signed-in employee profile. [role] is the typed enum (the data layer
/// maps raw values); [roleName] is the backend's raw string kept for display.
final class User extends Equatable {
  const User({
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

  /// Employee-code string, e.g. `EMP-2026-9582`.
  final String code;
  final String email;
  final UserRole role;
  final String roleName;
  final List<Permission> permissions;

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
