/// Developer-facing error taxonomy: keeps full technical detail for logs and
/// branching. Nothing here is safe to show to a user — user copy lives only
/// in `error_mapper.dart`.
sealed class AppException implements Exception {
  const AppException({
    required this.message,
    this.statusCode,
    this.serverMessage,
    this.errorCode,
    this.data,
    this.cause,
    this.stackTrace,
  });

  /// Technical English summary for logs; never rendered in the UI.
  final String message;

  /// HTTP status behind the error, when the server sent one.
  final int? statusCode;

  /// Backend text after cleanup; logging only, gated before display.
  final String? serverMessage;

  /// Backend error identifier (`code`, `error_code`, ...) for branching.
  final String? errorCode;

  /// Raw response body, kept for debugging.
  final Object? data;

  /// Original error this one was derived from.
  final Object? cause;

  final StackTrace? stackTrace;

  @override
  String toString() {
    final buffer = StringBuffer(runtimeType);
    final status = statusCode;
    if (status != null) {
      buffer.write('($status)');
    }
    buffer.write(': $message');
    final server = serverMessage;
    if (server != null) {
      buffer.write(' | server: $server');
    }
    final code = errorCode;
    if (code != null) {
      buffer.write(' | code: $code');
    }
    if (cause != null) {
      buffer.write(' | cause: $cause');
    }
    return buffer.toString();
  }
}

/// Why the network layer failed; the mapper picks user copy per reason, so it
/// never has to interpret free text.
enum NetworkErrorReason {
  /// Clear offline indicators (DNS failure, unreachable network).
  noInternet,

  /// The host exists but the connection was refused, reset or dropped.
  serverUnreachable,

  /// Establishing or holding the connection timed out.
  connectionTimeout,

  /// Uploading the request body timed out.
  sendTimeout,

  /// Downloading the response body timed out.
  receiveTimeout,

  /// HTTP 408: the server timed out waiting for the request.
  requestTimeout,

  /// TLS validation failed, so no secure connection was possible.
  badCertificate,
}

/// Transport-level failure, before any HTTP response exists.
final class NetworkException extends AppException {
  const NetworkException({
    required this.reason,
    super.message = 'The network request failed.',
    super.statusCode,
    super.serverMessage,
    super.errorCode,
    super.data,
    super.cause,
    super.stackTrace,
  });

  final NetworkErrorReason reason;
}

/// The caller cancelled the request, so there is nothing to report as an error.
final class RequestCancelledException extends AppException {
  const RequestCancelledException({
    super.message = 'The request was cancelled.',
    super.statusCode,
    super.serverMessage,
    super.errorCode,
    super.data,
    super.cause,
    super.stackTrace,
  });
}

/// 401 — credentials are missing or expired; only re-authentication helps.
final class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'The server rejected the credentials.',
    super.statusCode = 401,
    super.serverMessage,
    super.errorCode,
    super.data,
    super.cause,
    super.stackTrace,
  });
}

/// 403 — authenticated but not allowed; retrying will not change the outcome.
final class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'The server denied access to this resource.',
    super.statusCode = 403,
    super.serverMessage,
    super.errorCode,
    super.data,
    super.cause,
    super.stackTrace,
  });
}

/// 404/410 — the addressed resource does not exist (or no longer does).
final class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
    super.serverMessage,
    super.errorCode,
    super.data,
    super.cause,
    super.stackTrace,
  });
}

/// 400 with field-level errors, or 422 — carries per-field messages so forms
/// can highlight exactly what the backend rejected.
final class ValidationException extends AppException {
  const ValidationException({
    super.message = 'The request failed validation.',
    super.statusCode = 422,
    this.fieldErrors = const <String, List<String>>{},
    super.serverMessage,
    super.errorCode,
    super.data,
    super.cause,
    super.stackTrace,
  });

  final Map<String, List<String>> fieldErrors;
}

/// 429 — too many attempts; [retryAfter] comes from the `Retry-After` header.
final class RateLimitException extends AppException {
  const RateLimitException({
    super.message = 'The request was rate limited.',
    super.statusCode = 429,
    this.retryAfter,
    super.serverMessage,
    super.errorCode,
    super.data,
    super.cause,
    super.stackTrace,
  });

  final Duration? retryAfter;
}

/// Any other 4xx — one type keeps the status code instead of a class per code.
final class ClientErrorException extends AppException {
  const ClientErrorException({
    required super.statusCode,
    super.message = 'The server rejected the request.',
    super.serverMessage,
    super.errorCode,
    super.data,
    super.cause,
    super.stackTrace,
  });
}

/// Any 5xx — server-side problem; [retryAfter] carries the 503 hint.
final class ServerErrorException extends AppException {
  const ServerErrorException({
    super.statusCode = 500,
    super.message = 'The server failed to process the request.',
    this.retryAfter,
    super.serverMessage,
    super.errorCode,
    super.data,
    super.cause,
    super.stackTrace,
  });

  final Duration? retryAfter;
}

/// A status code the API should never produce (1xx, 3xx, outside 100-599);
/// kept apart from 4xx/5xx so the mapper can flag it as truly unexpected.
final class UnexpectedResponseException extends AppException {
  const UnexpectedResponseException({
    required super.statusCode,
    super.message = 'Received an unexpected status code.',
    super.serverMessage,
    super.errorCode,
    super.data,
    super.cause,
    super.stackTrace,
  });
}

/// The payload could not be decoded; a code bug or an incompatible backend.
final class ParsingException extends AppException {
  const ParsingException({
    super.message = 'Failed to parse the request or response payload.',
    super.statusCode,
    super.serverMessage,
    super.errorCode,
    super.data,
    super.cause,
    super.stackTrace,
  });
}

/// A local (non-secure) cache read/write failed.
final class CacheException extends AppException {
  const CacheException({
    super.message = 'A cache operation failed.',
    super.statusCode,
    super.serverMessage,
    super.errorCode,
    super.data,
    super.cause,
    super.stackTrace,
  });
}

/// A secure-storage read/write failed, usually meaning tokens are unusable.
final class SecureStorageException extends AppException {
  const SecureStorageException({
    super.message = 'A secure storage operation failed.',
    super.statusCode,
    super.serverMessage,
    super.errorCode,
    super.data,
    super.cause,
    super.stackTrace,
  });
}

/// Last-resort wrapper for any error with no better classification.
final class UnknownException extends AppException {
  const UnknownException({
    super.message = 'An unexpected error occurred.',
    super.statusCode,
    super.serverMessage,
    super.errorCode,
    super.data,
    super.cause,
    super.stackTrace,
  });
}
