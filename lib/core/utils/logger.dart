import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Severity of a log entry, mapped to `dart:developer` numeric levels.
enum AppLogLevel {
  debug(500, '🐛'),
  info(800, 'ℹ️'),
  success(800, '✅'),
  warning(900, '⚠️'),
  error(1000, '❌'),
  fatal(1000, '🔥');

  const AppLogLevel(this.value, this.prefix);

  final int value;
  final String prefix;
}

/// App-wide logger on `dart:developer`. Debug builds print everything at or
/// above [minimumLevel]; release builds print only error and fatal, so
/// production consoles stay quiet and no request bodies leak into CI logs.
abstract final class AppLogger {
  /// Lowest level emitted in debug builds.
  // Fixed rather than settable: nothing in the app raises it, and a mutable
  // static would be shared global state (ARCH-9).
  static const AppLogLevel minimumLevel = AppLogLevel.debug;

  static const String _defaultName = 'orbit';
  static const String _networkTag = 'NET';
  static const String _maskedValue = '••••••';

  static void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Object? data,
  }) => _log(
    AppLogLevel.debug,
    message,
    tag: tag,
    error: error,
    stackTrace: stackTrace,
    data: data,
  );

  static void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Object? data,
  }) => _log(
    AppLogLevel.info,
    message,
    tag: tag,
    error: error,
    stackTrace: stackTrace,
    data: data,
  );

  static void success(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Object? data,
  }) => _log(
    AppLogLevel.success,
    message,
    tag: tag,
    error: error,
    stackTrace: stackTrace,
    data: data,
  );

  static void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Object? data,
  }) => _log(
    AppLogLevel.warning,
    message,
    tag: tag,
    error: error,
    stackTrace: stackTrace,
    data: data,
  );

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Object? data,
  }) => _log(
    AppLogLevel.error,
    message,
    tag: tag,
    error: error,
    stackTrace: stackTrace,
    data: data,
  );

  static void fatal(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Object? data,
  }) => _log(
    AppLogLevel.fatal,
    message,
    tag: tag,
    error: error,
    stackTrace: stackTrace,
    data: data,
  );

  /// Pretty-prints maps/lists as indented JSON; never throws, so logging
  /// cannot mask the original failure.
  static String prettyJson(Object? data) {
    if (data == null) return 'null';
    try {
      if (data is Map || data is List) {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(data);
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }

  /// The `Authorization` header is masked so tokens never reach the console.
  static void logNetworkRequest({
    required String method,
    required String uri,
    Map<String, dynamic>? headers,
    Object? data,
  }) {
    final buffer = StringBuffer('→ $method $uri');
    final masked = _maskHeaders(headers);
    if (masked.isNotEmpty) {
      buffer.write('\n$masked');
    }
    if (data != null) {
      buffer.write('\n${prettyJson(data)}');
    }
    _log(AppLogLevel.debug, buffer.toString(), tag: _networkTag);
  }

  static void logNetworkResponse({
    required String method,
    required String uri,
    int? statusCode,
    Object? data,
  }) {
    final buffer = StringBuffer('← $method $uri → $statusCode');
    if (data != null) {
      buffer.write('\n${prettyJson(data)}');
    }
    _log(AppLogLevel.debug, buffer.toString(), tag: _networkTag);
  }

  static void logNetworkError({
    required String method,
    required String uri,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      AppLogLevel.error,
      '✗ $method $uri failed: $error',
      tag: _networkTag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _log(
    AppLogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Object? data,
  }) {
    if (!_enabled(level)) return;
    final buffer = StringBuffer(level.prefix);
    final effectiveTag = tag;
    if (effectiveTag != null && effectiveTag.isNotEmpty) {
      buffer.write('[$effectiveTag]');
    }
    buffer
      ..write(' ')
      ..write(message);
    if (data != null) {
      buffer
        ..write('\n')
        ..write(prettyJson(data));
    }
    developer.log(
      buffer.toString(),
      name: _defaultName,
      level: level.value,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static bool _enabled(AppLogLevel level) {
    if (kDebugMode) return level.index >= minimumLevel.index;
    return level == AppLogLevel.error || level == AppLogLevel.fatal;
  }

  static Map<String, dynamic> _maskHeaders(Map<String, dynamic>? headers) {
    if (headers == null || headers.isEmpty) return const <String, dynamic>{};
    return headers.map((key, value) {
      if (key.toLowerCase() == 'authorization') {
        return MapEntry<String, dynamic>(key, _maskedValue);
      }
      return MapEntry<String, dynamic>(key, value);
    });
  }
}
