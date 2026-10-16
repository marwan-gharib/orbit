import 'package:orbit/core/router/route_names.dart';

import '../../domain/entities/splash_state_entity.dart';
import '../view_models/splash_view_model.dart';

/// Maps domain entity to presentation view model.
extension SplashMapper on SplashStateEntity {
  SplashViewModel toViewModel() => SplashViewModel(
    nextRoute: nextRoute,
    hasAuthToken: hasAuthToken,
    onboardingSeen: onboardingSeen,
  );

  /// Computes the next route name based on auth and onboarding status.
  String get nextRoute {
    if (!hasAuthToken) {
      return onboardingSeen ? RouteNames.login : RouteNames.onboarding;
    }
    return onboardingSeen ? RouteNames.home : RouteNames.onboarding;
  }
}
