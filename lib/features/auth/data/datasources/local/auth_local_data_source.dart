import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/constants/log_tags.dart';
import 'package:orbit/core/errors/error_mapper.dart';
import 'package:orbit/core/local/cache/cache_service.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/core/utils/logger.dart';

import '../../models/login_response_model.dart';
import '../../models/session_info_model.dart';
import '../../models/user_model.dart';

/// Token and session persistence for auth (A2):
/// - Access AND refresh tokens live ONLY in secure storage — never in the
///   cache, never in logs, never inside the cached user JSON.
/// - The cached user profile is non-token display data, kept in `CacheService`
///   where the cheap key/value store is appropriate.
///
/// Catches everything (Exception and Error): a storage failure must become a
/// `Failure`, and a malformed cached payload must degrade, never crash.
class AuthLocalDataSource {
  AuthLocalDataSource({required this._cache, required this._secureStorage});

  final CacheService _cache;
  final SecureStorageClient _secureStorage;

  /// Persists the session; on ANY write failure, best-effort deletes what may
  /// have been written (B6), so the session is never half-saved.
  Future<ApiResult<void>> saveSession(LoginResponseModel session) async {
    try {
      await _secureStorage.write(AppConsts.accessTokenKey, session.accessToken);
      await _secureStorage.write(
        AppConsts.refreshTokenKey,
        session.refreshToken,
      );
      await _cache.writeJsonMap(
        AppConsts.authUserCacheKey,
        session.user.toJson(),
      );
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      await _rollback();
      return ResultFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }

  /// Deletes both tokens and the cached user; missing keys are not errors.
  Future<ApiResult<void>> clearSession() async {
    try {
      await _secureStorage.delete(AppConsts.accessTokenKey);
      await _secureStorage.delete(AppConsts.refreshTokenKey);
      await _cache.delete(AppConsts.authUserCacheKey);
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }

  /// The refresh token, or `null` when none was ever saved ("nothing to
  /// revoke" is not an error).
  Future<ApiResult<String?>> readRefreshToken() async {
    try {
      return Success(await _secureStorage.read(AppConsts.refreshTokenKey));
    } on Object catch (error, stackTrace) {
      return ResultFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }

  /// Snapshot for routing: authentication is decided by the access token's
  /// presence (B5); the cached user is best-effort display data.
  Future<ApiResult<SessionInfoModel>> readSessionInfo() async {
    try {
      final token = await _secureStorage.read(AppConsts.accessTokenKey);
      final isAuthenticated = token != null && token.isNotEmpty;
      return Success(
        SessionInfoModel(
          isAuthenticated: isAuthenticated,
          user: await _cachedUser(),
        ),
      );
    } on Object catch (error, stackTrace) {
      return ResultFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }

  /// A cached profile that fails to read or parse (corrupt JSON, shape
  /// change, IO error) is treated as absent and logged (B5) — the token read
  /// above already decided authentication, so a broken profile must never
  /// block startup.
  Future<UserModel?> _cachedUser() async {
    try {
      final json = await _cache.readJsonMap(AppConsts.authUserCacheKey);
      if (json == null) return null;
      return UserModel.fromJson(json);
    } on Object catch (error) {
      AppLogger.warning(
        'Cached user profile unusable: $error',
        tag: LogTags.auth,
      );
      return null;
    }
  }

  /// Partial-write cleanup (B6): delete errors are swallowed on purpose —
  /// the original save failure is the one that matters.
  Future<void> _rollback() async {
    try {
      await _secureStorage.delete(AppConsts.accessTokenKey);
      await _secureStorage.delete(AppConsts.refreshTokenKey);
      await _cache.delete(AppConsts.authUserCacheKey);
    } on Object catch (error) {
      AppLogger.warning(
        'Session rollback incomplete: $error',
        tag: LogTags.auth,
      );
    }
  }
}
