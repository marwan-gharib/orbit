/// Pure data representing the result of startup checks.
/// No Flutter dependencies — domain layer only.
library;

import 'package:equatable/equatable.dart';

class SplashStateEntity extends Equatable {
  const SplashStateEntity({
    required this.hasAuthToken,
    required this.onboardingSeen,
  });

  /// Whether a valid auth token exists in secure storage.
  final bool hasAuthToken;

  /// Whether the user has completed onboarding (cached flag).
  final bool onboardingSeen;

  @override
  List<Object?> get props => [hasAuthToken, onboardingSeen];
}
