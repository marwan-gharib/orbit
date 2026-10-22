import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/utils/logger.dart';

/// Debug-only request/response/error logging via [AppLogger]. Token values
/// are masked before anything is logged (A2: tokens are never logged).
final class NetworkLoggingInterceptor extends Interceptor {
  const NetworkLoggingInterceptor();

  static const String _maskedValue = '***';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.logNetworkRequest(
      method: options.method,
      uri: options.uri.toString(),
      headers: options.headers,
      data: redactTokens(options.data),
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    AppLogger.logNetworkResponse(
      method: response.requestOptions.method,
      uri: response.requestOptions.uri.toString(),
      statusCode: response.statusCode,
      data: redactTokens(response.data),
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.logNetworkError(
      method: err.requestOptions.method,
      uri: err.requestOptions.uri.toString(),
      error: err,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }

  /// Masks token values in a decoded body so they never reach the logs
  /// (sign-in responses carry both tokens). Exposed for tests.
  @visibleForTesting
  static Object? redactTokens(Object? body) {
    if (body is Map) {
      return body.map((key, value) {
        final masked = _isTokenKey(key) ? _maskedValue : redactTokens(value);
        return MapEntry(key, masked);
      });
    }
    if (body is List) {
      return [for (final item in body) redactTokens(item)];
    }
    return body;
  }

  static bool _isTokenKey(Object? key) =>
      key == ApiKeys.accessTokenKey || key == ApiKeys.refreshTokenKey;
}
