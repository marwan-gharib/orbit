import 'dart:convert';

import 'package:orbit/features/auth/domain/params/google_payload.dart';

/// Decodes the payload segment of a JWT into a JSON map.
/// Throws [FormatException] if the token is malformed, has invalid base64 padding,
/// or does not contain a JSON object.
Map<String, dynamic> decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length < 3) {
    throw const FormatException('JWT must contain at least 3 segments.');
  }

  var normalized = parts[1].replaceAll('-', '+').replaceAll('_', '/');
  switch (normalized.length % 4) {
    case 2:
      normalized += '==';
      break;
    case 3:
      normalized += '=';
      break;
    case 1:
      throw const FormatException('Invalid base64url string length in JWT.');
  }

  try {
    final decodedBytes = base64.decode(normalized);
    final jsonString = utf8.decode(decodedBytes);
    final dynamic decodedJson = jsonDecode(jsonString);
    if (decodedJson is! Map<String, dynamic>) {
      throw const FormatException('Decoded JWT payload is not a JSON object.');
    }
    return decodedJson;
  } on FormatException {
    rethrow;
  } on Object catch (error) {
    throw FormatException('Failed to decode JWT payload: $error');
  }
}

/// Decodes and validates a Google ID token into a [GooglePayload].
///
/// Validates that:
/// - The token is a valid JWT.
/// - The `iss` claim is either `https://accounts.google.com` or `accounts.google.com`.
/// - The `sub` and `email` claims are non-empty strings.
///
/// Falls back to [displayName] if `given_name` or `family_name` is missing from the payload.
GooglePayload decodeGoogleIdToken(String idToken, {String? displayName}) {
  final payload = decodeJwtPayload(idToken);

  final iss = payload['iss'];
  if (iss != 'https://accounts.google.com' && iss != 'accounts.google.com') {
    throw const FormatException(
      'Invalid or missing iss claim in Google ID token.',
    );
  }

  final sub = payload['sub'];
  if (sub is! String || sub.trim().isEmpty) {
    throw const FormatException(
      'Missing or empty sub claim in Google ID token.',
    );
  }

  final email = payload['email'];
  if (email is! String || email.trim().isEmpty) {
    throw const FormatException(
      'Missing or empty email claim in Google ID token.',
    );
  }

  var givenName = payload['given_name'] as String? ?? '';
  var familyName = payload['family_name'] as String? ?? '';

  if (givenName.isEmpty && familyName.isEmpty && displayName != null) {
    final trimmedName = displayName.trim();
    if (trimmedName.isNotEmpty) {
      final nameSegments = trimmedName.split(RegExp(r'\s+'));
      givenName = nameSegments.first;
      if (nameSegments.length > 1) {
        familyName = nameSegments.sublist(1).join(' ');
      }
    }
  }

  return GooglePayload(
    iss: iss,
    sub: sub.trim(),
    email: email.trim(),
    givenName: givenName.trim(),
    familyName: familyName.trim(),
    idToken: idToken,
  );
}
