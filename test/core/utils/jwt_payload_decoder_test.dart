import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/utils/jwt_payload_decoder.dart';

void main() {
  String createTestJwt(
    Map<String, dynamic> payload, {
    String header = '{"alg":"RS256","typ":"JWT"}',
    String signature = 'fake_signature',
  }) {
    final encodedHeader = base64Url
        .encode(utf8.encode(header))
        .replaceAll('=', '');
    final encodedPayload = base64Url
        .encode(utf8.encode(jsonEncode(payload)))
        .replaceAll('=', '');
    return '$encodedHeader.$encodedPayload.$signature';
  }

  group('decodeGoogleIdToken', () {
    test('should decode valid token with all required and optional claims', () {
      final jwt = createTestJwt({
        'iss': 'https://accounts.google.com',
        'sub': '1234567890',
        'email': 'user@example.com',
        'given_name': 'Jane',
        'family_name': 'Doe',
      });

      final result = decodeGoogleIdToken(jwt);

      expect(result.iss, 'https://accounts.google.com');
      expect(result.sub, '1234567890');
      expect(result.email, 'user@example.com');
      expect(result.givenName, 'Jane');
      expect(result.familyName, 'Doe');
      expect(result.idToken, jwt);
    });

    test('should accept accounts.google.com without https:// scheme', () {
      final jwt = createTestJwt({
        'iss': 'accounts.google.com',
        'sub': '1234567890',
        'email': 'user@example.com',
      });

      final result = decodeGoogleIdToken(jwt);

      expect(result.iss, 'accounts.google.com');
      expect(result.sub, '1234567890');
      expect(result.email, 'user@example.com');
    });

    test('should fall back to displayName when given_name/family_name are absent', () {
      final jwt = createTestJwt({
        'iss': 'https://accounts.google.com',
        'sub': '1234567890',
        'email': 'user@example.com',
      });

      final result = decodeGoogleIdToken(jwt, displayName: 'John Alexander Smith');

      expect(result.givenName, 'John');
      expect(result.familyName, 'Alexander Smith');
    });

    test('should handle single-word displayName correctly', () {
      final jwt = createTestJwt({
        'iss': 'https://accounts.google.com',
        'sub': '1234567890',
        'email': 'user@example.com',
      });

      final result = decodeGoogleIdToken(jwt, displayName: 'Marwan');

      expect(result.givenName, 'Marwan');
      expect(result.familyName, isEmpty);
    });

    test('should default to empty strings when all names are absent', () {
      final jwt = createTestJwt({
        'iss': 'https://accounts.google.com',
        'sub': '1234567890',
        'email': 'user@example.com',
      });

      final result = decodeGoogleIdToken(jwt);

      expect(result.givenName, isEmpty);
      expect(result.familyName, isEmpty);
    });

    test('should decode UTF-8 characters properly in claims', () {
      final jwt = createTestJwt({
        'iss': 'https://accounts.google.com',
        'sub': '987654321',
        'email': 'marwan@example.com',
        'given_name': 'مروان',
        'family_name': 'غريب',
      });

      final result = decodeGoogleIdToken(jwt);

      expect(result.givenName, 'مروان');
      expect(result.familyName, 'غريب');
    });

    test('should throw FormatException when token has fewer than 3 segments', () {
      expect(
        () => decodeGoogleIdToken('only.two_parts'),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw FormatException on invalid base64 characters', () {
      expect(
        () => decodeGoogleIdToken('header.invalid!@#base64.signature'),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw FormatException when payload is not a JSON object', () {
      final encodedHeader = base64Url.encode(utf8.encode('{}'));
      final encodedPayload = base64Url.encode(utf8.encode('"just a string"'));
      final jwt = '$encodedHeader.$encodedPayload.sig';

      expect(
        () => decodeGoogleIdToken(jwt),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw FormatException when iss is invalid or missing', () {
      final noIss = createTestJwt({
        'sub': '123',
        'email': 'user@example.com',
      });
      final wrongIss = createTestJwt({
        'iss': 'https://attacker.com',
        'sub': '123',
        'email': 'user@example.com',
      });

      expect(() => decodeGoogleIdToken(noIss), throwsA(isA<FormatException>()));
      expect(() => decodeGoogleIdToken(wrongIss), throwsA(isA<FormatException>()));
    });

    test('should throw FormatException when sub is missing or empty', () {
      final noSub = createTestJwt({
        'iss': 'https://accounts.google.com',
        'email': 'user@example.com',
      });
      final emptySub = createTestJwt({
        'iss': 'https://accounts.google.com',
        'sub': '   ',
        'email': 'user@example.com',
      });

      expect(() => decodeGoogleIdToken(noSub), throwsA(isA<FormatException>()));
      expect(() => decodeGoogleIdToken(emptySub), throwsA(isA<FormatException>()));
    });

    test('should throw FormatException when email is missing or empty', () {
      final noEmail = createTestJwt({
        'iss': 'https://accounts.google.com',
        'sub': '12345',
      });
      final emptyEmail = createTestJwt({
        'iss': 'https://accounts.google.com',
        'sub': '12345',
        'email': '   ',
      });

      expect(() => decodeGoogleIdToken(noEmail), throwsA(isA<FormatException>()));
      expect(() => decodeGoogleIdToken(emptyEmail), throwsA(isA<FormatException>()));
    });
  });
}
