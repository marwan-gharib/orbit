import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/errors/dio_error_handler.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/core/network/interceptors/auth_interceptor.dart';
import 'package:orbit/core/network/interceptors/error_interceptor.dart';
import 'package:orbit/core/network/interceptors/network_logging_interceptor.dart';

/// Dio-backed [BaseApiClient]: callers receive the decoded body on success
/// or an [AppException] subtype on failure — never a raw `DioException`.
final class DioApiClient implements BaseApiClient {
  /// Wraps an already-configured Dio instance (tests, custom setups); the
  /// caller owns its lifecycle.
  DioApiClient(this._dio);

  /// Builds a client with JSON defaults, non-2xx routed to the error path,
  /// and the standard interceptor chain.
  DioApiClient.configured({
    required String baseUrl,
    required SecureStorageClient secureStorage,
    required String Function() localeProvider,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Duration sendTimeout = const Duration(seconds: 30),
  }) : this(
         buildDio(
           baseUrl: baseUrl,
           secureStorage: secureStorage,
           localeProvider: localeProvider,
           connectTimeout: connectTimeout,
           receiveTimeout: receiveTimeout,
           sendTimeout: sendTimeout,
         ),
       );

  final Dio _dio;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Map<String, Object>? extra,
    Object? data,
  }) => _request(
    path,
    method: 'GET',
    queryParameters: queryParameters,
    headers: headers,
    extra: extra,
    data: data,
  );

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Map<String, Object>? extra,
  }) => _request(
    path,
    method: 'POST',
    data: data,
    queryParameters: queryParameters,
    headers: headers,
    extra: extra,
  );

  @override
  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Map<String, Object>? extra,
  }) => _request(
    path,
    method: 'PUT',
    data: data,
    queryParameters: queryParameters,
    headers: headers,
    extra: extra,
  );

  @override
  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Map<String, Object>? extra,
  }) => _request(
    path,
    method: 'PATCH',
    data: data,
    queryParameters: queryParameters,
    headers: headers,
    extra: extra,
  );

  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Map<String, Object>? extra,
  }) => _request(
    path,
    method: 'DELETE',
    data: data,
    queryParameters: queryParameters,
    headers: headers,
    extra: extra,
  );

  /// Single choke point for all verbs: runs the request and normalizes any
  /// thrown error into an [AppException].
  Future<dynamic> _request(
    String path, {
    required String method,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Map<String, Object>? extra,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method, headers: headers, extra: extra),
      );
      return response.data;
    } catch (error, stackTrace) {
      // ErrorInterceptor already classified Dio errors; handle() is a no-op
      // for AppExceptions and classifies anything else.
      throw DioErrorHandler.handle(error, stackTrace);
    }
  }

  /// Builds the full stack (defaults + interceptors); test-visible so tests
  /// can assert the static defaults and interceptor behavior deterministically.
  @visibleForTesting
  static Dio buildDio({
    required String baseUrl,
    required SecureStorageClient secureStorage,
    required String Function() localeProvider,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Duration sendTimeout = const Duration(seconds: 30),
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        responseType: ResponseType.json,
        contentType: 'application/json; charset=utf-8',
        headers: <String, dynamic>{
          Headers.acceptHeader: 'application/json',
          // Static identity header set once here — every request carries it.
          ApiKeys.clientTypeHeaderKey: ApiKeys.clientTypeHeaderValue,
        },
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
    // Order matters: onRequest runs top-down, onResponse/onError bottom-up,
    // so logging first sees the final classified outcome.
    if (kDebugMode) {
      dio.interceptors.add(const NetworkLoggingInterceptor());
    }
    dio.interceptors.addAll(<Interceptor>[
      AuthInterceptor(secureStorage),
      const ErrorInterceptor(),
    ]);
    return dio;
  }
}
