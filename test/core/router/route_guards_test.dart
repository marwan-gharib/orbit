import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/router/route_guards.dart';
import 'package:orbit/core/router/route_paths.dart';

void main() {
  group('RouteGuards.authRedirect', () {
    test('should send login and signup back to pending while pending', () {
      expect(
        RouteGuards.authRedirect(
          location: RoutePaths.login,
          isPendingSignup: true,
        ),
        RoutePaths.pending,
      );
      expect(
        RouteGuards.authRedirect(
          location: RoutePaths.signup,
          isPendingSignup: true,
        ),
        RoutePaths.pending,
      );
    });

    test('should leave pending and unrelated routes alone while pending', () {
      expect(
        RouteGuards.authRedirect(
          location: RoutePaths.pending,
          isPendingSignup: true,
        ),
        isNull,
      );
      expect(
        RouteGuards.authRedirect(
          location: RoutePaths.home,
          isPendingSignup: true,
        ),
        isNull,
      );
    });

    test('should fall back to login when pending opens without a session', () {
      expect(
        RouteGuards.authRedirect(
          location: RoutePaths.pending,
          isPendingSignup: false,
        ),
        RoutePaths.login,
      );
    });

    test('should leave auth and unrelated routes alone without pending', () {
      expect(
        RouteGuards.authRedirect(
          location: RoutePaths.login,
          isPendingSignup: false,
        ),
        isNull,
      );
      expect(
        RouteGuards.authRedirect(
          location: RoutePaths.signup,
          isPendingSignup: false,
        ),
        isNull,
      );
      expect(
        RouteGuards.authRedirect(
          location: RoutePaths.onboarding,
          isPendingSignup: false,
        ),
        isNull,
      );
    });
  });
}
