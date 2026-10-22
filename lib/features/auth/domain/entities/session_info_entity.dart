import 'package:equatable/equatable.dart';

import 'user_entity.dart';

/// Local-only session snapshot for routing decisions (go_router redirects):
/// whether a saved access token exists, plus the cached profile (may be
/// absent while still authenticated — corrupted cache data is treated as
/// absent, never as a failure to block startup).
final class SessionInfo extends Equatable {
  const SessionInfo({required this.isAuthenticated, this.user});

  final bool isAuthenticated;
  final User? user;

  @override
  List<Object?> get props => [isAuthenticated, user];
}
