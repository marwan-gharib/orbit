import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:orbit/core/errors/exceptions.dart';

/// Classifies any Dio/platform error into an [AppException]. Exhaustive over
/// `DioExceptionType` (no default) so a Dio upgrade that adds a type fails to
/// compile here instead of quietly reaching the user as "unknown error".
///
/// Error bodies are expected in the backend envelope `{status, message, data}`;
/// a few common variants (`error`, `detail`, `errors`, message lists) are also
/// tolerated.
final class DioErrorHandler {
  const DioErrorHandler._();

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
        return _network(
          _networkReason(error),
          'Socket error: $error',
          error,
          trace,
        );
      }
      if (error is TimeoutException) {
        return _network(
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
      DioExceptionType.transformTimeout => _network(
        NetworkErrorReason.connectionTimeout,
        technical,
        carrier,
        st,
      ),
      DioExceptionType.sendTimeout => _network(
        NetworkErrorReason.sendTimeout,
        technical,
        carrier,
        st,
      ),
      DioExceptionType.receiveTimeout => _network(
        NetworkErrorReason.receiveTimeout,
        technical,
        carrier,
        st,
      ),
      DioExceptionType.badCertificate => _network(
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
      DioExceptionType.connectionError => _network(
        _networkReason(carrier),
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
      return _network(
        NetworkErrorReason.connectionTimeout,
        technical,
        cause,
        st,
      );
    }
    final reason = _networkReason(cause ?? error);
    if (cause is SocketException || reason == NetworkErrorReason.noInternet) {
      return _network(reason, technical, cause ?? error, st);
    }
    return UnknownException(
      message: technical,
      cause: cause ?? error,
      stackTrace: st,
    );
  }

  static NetworkException _network(
    NetworkErrorReason reason,
    String technical,
    Object? cause,
    StackTrace? st,
  ) => NetworkException(
    reason: reason,
    message: technical,
    statusCode: reason == NetworkErrorReason.requestTimeout ? 408 : null,
    cause: cause,
    stackTrace: st,
  );

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
      return _network(
        NetworkErrorReason.serverUnreachable,
        'The response carried no status code.',
        cause,
        st,
      );
    }
    final data = response?.data;
    final body = _asMap(data);
    final technical = 'HTTP $status';
    final serverMessage = body != null
        ? _messageOf(body)
        : (data is String ? _clean(data) : null);
    final errorCode = body == null ? null : _errorCode(body);
    final fieldErrors = body != null && (status == 400 || status == 422)
        ? _fieldErrors(body)
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
      408 => _network(NetworkErrorReason.requestTimeout, technical, cause, st),
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

  /// `SocketException` is not always "no internet": only DNS/network-down
  /// wording counts as offline; refused/reset/closed mean the server is the
  /// problem. Walks the cause chain because Dio wraps the original error.
  static NetworkErrorReason _networkReason(Object? error) {
    Object? node = error;
    for (var hops = 0; node != null && hops < 8; hops++) {
      final text = node.toString().toLowerCase();
      if (_offlineMarkers.any(text.contains)) {
        return NetworkErrorReason.noInternet;
      }
      node = node is DioException ? node.error : null;
    }
    return NetworkErrorReason.serverUnreachable;
  }

  static const List<String> _offlineMarkers = [
    'failed host lookup',
    'network is unreachable',
    'no address associated with hostname',
    'no such host is known',
    'nodename nor servname provided',
  ];

  /// The body as a map: Dio's decoded JSON, or a JSON string (plain
  /// `responseType`, wrong content type). Anything else yields null.
  static Map<String, dynamic>? _asMap(Object? data) {
    try {
      var value = data;
      if (value is String) {
        final trimmed = value.trim();
        if (!trimmed.startsWith('{')) return null;
        value = jsonDecode(trimmed);
      }
      return value is Map ? Map<String, dynamic>.from(value) : null;
    } catch (_) {
      return null;
    }
  }

  /// Keys that may hold the human-readable message, in priority order.
  static const List<String> _messageKeys = [
    'message',
    'error',
    'detail',
    'msg',
  ];

  static String? _messageOf(Map<String, dynamic> body) {
    for (final key in _messageKeys) {
      final text = _text(body[key]);
      if (text != null) return text;
    }
    return null;
  }

  /// Reads a message from a string, a list of strings (NestJS-style
  /// validation) or a nested `{message: ...}` map.
  static String? _text(Object? value) {
    if (value is String) return _clean(value);
    if (value is List) {
      final parts = value.map(_text).whereType<String>().toList();
      return parts.isEmpty ? null : _clean(parts.join('; '));
    }
    if (value is Map) return _text(value['message']);
    return null;
  }

  static final RegExp _spaces = RegExp(r'\s+');

  /// Drops unusable text (HTML pages, bare status phrases), collapses
  /// whitespace and caps the length.
  static String? _clean(String raw) {
    var text = raw.trim();
    if (text.isEmpty) return null;
    final lower = text.toLowerCase();
    if (text.startsWith('<') ||
        lower.contains('<html') ||
        lower.contains('<!doctype')) {
      return null;
    }
    text = text.replaceAll(_spaces, ' ');
    if (text.length > 300) text = text.substring(0, 300).trimRight();
    return _genericPhrases.contains(text.toLowerCase()) ? null : text;
  }

  /// Status phrases carry no information for a user, so they are dropped.
  static const Set<String> _genericPhrases = {
    'error',
    'bad request',
    'unauthorized',
    'forbidden',
    'not found',
    'conflict',
    'unprocessable entity',
    'unprocessable content',
    'too many requests',
    'internal server error',
    'bad gateway',
    'service unavailable',
    'gateway timeout',
  };

  static String? _errorCode(Map<String, dynamic> body) {
    for (final key in ['code', 'error_code', 'errorCode']) {
      final value = body[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is int) return value.toString();
    }
    return null;
  }

  /// Per-field messages for 400/422, read from `errors` (or `data`) shaped
  /// `{field: message}` or `{field: [messages]}`.
  static Map<String, List<String>> _fieldErrors(Map<String, dynamic> body) {
    for (final key in ['errors', 'data']) {
      final container = body[key];
      if (container is! Map) continue;
      final result = <String, List<String>>{};
      container.forEach((field, value) {
        if (field is! String || field.trim().isEmpty) return;
        final raw = value is List ? value : <Object?>[value];
        final messages = <String>[];
        for (final item in raw) {
          final text = item is String ? _clean(item) : null;
          if (text != null) messages.add(text);
        }
        if (messages.isNotEmpty) result[field.trim()] = messages;
      });
      if (result.isNotEmpty) return result;
    }
    return const <String, List<String>>{};
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
