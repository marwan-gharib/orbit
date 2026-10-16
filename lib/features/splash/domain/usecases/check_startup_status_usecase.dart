import 'package:orbit/core/utils/api_result.dart';

import '../repositories/splash_repository.dart';
import '../entities/splash_state_entity.dart';

/// Checks auth token and onboarding status in parallel.
/// Returns a combined [SplashStateEntity] on success.
class CheckStartupStatusUseCase {
  CheckStartupStatusUseCase(this._repository);

  final SplashRepository _repository;

  Future<ApiResult<SplashStateEntity>> call() =>
      _repository.checkStartupStatus();
}
