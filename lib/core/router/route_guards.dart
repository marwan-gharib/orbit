import 'package:orbit/core/router/route_paths.dart';

/// Holds reusable navigation guards (auth, redirects, feature flags).
abstract final class RouteGuards {
  /// Keeps the auth flow on a single path (NAV-1, NAV-3):
  ///
  /// - a pending signup may not return to login or signup;
  /// - `/pending` without a pending signup falls back to login, so a stale
  ///   link or deep link never shows an empty approval screen.
  ///
  /// Any other location is left alone. The redirect runs only when
  /// [isPendingSignup] changes, because the router listens to the session.
  static String? authRedirect({
    required String location,
    required bool isPendingSignup,
  }) {
    if (isPendingSignup) {
      return switch (location) {
        RoutePaths.login || RoutePaths.signup => RoutePaths.pending,
        _ => null,
      };
    }
    return location == RoutePaths.pending ? RoutePaths.login : null;
  }
}
