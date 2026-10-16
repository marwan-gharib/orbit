import 'package:equatable/equatable.dart';

/// View model for the splash screen — UI-ready data derived from entity.
class SplashViewModel extends Equatable {
  const SplashViewModel({
    required this.nextRoute,
    required this.hasAuthToken,
    required this.onboardingSeen,
  });

  /// The route to navigate to after splash completes.
  final String nextRoute;

  /// Whether auth token exists (for debugging/display).
  final bool hasAuthToken;

  /// Whether onboarding was completed (for debugging/display).
  final bool onboardingSeen;

  @override
  List<Object?> get props => [nextRoute, hasAuthToken, onboardingSeen];
}
