import 'package:orbit/features/auth/domain/entities/session_info_entity.dart';

import 'user_model.dart';

/// Local-only snapshot built by the auth local data source; mirrors
/// [SessionInfo] with the user still as a model.
final class SessionInfoModel {
  const SessionInfoModel({required this.isAuthenticated, this.user});

  final bool isAuthenticated;
  final UserModel? user;

  SessionInfo toEntity() =>
      SessionInfo(isAuthenticated: isAuthenticated, user: user?.toEntity());
}
