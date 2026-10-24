import 'package:dio/dio.dart';
import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
import 'package:orbit/core/network/refresh/token_refresh_service.dart';
import 'package:orbit/core/network/session/session_cleaner.dart';
import 'package:orbit/core/network/session/session_expired_notifier.dart';

/// Intercepts HTTP 401 errors on authenticated requests, initiates a
/// single-flight token refresh, retries the failed request with the new token,
/// and terminates the local session if the refresh token is rejected.
final class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor({
    required this._dio,
    required this._secureStorage,
    required this._refreshService,
    required this._sessionCleaner,
    required this._sessionExpiredNotifier,
  });

  final Dio _dio;
  final SecureStorageClient _secureStorage;
  final TokenRefreshService _refreshService;
  final SessionCleaner _sessionCleaner;
  final SessionExpiredNotifier _sessionExpiredNotifier;

  /// In-memory single-flight lock ensuring concurrent 401s share a single refresh call.
  Future<String>? _pendingRefresh;

  static const Set<String> _noRefreshPaths = {
    Endpoints.authLogin,
    Endpoints.authSignup,
    Endpoints.authLogout,
    Endpoints.authRefresh,
    Endpoints.authEmployeeStatus,
    Endpoints.authSsoMobile,
  };

  bool _isExcluded(RequestOptions options) {
    if (_noRefreshPaths.contains(options.path)) return true;
    if (options.extra[ApiKeys.requiresAuthExtraKey] == false) return true;
    return false;
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only intercept HTTP 401 Unauthorized errors
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final options = err.requestOptions;

    // Public and authentication endpoints never refresh
    if (_isExcluded(options)) {
      handler.next(err);
      return;
    }

    // Requests lacking Authorization header were not authenticated
    final authHeader = options.headers[ApiKeys.authorizationHeaderKey];
    if (authHeader is! String || authHeader.trim().isEmpty) {
      handler.next(err);
      return;
    }

    // Prevent cascading retry loops: each request may only be retried once
    if (options.extra[AppConsts.retryAttemptedExtraKey] == true) {
      handler.next(err);
      return;
    }

    // Token already changed optimization: if storage already has a newer token
    // than what this request used, retry immediately without another refresh call.
    final requestToken = authHeader
        .replaceFirst(RegExp(r'^Bearer\s+', caseSensitive: false), '')
        .trim();
    final storedToken = await _secureStorage.read(AppConsts.accessTokenKey);
    if (storedToken != null &&
        storedToken.isNotEmpty &&
        storedToken != requestToken) {
      try {
        final response = await _retryRequest(options, storedToken);
        handler.resolve(response);
        return;
      } on DioException catch (retryErr) {
        handler.next(retryErr);
        return;
      }
    }

    final generationSnapshot = _sessionExpiredNotifier.currentGeneration;

    try {
      // Assignment is inside the try so that a synchronous throw from
      // refresh() (e.g. a mocktail thenThrow, or a missing refresh token
      // detected before any I/O) is caught by the handlers below.
      _pendingRefresh ??= _refreshService.refresh(
        capturedGeneration: generationSnapshot,
      );
      final newToken = await _pendingRefresh!;
      final response = await _retryRequest(options, newToken);
      handler.resolve(response);
    } on SessionExpiredException catch (expiredErr) {
      await _sessionCleaner.clearSession();
      _sessionExpiredNotifier.signalExpired();
      handler.reject(err.copyWith(error: expiredErr));
    } on StaleSessionException catch (staleErr) {
      // Session changed while in-flight (logout/account switch); fail neutrally.
      handler.reject(err.copyWith(error: staleErr));
    } catch (_) {
      // Network error or 5xx during refresh: preserve session and let error pass through
      handler.next(err);
    } finally {
      _pendingRefresh = null;
    }
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions options,
    String newToken,
  ) {
    final retryExtra = Map<String, dynamic>.from(options.extra);
    retryExtra[AppConsts.retryAttemptedExtraKey] = true;

    final retryHeaders = Map<String, dynamic>.from(options.headers);
    retryHeaders[ApiKeys.authorizationHeaderKey] = 'Bearer $newToken';

    final retryOptions = options.copyWith(
      headers: retryHeaders,
      extra: retryExtra,
    );

    return _dio.fetch<dynamic>(retryOptions);
  }
}
