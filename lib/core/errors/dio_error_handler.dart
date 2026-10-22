import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:orbit/core/errors/error_body_parser.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/network_exception_factory.dart';

/// Classifies any Dio/platform error into an [AppException]. Exhaustive over
/// `DioExceptionType` (no default) so a Dio upgrade that adds a type fails to
/// compile here instead of quietly reaching the user as "unknown error".
///
/// Error bodies are expected in the backend envelope `{status, message, data}`;
/// a few common variants (`error`, `detail`, `errors`, message lists) are also
/// tolerated.
abstract final class DioErrorHandler {
  /// Converts [error] into an [AppException]; [st] fills in when the error
  /// carries no stack trace of its own. Never throws.
  static AppException handle(Object error, [StackTrace? st]) {
    try {
      if (error is AppException) return error;
      if (error is DioException) {
        final inner = error.error;
        if (inner is AppException) return inner;
        return _fromDio(error, st ?? error.stackTrace);
      }
      // Raw errors arrive without a stack when the caller omitted one, but
      // parsing/unknown reports must still be loggable with a trace.
      final trace = st ?? StackTrace.current;
      if (error is FormatException || error is TypeError) {
        return ParsingException(cause: error, stackTrace: trace);
      }
      if (error is SocketException) {
        return NetworkExceptionFactory.of(
          NetworkExceptionFactory.reasonOf(error),
          'Socket error: $error',
          error,
          trace,
        );
      }
      if (error is TimeoutException) {
        return NetworkExceptionFactory.of(
          NetworkErrorReason.connectionTimeout,
          'The operation timed out.',
          error,
          trace,
        );
      }
      return UnknownException(cause: error, stackTrace: trace);
    } catch (e) {
      return UnknownException(
        message: 'Error classification failed: $e',
        cause: error,
        stackTrace: st ?? StackTrace.current,
      );
    }
  }

  static AppException _fromDio(DioException error, StackTrace? st) {
    final carrier = error.error ?? error;
    final technical = _technical(error);
    return switch (error.type) {
      // The transformer's own deadline reads as "too slow" to the user.
      DioExceptionType.connectionTimeout ||
      DioExceptionType.transformTimeout => NetworkExceptionFactory.of(
        NetworkErrorReason.connectionTimeout,
        technical,
        carrier,
        st,
      ),
      DioExceptionType.sendTimeout => NetworkExceptionFactory.of(
        NetworkErrorReason.sendTimeout,
        technical,
        carrier,
        st,
      ),
      DioExceptionType.receiveTimeout => NetworkExceptionFactory.of(
        NetworkErrorReason.receiveTimeout,
        technical,
        carrier,
        st,
      ),
      DioExceptionType.badCertificate => NetworkExceptionFactory.of(
        NetworkErrorReason.badCertificate,
        technical,
        carrier,
        st,
      ),
      DioExceptionType.badResponse => _fromResponse(error, st),
      DioExceptionType.cancel => RequestCancelledException(
        message: technical,
        cause: carrier,
        stackTrace: st,
      ),
      DioExceptionType.connectionError => NetworkExceptionFactory.of(
        NetworkExceptionFactory.reasonOf(carrier),
        technical,
        carrier,
        st,
      ),
      DioExceptionType.unknown => _fromUnknown(error, st),
    };
  }

  static AppException _fromUnknown(DioException error, StackTrace? st) {
    final cause = error.error;
    final technical = _technical(error);
    if (cause is FormatException || cause is TypeError) {
      return ParsingException(
        message: 'Failed to parse a payload: $cause',
        cause: cause,
        stackTrace: st,
      );
    }
    if (cause is TimeoutException) {
      return NetworkExceptionFactory.of(
        NetworkErrorReason.connectionTimeout,
        technical,
        cause,
        st,
      );
    }
    final reason = NetworkExceptionFactory.reasonOf(cause ?? error);
    if (cause is SocketException || reason == NetworkErrorReason.noInternet) {
      return NetworkExceptionFactory.of(reason, technical, cause ?? error, st);
    }
    return UnknownException(
      message: technical,
      cause: cause ?? error,
      stackTrace: st,
    );
  }

  /// Dio's own text is developer-facing, so it only ever lands here.
  static String _technical(DioException error) {
    final detail = error.message?.trim();
    if (detail == null || detail.isEmpty) return error.type.name;
    return '${error.type.name}: $detail';
  }

  static AppException _fromResponse(DioException error, StackTrace? st) {
    final response = error.response;
    final status = response?.statusCode;
    final cause = error.error ?? error;
    if (status == null) {
      return NetworkExceptionFactory.of(
        NetworkErrorReason.serverUnreachable,
        'The response carried no status code.',
        cause,
        st,
      );
    }
    final data = response?.data;
    // A non-JSON, empty, or keyless body contributes nothing (A1): the
    // status switch below still classifies the failure, with no server copy.
    final body = ErrorBodyParser.tryAsMap(data);
    final technical = 'HTTP $status';
    final serverMessage = body == null
        ? null
        : ErrorBodyParser.serverMessageOf(body);
    final errorCode = body == null ? null : ErrorBodyParser.errorCodeOf(body);
    final fieldErrors = body != null && (status == 400 || status == 422)
        ? ErrorBodyParser.fieldErrorsOf(body)
        : const <String, List<String>>{};
    final retryAfter = status == 429 || status == 503
        ? _retryAfter(response?.headers)
        : null;
    return switch (status) {
      401 => UnauthorizedException(
        message: technical,
        statusCode: status,
        serverMessage: serverMessage,
        errorCode: errorCode,
        data: data,
        cause: cause,
        stackTrace: st,
      ),
      403 => ForbiddenException(
        message: technical,
        statusCode: status,
        serverMessage: serverMessage,
        errorCode: errorCode,
        data: data,
        cause: cause,
        stackTrace: st,
      ),
      404 || 410 => NotFoundException(
        message: technical,
        statusCode: status,
        serverMessage: serverMessage,
        errorCode: errorCode,
        data: data,
        cause: cause,
        stackTrace: st,
      ),
      408 => NetworkExceptionFactory.of(
        NetworkErrorReason.requestTimeout,
        technical,
        cause,
        st,
      ),
      422 => ValidationException(
        message: technical,
        fieldErrors: fieldErrors,
        statusCode: status,
        serverMessage: serverMessage,
        errorCode: errorCode,
        data: data,
        cause: cause,
        stackTrace: st,
      ),
      429 => RateLimitException(
        message: technical,
        retryAfter: retryAfter,
        serverMessage: serverMessage,
        errorCode: errorCode,
        data: data,
        cause: cause,
        stackTrace: st,
      ),
      >= 400 && < 500 =>
        fieldErrors.isNotEmpty
            ? ValidationException(
                message: technical,
                fieldErrors: fieldErrors,
                statusCode: status,
                serverMessage: serverMessage,
                errorCode: errorCode,
                data: data,
                cause: cause,
                stackTrace: st,
              )
            : ClientErrorException(
                message: technical,
                statusCode: status,
                serverMessage: serverMessage,
                errorCode: errorCode,
                data: data,
                cause: cause,
                stackTrace: st,
              ),
      >= 500 && < 600 => ServerErrorException(
        message: technical,
        statusCode: status,
        retryAfter: retryAfter,
        serverMessage: serverMessage,
        errorCode: errorCode,
        data: data,
        cause: cause,
        stackTrace: st,
      ),
      _ => UnexpectedResponseException(
        message: technical,
        statusCode: status,
        serverMessage: serverMessage,
        errorCode: errorCode,
        data: data,
        cause: cause,
        stackTrace: st,
      ),
    };
  }

  /// Delta-seconds only: the HTTP-date form depends on clock sync, so it is
  /// ignored rather than guessed.
  static Duration? _retryAfter(Headers? headers) {
    try {
      final values = headers?['retry-after'];
      if (values == null || values.isEmpty) return null;
      final seconds = int.tryParse(values.first.trim());
      if (seconds == null || seconds < 0) return null;
      return Duration(seconds: seconds);
    } catch (_) {
      return null;
    }
  }
}
