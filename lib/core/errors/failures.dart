import 'package:equatable/equatable.dart';

import 'package:orbit/core/errors/exceptions.dart';

/// User-facing outcome of a failed operation. Only [message] may reach the
/// screen; [statusCode]/[serverMessage]/[errorCode] exist for logs, tests and
/// branching, so equality covers them too. Exception: a caller may choose to
/// display [serverMessage] — e.g. a login screen showing the backend's own
/// invalid-credentials text — as long as it screens the text it renders.
sealed class Failure extends Equatable {
  const Failure({
    required this.message,
    this.statusCode,
    this.serverMessage,
    this.errorCode,
  });

  /// Always user-safe; supplied by `ErrorMapper`, never defaulted here.
  final String message;

  final int? statusCode;

  /// Backend text, logging/debug only — never displayed by default. A caller
  /// may deliberately render it after screening it (e.g. a login screen
  /// showing the backend invalid-credentials text); see the class doc.
  final String? serverMessage;

  final String? errorCode;

  @override
  List<Object?> get props => [message, statusCode, serverMessage, errorCode];
}

/// Transport failure; [reason] drives distinct copy per network cause.
final class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    required this.reason,
    super.statusCode,
    super.serverMessage,
    super.errorCode,
  });

  final NetworkErrorReason reason;

  @override
  List<Object?> get props => [...super.props, reason];
}

/// The operation was cancelled before it finished.
final class CancelledFailure extends Failure {
  const CancelledFailure({
    required super.message,
    super.statusCode,
    super.serverMessage,
    super.errorCode,
  });
}

/// Credentials are missing or expired; the user must sign in again.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    required super.message,
    super.statusCode,
    super.serverMessage,
    super.errorCode,
  });
}

/// The backend definitively rejected the refresh token (expired, invalid,
/// blacklisted) or the session was terminally revoked. The local session has
/// been cleared and the user must sign in again.
final class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure({
    required super.message,
    super.statusCode,
    super.serverMessage,
    super.errorCode,
  });
}

/// Authenticated, but not allowed to perform this action.
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    required super.message,
    super.statusCode,
    super.serverMessage,
    super.errorCode,
  });
}

/// 401 on a sign-in attempt: the credentials themselves are wrong. Distinct
/// from [UnauthorizedFailure] so the sign-in flow can show "wrong
/// email/password" copy instead of "sign in again"; the backend's original
/// text stays available through [serverMessage].
final class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure({
    required super.message,
    super.statusCode,
    super.serverMessage,
    super.errorCode,
  });
}

/// The requested resource does not exist or is gone.
final class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.statusCode,
    super.serverMessage,
    super.errorCode,
  });
}

/// Input validation failed; [fieldErrors] holds per-field backend messages for
/// inline form display, already filtered for user safety.
final class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    this.fieldErrors = const <String, List<String>>{},
    super.statusCode,
    super.serverMessage,
    super.errorCode,
  });

  final Map<String, List<String>> fieldErrors;

  @override
  List<Object?> get props => [...super.props, _sortedEntries];

  /// Key-sorted, length-prefixed encoding: maps compare by insertion order in
  /// Dart, so equal maps built in different orders would otherwise break
  /// `==`/`hashCode`, and plain joining could make distinct maps collide.
  List<String> get _sortedEntries => [
    for (final entry
        in fieldErrors.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))
      '${entry.key.length}:${entry.key}:'
          '${entry.value.map((m) => '${m.length}:$m').join()}',
  ];
}

/// The server rejected an otherwise well-formed request (4xx without field
/// details worth showing inline).
final class RequestFailure extends Failure {
  const RequestFailure({
    required super.message,
    super.statusCode,
    super.serverMessage,
    super.errorCode,
  });
}

/// The backend failed to process the request; [retryAfter] carries the 503
/// hint so the UI can tell the user when to come back.
final class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    this.retryAfter,
    super.statusCode,
    super.serverMessage,
    super.errorCode,
  });

  final Duration? retryAfter;

  @override
  List<Object?> get props => [...super.props, retryAfter];
}

/// Rate limit exceeded; [retryAfter] is the parsed `Retry-After` hint.
final class RateLimitFailure extends Failure {
  const RateLimitFailure({
    required super.message,
    this.retryAfter,
    super.statusCode,
    super.serverMessage,
    super.errorCode,
  });

  final Duration? retryAfter;

  @override
  List<Object?> get props => [...super.props, retryAfter];
}

/// A payload could not be encoded or decoded.
final class ParsingFailure extends Failure {
  const ParsingFailure({
    required super.message,
    super.statusCode,
    super.serverMessage,
    super.errorCode,
  });
}

/// A local (non-secure) cache read/write failed.
final class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.statusCode,
    super.serverMessage,
    super.errorCode,
  });
}

/// A secure-storage read/write failed.
final class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.statusCode,
    super.serverMessage,
    super.errorCode,
  });
}

/// No better classification applied.
final class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.statusCode,
    super.serverMessage,
    super.errorCode,
  });
}
