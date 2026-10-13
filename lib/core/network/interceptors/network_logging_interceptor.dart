import 'package:dio/dio.dart';
import 'package:orbit/core/utils/logger.dart';

/// Debug-only request/response/error logging via [AppLogger].
final class NetworkLoggingInterceptor extends Interceptor {
  const NetworkLoggingInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.logNetworkRequest(
      method: options.method,
      uri: options.uri.toString(),
      headers: options.headers,
      data: options.data,
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
      data: response.data,
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
}
