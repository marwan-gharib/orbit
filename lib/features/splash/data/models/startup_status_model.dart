import '../../domain/entities/splash_state_entity.dart';

/// Data model for startup status — maps to/from storage.
class StartupStatusModel {
  const StartupStatusModel({
    required this.hasAuthToken,
    required this.onboardingSeen,
  });

  final bool hasAuthToken;
  final bool onboardingSeen;

  /// Creates an entity from this model.
  SplashStateEntity toEntity() => SplashStateEntity(
    hasAuthToken: hasAuthToken,
    onboardingSeen: onboardingSeen,
  );
}
