import 'package:dio/dio.dart';
import 'package:orbit/core/constants/api_keys.dart';

/// Factory creating a dedicated, isolated [Dio] client for token refresh.
///
/// Has ZERO interceptors attached (no auth header injection, no error
/// rewriting, no token refresh loop, no network logging).
abstract final class RefreshDioClient {
  static Dio create({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Duration sendTimeout = const Duration(seconds: 30),
  }) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        responseType: ResponseType.json,
        contentType: 'application/json; charset=utf-8',
        headers: <String, dynamic>{
          Headers.acceptHeader: 'application/json',
          ApiKeys.clientTypeHeaderKey: ApiKeys.clientTypeHeaderValue,
        },
        // Permits 400 and 401 so TokenRefreshService receives the response directly
        // and handles terminal rejection deterministically without intermediate DioException:
        validateStatus: (status) =>
            status != null &&
            ((status >= 200 && status < 300) ||
                status == 400 ||
                status == 401),
      ),
    );
  }
}
