import 'package:orbit/core/errors/dio_error_handler.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/logger.dart';

const _unknownCopy = 'Something unexpected happened. Please try again.';

/// The single place [AppException]s become [Failure]s. Owns every piece of
/// user-facing copy, logs the technical detail that mapping is about to drop,
/// and only lets backend text through after a safety check.
final class ErrorMapper {
  const ErrorMapper._();

  /// Converts any [error] into a [Failure]; never throws.
  static Failure toFailure(Object error, [StackTrace? st]) {
    try {
      final exception = error is AppException
          ? error
          : DioErrorHandler.handle(error, st);
      _log(exception, st ?? exception.stackTrace);
      return _toFailure(exception);
    } catch (e) {
      AppLogger.error(
        'Error mapping failed: $e',
        tag: 'ERR',
        error: e,
        stackTrace: st,
      );
      return const UnknownFailure(message: _unknownCopy);
    }
  }

  /// No wildcard: adding an [AppException] subtype must fail to compile here.
  static Failure _toFailure(AppException e) {
    final status = e.statusCode;
    final server = e.serverMessage;
    final code = e.errorCode;
    return switch (e) {
      final NetworkException network => NetworkFailure(
        message: _networkMessage(network.reason),
        reason: network.reason,
        statusCode: status,
        serverMessage: server,
        errorCode: code,
      ),
      RequestCancelledException() => CancelledFailure(
        message: 'The request was cancelled.',
        statusCode: status,
        serverMessage: server,
        errorCode: code,
      ),
      UnauthorizedException() => UnauthorizedFailure(
        message: "We couldn't verify your identity. Please sign in again.",
        statusCode: status,
        serverMessage: server,
        errorCode: code,
      ),
      ForbiddenException() => ForbiddenFailure(
        message: "You don't have permission to do this.",
        statusCode: status,
        serverMessage: server,
        errorCode: code,
      ),
      NotFoundException() => NotFoundFailure(
        message: status == 410
            ? 'This is no longer available.'
            : "We couldn't find what you were looking for.",
        statusCode: status,
        serverMessage: server,
        errorCode: code,
      ),
      final ValidationException validation => ValidationFailure(
        message:
            _backendMessage(validation) ??
            'Please check the highlighted fields and try again.',
        fieldErrors: _safeFieldErrors(validation.fieldErrors),
        statusCode: status,
        serverMessage: server,
        errorCode: code,
      ),
      final RateLimitException rate => RateLimitFailure(
        message: _rateLimitMessage(rate.retryAfter),
        retryAfter: rate.retryAfter,
        statusCode: status,
        serverMessage: server,
        errorCode: code,
      ),
      final ClientErrorException client => RequestFailure(
        message: _backendMessage(client) ?? _requestMessage(status),
        statusCode: status,
        serverMessage: server,
        errorCode: code,
      ),
      final ServerErrorException serverError => ServerFailure(
        message: _serverFailureMessage(status, serverError.retryAfter),
        retryAfter: serverError.retryAfter,
        statusCode: status,
        serverMessage: server,
        errorCode: code,
      ),
      UnexpectedResponseException() => UnknownFailure(
        message: _unknownCopy,
        statusCode: status,
        serverMessage: server,
        errorCode: code,
      ),
      ParsingException() => ParsingFailure(
        message:
            'We received unexpected data from the server. Please try again.',
        statusCode: status,
        serverMessage: server,
        errorCode: code,
      ),
      CacheException() => CacheFailure(
        message: "We couldn't read the saved data on your device.",
        statusCode: status,
        serverMessage: server,
        errorCode: code,
      ),
      SecureStorageException() => StorageFailure(
        message:
            "We couldn't access secure data on your device. "
            'Please sign in again.',
        statusCode: status,
        serverMessage: server,
        errorCode: code,
      ),
      UnknownException() => UnknownFailure(
        message: _unknownCopy,
        statusCode: status,
        serverMessage: server,
        errorCode: code,
      ),
    };
  }

  /// Logs what the [Failure] is about to leave out. Routine problems warn;
  /// anything that hints at a bug or a broken backend errors with the stack
  /// trace (so a `TypeError` turned into a parsing failure is never silent).
  /// Never logs bodies, headers or tokens.
  static void _log(AppException e, StackTrace? stackTrace) {
    final details = [
      e.message,
      if (e.errorCode != null) 'code=${e.errorCode}',
      if (e.serverMessage != null) 'server=${e.serverMessage}',
    ].join(' | ');
    final expected = switch (e) {
      NetworkException() ||
      RequestCancelledException() ||
      UnauthorizedException() ||
      ForbiddenException() ||
      NotFoundException() ||
      ValidationException() ||
      RateLimitException() ||
      ClientErrorException() => true,
      _ => false,
    };
    if (expected) {
      AppLogger.warning(details, tag: 'ERR');
    } else {
      AppLogger.error(
        details,
        tag: 'ERR',
        error: e.cause ?? e,
        stackTrace: stackTrace,
      );
    }
  }

  static String _networkMessage(NetworkErrorReason reason) => switch (reason) {
    NetworkErrorReason.noInternet =>
      "You're offline. Check your internet connection and try again.",
    NetworkErrorReason.serverUnreachable =>
      "We couldn't reach the server. Please try again in a moment.",
    NetworkErrorReason.connectionTimeout ||
    NetworkErrorReason.sendTimeout ||
    NetworkErrorReason.receiveTimeout ||
    NetworkErrorReason.requestTimeout =>
      'The server is taking too long to respond. Please try again.',
    NetworkErrorReason.badCertificate =>
      "We couldn't make a secure connection. Check your network and your "
          "device's date and time, then try again.",
  };

  static String _requestMessage(int? status) => switch (status) {
    400 =>
      "We couldn't process your request. Please check your input and "
          'try again.',
    409 => 'This conflicts with existing data. Refresh and try again.',
    413 => "The file or data you're sending is too large.",
    _ => "We couldn't complete your request. Please try again.",
  };

  static String _serverFailureMessage(int? status, Duration? retryAfter) {
    if (status != 503) {
      return 'Something went wrong on our side. Please try again later.';
    }
    final wait = _waitPhrase(retryAfter);
    return wait == null
        ? 'The service is temporarily unavailable. Please try again soon.'
        : 'The service is temporarily unavailable. '
              'Please try again in $wait.';
  }

  static String _rateLimitMessage(Duration? retryAfter) {
    final wait = _waitPhrase(retryAfter);
    return wait == null
        ? 'Too many attempts. Please wait a moment and try again.'
        : 'Too many attempts. Please try again in $wait.';
  }

  static String? _waitPhrase(Duration? retryAfter) {
    final seconds = retryAfter?.inSeconds ?? 0;
    if (seconds <= 0) return null;
    if (seconds < 60) return '$seconds second${seconds == 1 ? '' : 's'}';
    final minutes = (seconds + 59) ~/ 60;
    return '$minutes minute${minutes == 1 ? '' : 's'}';
  }

  /// Statuses where the backend describes the user's own input, so its text
  /// may replace the generic copy (if it passes [_isUserSafe]). Everything
  /// else (401, 403, 404, 429, 5xx, network) always uses our own copy.
  static const Set<int> _backendTextStatuses = {400, 409, 422};

  static String? _backendMessage(AppException e) {
    final server = e.serverMessage;
    if (server == null || !_backendTextStatuses.contains(e.statusCode)) {
      return null;
    }
    return _isUserSafe(server) ? server : null;
  }

  /// Drops unsafe per-field messages so a form never renders backend internals.
  static Map<String, List<String>> _safeFieldErrors(
    Map<String, List<String>> fieldErrors,
  ) {
    final safe = <String, List<String>>{};
    fieldErrors.forEach((field, messages) {
      final kept = [
        for (final m in messages)
          if (_isUserSafe(m, isFieldMessage: true)) m,
      ];
      if (kept.isNotEmpty) safe[field] = kept;
    });
    return safe;
  }

  static const List<String> _technicalMarkers = [
    'exception',
    'stack trace',
    'traceback',
    'sql',
    'errno',
    'constraint',
    'violates',
    'undefined',
    '://',
  ];

  static final RegExp _whitespace = RegExp(r'\s');
  static final RegExp _unsafeChars = RegExp(r'[\r\n<>{}]');
  static final RegExp _plainWord = RegExp(r'^[A-Z]?[a-z]+[.!?]*$');

  /// Conservative on purpose: anything machine-ish falls back to the generic
  /// copy rather than risking an error code or stack trace on screen. A single
  /// word passes only as a per-field message ("Required"), never as an
  /// identifier (`invalid_grant`, `EMAIL_TAKEN`, `emailExists`).
  static bool _isUserSafe(String text, {bool isFieldMessage = false}) {
    final value = text.trim();
    if (value.length < 3 || value.length > 160) return false;
    if (_unsafeChars.hasMatch(value) || value.startsWith('[')) return false;
    if (!_whitespace.hasMatch(value) &&
        !(isFieldMessage && _plainWord.hasMatch(value))) {
      return false;
    }
    final lower = value.toLowerCase();
    return !_technicalMarkers.any(lower.contains);
  }
}
