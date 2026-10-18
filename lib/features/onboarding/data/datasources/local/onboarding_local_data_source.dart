import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/local/cache/cache_service.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/core/errors/failures.dart';

/// Local data source for onboarding persistence.
/// Uses [CacheService] (SharedPreferences) to store the completion flag.
class OnboardingLocalDataSource {
  OnboardingLocalDataSource(this._cache);

  final CacheService _cache;

  /// Writes the onboarding completion flag.
  Future<ApiResult<void>> setOnboardingSeen() async {
    try {
      await _cache.writeBool(AppConsts.onboardingSeenKey, true);
      return const Success(null);
    } on Exception catch (e) {
      return ResultFailure(
        CacheFailure(message: 'Failed to save onboarding status: $e'),
      );
    }
  }

  /// Reads the onboarding completion flag (used by splash, not by onboarding itself).
  Future<ApiResult<bool>> getOnboardingSeen() async {
    try {
      final seen = await _cache.readBool(AppConsts.onboardingSeenKey) ?? false;
      return Success(seen);
    } on Exception catch (e) {
      return ResultFailure(
        CacheFailure(message: 'Failed to read onboarding status: $e'),
      );
    }
  }
}
