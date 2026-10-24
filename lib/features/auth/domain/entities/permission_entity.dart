import 'package:equatable/equatable.dart';

/// A backend-driven permission pair. Plain Strings on purpose: modules and
/// permissions are dynamic, so they must never become closed enums.
final class Permission extends Equatable {
  const Permission({required this.module, required this.permission});

  final String module;
  final String permission;

  @override
  List<Object?> get props => [module, permission];
}
