import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/errors/error_body_parser.dart';

/// Container names the parser accepts, in contract order (ARCH-10/TEST-7):
/// index 0 is the preferred container, index 1 the fallback.
final tErrorsKey = ApiKeys.fieldErrorsKeys[0];
final tDataKey = ApiKeys.fieldErrorsKeys[1];

/// Body keys that may carry a backend error identifier (contract order).
final tCodeKey = ApiKeys.errorCodeKeys[0];
final tCodeKeyAlt = ApiKeys.errorCodeKeys[1];
final tCodeKeyCamel = ApiKeys.errorCodeKeys[2];

void main() {
  group('tryAsMap', () {
    test('should return the body when it is already a map', () {
      final map = ErrorBodyParser.tryAsMap(<String, dynamic>{'a': 1});
      expect(map, {'a': 1});
    });

    test('should decode a JSON object delivered as a string', () {
      final map = ErrorBodyParser.tryAsMap(jsonEncode({'a': 1}));
      expect(map, {'a': 1});
    });

    test('should return null for a non-JSON string body', () {
      expect(ErrorBodyParser.tryAsMap('<html>down</html>'), isNull);
      expect(ErrorBodyParser.tryAsMap(''), isNull);
      expect(ErrorBodyParser.tryAsMap('[1,2,3]'), isNull);
    });

    test('should return null for a non-body value', () {
      expect(ErrorBodyParser.tryAsMap(null), isNull);
      expect(ErrorBodyParser.tryAsMap(42), isNull);
    });
  });

  group('serverMessageOf', () {
    test('should read a string value under each single key', () {
      expect(
        ErrorBodyParser.serverMessageOf({ApiKeys.errorMessageKey: 'Wrong'}),
        'Wrong',
      );
      expect(
        ErrorBodyParser.serverMessageOf({ApiKeys.errorErrorKey: 'Wrong'}),
        'Wrong',
      );
      expect(
        ErrorBodyParser.serverMessageOf({ApiKeys.errorDetailKey: 'Wrong'}),
        'Wrong',
      );
    });

    test('should prefer message when every key is present', () {
      final message = ErrorBodyParser.serverMessageOf(const {
        ApiKeys.errorMessageKey: 'First',
        ApiKeys.errorErrorKey: 'Second',
        ApiKeys.errorDetailKey: 'Third',
      });
      expect(message, 'First');
    });

    test('should fall through the precedence list when earlier keys miss', () {
      final withErrorOnly = ErrorBodyParser.serverMessageOf(const {
        ApiKeys.errorErrorKey: 'Second',
        ApiKeys.errorDetailKey: 'Third',
      });
      expect(withErrorOnly, 'Second');

      final withDetailOnly = ErrorBodyParser.serverMessageOf(const {
        ApiKeys.errorDetailKey: 'Third',
      });
      expect(withDetailOnly, 'Third');
    });

    test('should join a list of strings into one message', () {
      final message = ErrorBodyParser.serverMessageOf(const {
        ApiKeys.errorMessageKey: ['A', 'B'],
      });
      expect(message, 'A; B');
    });

    test('should treat a map value as field errors, not a message', () {
      final body = {
        ApiKeys.errorMessageKey: {ApiKeys.emailKey: 'required'},
        ApiKeys.errorDetailKey: 'Wrong creds',
      };
      expect(ErrorBodyParser.serverMessageOf(body), 'Wrong creds');
    });

    test('should skip empty and generic values', () {
      expect(
        ErrorBodyParser.serverMessageOf({ApiKeys.errorMessageKey: ''}),
        isNull,
      );
      expect(
        ErrorBodyParser.serverMessageOf({ApiKeys.errorMessageKey: 'error'}),
        isNull,
      );
    });

    test('should return null when none of the keys are present', () {
      expect(ErrorBodyParser.serverMessageOf(const {'foo': 'bar'}), isNull);
    });
  });

  group('fieldErrorsOf', () {
    test('should read errors from the errors container', () {
      final fields = ErrorBodyParser.fieldErrorsOf({
        ApiKeys.emailKey: 'exists',
        tErrorsKey: {
          ApiKeys.emailKey: ['Already in use.'],
        },
      });
      expect(fields, {
        ApiKeys.emailKey: ['Already in use.'],
      });
    });

    test('should read errors from the data container as a fallback', () {
      final fields = ErrorBodyParser.fieldErrorsOf({
        tDataKey: {ApiKeys.emailKey: 'Bad domain.'},
      });
      expect(fields, {
        ApiKeys.emailKey: ['Bad domain.'],
      });
    });

    test('should read field errors from a map under a message key (A1)', () {
      final fields = ErrorBodyParser.fieldErrorsOf(const {
        ApiKeys.errorMessageKey: {ApiKeys.passwordKey: 'Too weak.'},
      });
      expect(fields, {
        ApiKeys.passwordKey: ['Too weak.'],
      });
    });

    test('should prefer the errors container over message-key maps', () {
      final fields = ErrorBodyParser.fieldErrorsOf({
        ApiKeys.errorMessageKey: {ApiKeys.passwordKey: 'Too weak.'},
        tErrorsKey: {ApiKeys.emailKey: 'Taken.'},
      });
      expect(fields, {
        ApiKeys.emailKey: ['Taken.'],
      });
    });

    test('should wrap a plain string field message in a list', () {
      final fields = ErrorBodyParser.fieldErrorsOf({
        tErrorsKey: {ApiKeys.emailKey: 'Required'},
      });
      expect(fields, {
        ApiKeys.emailKey: ['Required'],
      });
    });

    test('should drop blank fields and non-string messages', () {
      final fields = ErrorBodyParser.fieldErrorsOf({
        tErrorsKey: {
          '': 'ignored',
          ApiKeys.emailKey: <Object?>[42, 'Kept.'],
        },
      });
      expect(fields, {
        ApiKeys.emailKey: ['Kept.'],
      });
    });

    test('should return empty when no field map exists', () {
      expect(
        ErrorBodyParser.fieldErrorsOf(const {ApiKeys.errorMessageKey: 'Text'}),
        isEmpty,
      );
    });
  });

  group('errorCodeOf', () {
    test('should read a string identifier from each known key', () {
      expect(
        ErrorBodyParser.errorCodeOf({tCodeKey: 'EMAIL_TAKEN'}),
        'EMAIL_TAKEN',
      );
      expect(
        ErrorBodyParser.errorCodeOf({tCodeKeyAlt: 'EMAIL_TAKEN'}),
        'EMAIL_TAKEN',
      );
      expect(
        ErrorBodyParser.errorCodeOf({tCodeKeyCamel: 'EMAIL_TAKEN'}),
        'EMAIL_TAKEN',
      );
    });

    test('should stringify an int identifier', () {
      expect(ErrorBodyParser.errorCodeOf({tCodeKey: 4011}), '4011');
    });

    test('should return null when no key carries a value', () {
      expect(ErrorBodyParser.errorCodeOf({tCodeKey: ''}), isNull);
      expect(ErrorBodyParser.errorCodeOf(const {}), isNull);
    });
  });
}
