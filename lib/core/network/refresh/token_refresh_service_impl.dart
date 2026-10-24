import 'package:dio/dio.dart';
import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/core/errors/dio_error_handler.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
import 'package:orbit/core/network/session/session_expired_notifier.dart';
import 'package:orbit/core/utils/logger.dart';

import 'token_refresh_service.dart';

/// Concrete implementation of [TokenRefreshService] executing the refresh
/// endpoint call, handling rotation, and atomically updating secure storage.
final class TokenRefreshServiceImpl implements TokenRefreshService {
  TokenRefreshServiceImpl({
    required this._refreshDio,
    required this._secureStorage,
    required this._sessionNotifier,
  });

  final Dio _refreshDio;
  final SecureStorageClient _secureStorage;
  final SessionExpiredNotifier _sessionNotifier;

  @override
  Future<String> refresh({required int capturedGeneration}) async {
    final refreshToken = await _secureStorage.read(AppConsts.refreshTokenKey);
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      throw const SessionExpiredException(
        message: 'No refresh token available in secure storage.',
      );
    }

    try {
      final response = await _refreshDio.post<dynamic>(
        Endpoints.authRefresh,
        data: <String, Object>{
          ApiKeys.refreshKey: refreshToken,
        },
      );

      final statusCode = response.statusCode;
      if (statusCode == 400 || statusCode == 401) {
        throw SessionExpiredException(
          message: 'Backend rejected the refresh token ($statusCode).',
          statusCode: statusCode,
        );
      }

      if (statusCode != null && (statusCode < 200 || statusCode >= 300)) {
        throw ServerErrorException(
          message: 'Refresh failed with unexpected status: $statusCode.',
          statusCode: statusCode,
        );
      }

      final data = response.data;
      if (data is! Map || !data.containsKey(ApiKeys.refreshAccessKey)) {
        throw const ServerErrorException(
          message: 'Refresh response was malformed: missing "access" token.',
        );
      }

      final newAccessToken = data[ApiKeys.refreshAccessKey] as String?;
      if (newAccessToken == null || newAccessToken.trim().isEmpty) {
        throw const ServerErrorException(
          message: 'Empty access token received in refresh response.',
        );
      }

      // Guard against logout or account-switch while this request was in flight.
      if (_sessionNotifier.currentGeneration != capturedGeneration) {
        AppLogger.warning(
          'Token refresh completed after session was invalidated. Discarding token.',
          tag: 'REFRESH',
        );
        throw const StaleSessionException();
      }

      // Atomically persist the new access token.
      await _secureStorage.write(AppConsts.accessTokenKey, newAccessToken);

      // Handle optional refresh token rotation if present.
      final rotatedRefreshToken = data[ApiKeys.refreshKey] as String?;
      if (rotatedRefreshToken != null && rotatedRefreshToken.isNotEmpty) {
        await _secureStorage.write(
          AppConsts.refreshTokenKey,
          rotatedRefreshToken,
        );
      }

      return newAccessToken;
    } on AppException {
      rethrow;
    } on DioException catch (e, st) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 400 || statusCode == 401) {
        throw SessionExpiredException(
          message: 'Backend rejected the refresh token ($statusCode).',
          statusCode: statusCode,
          cause: e,
          stackTrace: st,
        );
      }
      throw DioErrorHandler.handle(e, st);
    } on Object catch (e, st) {
      throw DioErrorHandler.handle(e, st);
    }
  }
}
