import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/router/route_guards.dart';
import 'package:orbit/core/router/route_paths.dart';

void main() {
  group('RouteGuards.authRedirect', () {
    group('when session is expired (isSessionExpired == true)', () {
      test('should redirect protected route (/home) to /login', () {
        expect(
          RouteGuards.authRedirect(
            location: RoutePaths.home,
            isPendingSignup: false,
            isSessionExpired: true,
          ),
          RoutePaths.login,
        );
      });

      test('should leave auth-safe routes alone', () {
        expect(
          RouteGuards.authRedirect(
            location: RoutePaths.login,
            isPendingSignup: false,
            isSessionExpired: true,
          ),
          isNull,
        );
        expect(
          RouteGuards.authRedirect(
            location: RoutePaths.signup,
            isPendingSignup: false,
            isSessionExpired: true,
          ),
          isNull,
        );
        expect(
          RouteGuards.authRedirect(
            location: RoutePaths.pending,
            isPendingSignup: false,
            isSessionExpired: true,
          ),
          isNull,
        );
        expect(
          RouteGuards.authRedirect(
            location: RoutePaths.splash,
            isPendingSignup: false,
            isSessionExpired: true,
          ),
          isNull,
        );
      });
    });

    group('when session is not expired (isSessionExpired == false)', () {
      test('should send login and signup back to pending while pending', () {
        expect(
          RouteGuards.authRedirect(
            location: RoutePaths.login,
            isPendingSignup: true,
            isSessionExpired: false,
          ),
          RoutePaths.pending,
        );
        expect(
          RouteGuards.authRedirect(
            location: RoutePaths.signup,
            isPendingSignup: true,
            isSessionExpired: false,
          ),
          RoutePaths.pending,
        );
      });

      test('should leave pending and unrelated routes alone while pending', () {
        expect(
          RouteGuards.authRedirect(
            location: RoutePaths.pending,
            isPendingSignup: true,
            isSessionExpired: false,
          ),
          isNull,
        );
        expect(
          RouteGuards.authRedirect(
            location: RoutePaths.home,
            isPendingSignup: true,
            isSessionExpired: false,
          ),
          isNull,
        );
      });

      test('should fall back to login when pending opens without a session', () {
        expect(
          RouteGuards.authRedirect(
            location: RoutePaths.pending,
            isPendingSignup: false,
            isSessionExpired: false,
          ),
          RoutePaths.login,
        );
      });

      test('should leave auth and unrelated routes alone without pending', () {
        expect(
          RouteGuards.authRedirect(
            location: RoutePaths.login,
            isPendingSignup: false,
            isSessionExpired: false,
          ),
          isNull,
        );
        expect(
          RouteGuards.authRedirect(
            location: RoutePaths.signup,
            isPendingSignup: false,
            isSessionExpired: false,
          ),
          isNull,
        );
        expect(
          RouteGuards.authRedirect(
            location: RoutePaths.onboarding,
            isPendingSignup: false,
            isSessionExpired: false,
          ),
          isNull,
        );
      });
    });
  });
}
