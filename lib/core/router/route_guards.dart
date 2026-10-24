import 'package:orbit/core/router/route_paths.dart';

/// Holds reusable navigation guards (auth, redirects, feature flags).
abstract final class RouteGuards {
  /// Keeps the auth flow on a single path (NAV-1, NAV-3):
  ///
  /// - an expired session redirects to `/login` from any protected screen;
  /// - an auth-safe screen (login, signup, pending, splash) is preserved;
  /// - a pending signup may not return to login or signup;
  /// - `/pending` without a pending signup falls back to login, so a stale
  ///   link or deep link never shows an empty approval screen.
  static String? authRedirect({
    required String location,
    required bool isPendingSignup,
    required bool isSessionExpired,
  }) {
    if (isSessionExpired) {
      const safeLocations = {
        RoutePaths.login,
        RoutePaths.signup,
        RoutePaths.pending,
        RoutePaths.splash,
      };

      if (!safeLocations.contains(location)) {
        return RoutePaths.login;
      }
      return null;
    }

    if (isPendingSignup) {
      return switch (location) {
        RoutePaths.login || RoutePaths.signup => RoutePaths.pending,
        _ => null,
      };
    }
    return location == RoutePaths.pending ? RoutePaths.login : null;
  }
}
