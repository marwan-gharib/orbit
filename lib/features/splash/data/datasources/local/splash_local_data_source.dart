import 'package:orbit/core/errors/error_mapper.dart';
import 'package:orbit/core/local/cache/cache_service.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
import 'package:orbit/core/utils/api_result.dart';

import '../../../../../core/constants/app_consts.dart';
import '../../models/startup_status_model.dart';

/// Local data source for splash startup checks.
/// Combines secure storage (auth token) and cache (onboarding flag).
class SplashLocalDataSource {
  SplashLocalDataSource({required this._cache, required this._secureStorage});

  final CacheService _cache;
  final SecureStorageClient _secureStorage;

  /// Reads both auth token and onboarding flag.
  Future<ApiResult<StartupStatusModel>> getStartupStatus() async {
    try {
      // Read both in parallel
      final results = await Future.wait([
        _secureStorage.read(AppConsts.accessTokenKey),
        _cache.readBool(AppConsts.onboardingSeenKey),
      ]);

      final authToken = results[0] as String?;
      final onboardingSeen = results[1] as bool? ?? false;

      return Success(
        StartupStatusModel(
          hasAuthToken: authToken != null && authToken.isNotEmpty,
          onboardingSeen: onboardingSeen,
        ),
      );
    } on Exception catch (e) {
      return ResultFailure(ErrorMapper.toFailure(e));
    }
  }
}
