import 'package:orbit/core/router/route_names.dart';

import '../../domain/entities/splash_state_entity.dart';
import '../view_models/splash_view_model.dart';

/// Maps domain entity to presentation view model.
extension SplashMapper on SplashStateEntity {
  SplashViewModel toViewModel() => SplashViewModel(
    nextRoute: nextRoute,
    hasAuthToken: hasAuthToken,
    onboardingSeen: onboardingSeen,
    hasPendingSignup: hasPendingSignup,
  );

  /// Computes the next route name. A real session wins over everything, then
  /// an unapproved account, then first-run onboarding, then login.
  String get nextRoute {
    if (hasAuthToken) {
      return onboardingSeen ? RouteNames.home : RouteNames.onboarding;
    }
    if (hasPendingSignup) return RouteNames.pending;
    return onboardingSeen ? RouteNames.login : RouteNames.onboarding;
  }
}
