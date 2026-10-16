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
      );

      final viewModel = entity.toViewModel();

      expect(viewModel, isA<SplashViewModel>());
      expect(viewModel.hasAuthToken, true);
      expect(viewModel.onboardingSeen, false);
      expect(viewModel.nextRoute, RouteNames.onboarding);
    });

    test(
      'nextRoute returns onboarding when no auth and onboarding not seen',
      () {
        const entity = SplashStateEntity(
          hasAuthToken: false,
          onboardingSeen: false,
        );

        expect(entity.nextRoute, RouteNames.onboarding);
      },
    );

    test('nextRoute returns login when no auth and onboarding seen', () {
      const entity = SplashStateEntity(
        hasAuthToken: false,
        onboardingSeen: true,
      );

      expect(entity.nextRoute, RouteNames.login);
    });

    test('nextRoute returns onboarding when auth and onboarding not seen', () {
      const entity = SplashStateEntity(
        hasAuthToken: true,
        onboardingSeen: false,
      );

      expect(entity.nextRoute, RouteNames.onboarding);
    });

    test('nextRoute returns home when auth and onboarding seen', () {
      const entity = SplashStateEntity(
        hasAuthToken: true,
        onboardingSeen: true,
      );

      expect(entity.nextRoute, RouteNames.home);
    });
  });
}
