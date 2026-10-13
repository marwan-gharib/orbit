import 'package:dio/dio.dart';
import 'package:orbit/core/errors/dio_error_handler.dart';

/// Replaces every [DioException.error] with a classified [AppException] so
/// downstream code sees a stable domain error; the DioException itself is
/// preserved as the carrier.
final class ErrorInterceptor extends Interceptor {
  const ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(err.copyWith(error: DioErrorHandler.handle(err)));
  }
}
