import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/splash/domain/entities/splash_state_entity.dart';
import 'package:orbit/features/splash/presentation/mappers/splash_mapper.dart';
import 'package:orbit/features/splash/presentation/view_models/splash_view_model.dart';
import 'package:orbit/core/router/route_names.dart';

void main() {
  group('SplashMapper', () {
    test('toViewModel returns correct view model', () {
      const entity = SplashStateEntity(
        hasAuthToken: true,
        onboardingSeen: false,
        hasPendingSignup: false,
      );

      final viewModel = entity.toViewModel();

      expect(viewModel, isA<SplashViewModel>());
      expect(viewModel.hasAuthToken, true);
      expect(viewModel.onboardingSeen, false);
      expect(viewModel.hasPendingSignup, false);
      expect(viewModel.nextRoute, RouteNames.onboarding);
    });

    test(
      'nextRoute returns onboarding when no auth and onboarding not seen',
      () {
        const entity = SplashStateEntity(
          hasAuthToken: false,
          onboardingSeen: false,
          hasPendingSignup: false,
        );

        expect(entity.nextRoute, RouteNames.onboarding);
      },
    );

    test('nextRoute returns login when no auth and onboarding seen', () {
      const entity = SplashStateEntity(
        hasAuthToken: false,
        onboardingSeen: true,
        hasPendingSignup: false,
      );

      expect(entity.nextRoute, RouteNames.login);
    });

    test('nextRoute returns onboarding when auth and onboarding not seen', () {
      const entity = SplashStateEntity(
        hasAuthToken: true,
        onboardingSeen: false,
        hasPendingSignup: false,
      );

      expect(entity.nextRoute, RouteNames.onboarding);
    });

    test('nextRoute returns home when auth and onboarding seen', () {
      const entity = SplashStateEntity(
        hasAuthToken: true,
        onboardingSeen: true,
        hasPendingSignup: false,
      );

      expect(entity.nextRoute, RouteNames.home);
    });

    test('nextRoute returns pending when no auth and a signup is pending', () {
      const entity = SplashStateEntity(
        hasAuthToken: false,
        onboardingSeen: true,
        hasPendingSignup: true,
      );

      expect(entity.nextRoute, RouteNames.pending);
    });

    test('nextRoute prefers a real session over a pending signup', () {
      const entity = SplashStateEntity(
        hasAuthToken: true,
        onboardingSeen: true,
        hasPendingSignup: true,
      );

      expect(entity.nextRoute, RouteNames.home);
    });
  });
}
