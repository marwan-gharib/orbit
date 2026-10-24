import 'package:dio/dio.dart';
import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';

/// Attaches the stored access token as a Bearer header. Requests can opt out
/// with `extra: {ApiKeys.requiresAuthExtraKey: false}` — used by
/// login/refresh/public endpoints that must not carry credentials.
final class AuthInterceptor extends Interceptor {
  const AuthInterceptor(this._secureStorage);

  final SecureStorageClient _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[ApiKeys.requiresAuthExtraKey] == false) {
      handler.next(options);
      return;
    }
    try {
      final token = await _secureStorage.read(AppConsts.accessTokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers[ApiKeys.authorizationHeaderKey] = 'Bearer $token';
      }
    } catch (_) {
      // A storage hiccup must not abort the request; a 401 can take over.
    }
    handler.next(options);
  }
}
