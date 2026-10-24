import 'package:flutter/material.dart';

import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/i18n/strings.g.dart';

/// One-liner accessors for ambient [BuildContext] state (theme, media query,
/// focus). Note: `context.colors` / `context.textStyles` live next to their
/// extension classes in `lib/core/theme/extensions/`.
extension AppContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  bool get isDark => theme.brightness == Brightness.dark;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => MediaQuery.sizeOf(this);

  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  EdgeInsets get padding => MediaQuery.paddingOf(this);

  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  /// Localized, user-safe copy for a [Failure] (ERR-4). The single place a
  /// failure becomes screen text; `Failure.message` itself is never shown.
  String failureText(Failure failure) => switch (failure) {
    NetworkFailure(:final reason) => _networkText(this, reason),
    CancelledFailure() => t.errors.cancelled,
    UnauthorizedFailure() => t.errors.unauthorized,
    SessionExpiredFailure() => t.errors.sessionExpired,
    InvalidCredentialsFailure() => t.errors.invalidCredentials,
    ForbiddenFailure() => t.errors.forbidden,
    NotFoundFailure(:final statusCode) =>
      statusCode == 410 ? t.errors.gone : t.errors.notFound,
    ValidationFailure() => t.errors.validation,
    RequestFailure(:final statusCode) => switch (statusCode) {
      400 => t.errors.request400,
      405 => t.errors.request405,
      409 => t.errors.request409,
      413 => t.errors.request413,
      423 => t.errors.request423,
      451 => t.errors.request451,
      _ => t.errors.request,
    },
    ServerFailure(:final statusCode, :final retryAfter) =>
      statusCode == 503
          ? switch (_waitPhrase(this, retryAfter)) {
              final wait? => t.errors.server503Wait(wait: wait),
              null => t.errors.server503,
            }
          : statusCode == 502
          ? t.errors.server502
          : t.errors.server,
    RateLimitFailure(:final retryAfter) => switch (_waitPhrase(
      this,
      retryAfter,
    )) {
      final wait? => t.errors.rateLimitWait(wait: wait),
      null => t.errors.rateLimit,
    },
    ParsingFailure() => t.errors.parsing,
    CacheFailure() => t.errors.cache,
    StorageFailure() => t.errors.storage,
    UnknownFailure() => t.errors.unknown,
  };
}

String _networkText(BuildContext context, NetworkErrorReason reason) =>
    switch (reason) {
      NetworkErrorReason.noInternet => context.t.errors.offline,
      NetworkErrorReason.serverUnreachable => context.t.errors.unreachable,
      NetworkErrorReason.connectionTimeout ||
      NetworkErrorReason.sendTimeout ||
      NetworkErrorReason.receiveTimeout ||
      NetworkErrorReason.requestTimeout => context.t.errors.timeout,
      NetworkErrorReason.badCertificate => context.t.errors.certificate,
    };

/// Mirrors `ErrorMapper`'s wait phrasing ("5 seconds" / "2 minutes").
String? _waitPhrase(BuildContext context, Duration? retryAfter) {
  final seconds = retryAfter?.inSeconds ?? 0;
  if (seconds <= 0) return null;
  if (seconds < 60) return context.t.errors.waitSeconds(n: seconds);
  final minutes = (seconds + 59) ~/ 60;
  return context.t.errors.waitMinutes(n: minutes);
}
