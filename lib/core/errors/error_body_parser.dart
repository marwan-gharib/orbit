import 'dart:convert';

import 'package:orbit/core/constants/api_keys.dart';

/// The one place an error-response body becomes (serverMessage,
/// fieldErrors, errorCode). Every caller — the Dio error classifier included
/// — shares this parser; features never parse error bodies themselves.
///
/// Value shapes handled per A1:
/// - A String, or a List of Strings, under a precedence key → the server
///   message (first non-empty wins, in [ApiKeys.serverMessageKeyPrecedence]
///   order).
/// - A Map of field -> message(s) under `errors`/`data`, or under a
///   precedence key → per-field errors (>`ValidationFailure.fieldErrors`).
/// - A non-JSON, empty, or keyless body → nothing extracted; the caller
///   keeps a status-code-based failure with no server message.
abstract final class ErrorBodyParser {
  /// The body as a map: an already-decoded JSON object, or a JSON object
  /// arriving as a string (plain `responseType`, wrong content type).
  /// Anything else yields `null` — never throws.
  static Map<String, dynamic>? tryAsMap(Object? body) {
    try {
      var value = body;
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

  /// The first non-empty message across the precedence keys; `null` when
  /// none of the keys hold message-shaped text. Map values under these keys
  /// are field errors by contract, never a message.
  static String? serverMessageOf(Map<String, dynamic> body) {
    for (final key in ApiKeys.serverMessageKeyPrecedence) {
      final message = _messageText(body[key]);
      if (message != null) return message;
    }
    return null;
  }

  /// Per-field errors from, in order, the `errors`/`data` containers and
  /// then any Map value under a precedence key; empty when no source parses.
  static Map<String, List<String>> fieldErrorsOf(Map<String, dynamic> body) {
    final sources = <Object?>[
      for (final key in ApiKeys.fieldErrorsKeys) body[key],
      for (final key in ApiKeys.serverMessageKeyPrecedence) body[key],
    ];
    for (final source in sources) {
      final fields = _fieldMap(source);
      if (fields.isNotEmpty) return fields;
    }
    return const <String, List<String>>{};
  }

  /// The backend error identifier for branching, from any of
  /// [ApiKeys.errorCodeKeys]; `null` when absent.
  static String? errorCodeOf(Map<String, dynamic> body) {
    for (final key in ApiKeys.errorCodeKeys) {
      final value = body[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is int) return value.toString();
    }
    return null;
  }

  static String? _messageText(Object? value) {
    if (value is String) return clean(value);
    if (value is List) {
      final parts = value.map(_messageText).whereType<String>().toList();
      return parts.isEmpty ? null : clean(parts.join('; '));
    }
    return null;
  }

  static Map<String, List<String>> _fieldMap(Object? source) {
    if (source is! Map) return const <String, List<String>>{};
    final result = <String, List<String>>{};
    source.forEach((field, raw) {
      if (field is! String || field.trim().isEmpty) return;
      final items = raw is List ? raw : <Object?>[raw];
      final messages = <String>[];
      for (final item in items) {
        if (item is String) {
          final text = clean(item);
          if (text != null) messages.add(text);
        }
      }
      if (messages.isNotEmpty) result[field.trim()] = messages;
    });
    return result;
  }

  static final RegExp _spaces = RegExp(r'\s+');

  /// Drops unusable text (HTML pages, bare status phrases), collapses
  /// whitespace and caps the length.
  static String? clean(String raw) {
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
    return genericPhrases.contains(text.toLowerCase()) ? null : text;
  }

  /// Status phrases carry no information for a user, so they are dropped.
  static const Set<String> genericPhrases = {
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
}
