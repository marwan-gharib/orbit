import 'package:orbit/core/utils/api_result.dart';

import '../entities/splash_state_entity.dart';

/// Contract for startup data access.
/// Implemented in data layer; used by [CheckStartupStatusUseCase].
abstract interface class SplashRepository {
  /// Checks both auth token (secure storage) and onboarding flag (cache).
  /// Returns a combined entity with both results.
  Future<ApiResult<SplashStateEntity>> checkStartupStatus();
}
