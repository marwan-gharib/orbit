import 'package:dio/dio.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';

/// Attaches the stored access token as a Bearer header. Requests can opt out
/// with `extra: {'requiresAuth': false}` — used by login/refresh/public
/// endpoints that must not carry credentials.
final class AuthInterceptor extends Interceptor {
  const AuthInterceptor(this._secureStorage);

  static const String _authorizationHeader = 'Authorization';
  static const String _accessTokenKey = 'access_token';

  /// Opt-out flag for [onRequest]: set `options.extra['requiresAuth'] = false`
  /// to skip the Authorization header entirely.
  static const String requiresAuthExtra = 'requiresAuth';

  final SecureStorageClient _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[requiresAuthExtra] == false) {
      handler.next(options);
      return;
    }
    try {
      final token = await _secureStorage.read(_accessTokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers[_authorizationHeader] = 'Bearer $token';
      }
    } catch (_) {
      // A storage hiccup must not abort the request; a 401 can take over.
    }
    handler.next(options);
  }
}
