import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/network/interceptors/network_logging_interceptor.dart';

void main() {
  group('NetworkLoggingInterceptor.redactTokens', () {
    test('should mask token values in a decoded body', () {
      final body = <String, dynamic>{
        ApiKeys.accessTokenKey: 'secret-access',
        ApiKeys.refreshTokenKey: 'secret-refresh',
        ApiKeys.emailKey: 'a@b.c',
      };

      final redacted = NetworkLoggingInterceptor.redactTokens(body) as Map;

      expect(redacted[ApiKeys.accessTokenKey], '***');
      expect(redacted[ApiKeys.refreshTokenKey], '***');
      expect(redacted[ApiKeys.emailKey], 'a@b.c');
    });

    test('should mask tokens nested inside lists', () {
      final body = <String, dynamic>{
        ApiKeys.userKey: [
          <String, dynamic>{ApiKeys.accessTokenKey: 'secret-access'},
        ],
      };

      final redacted = NetworkLoggingInterceptor.redactTokens(body) as Map;
      final nested = (redacted[ApiKeys.userKey] as List).first as Map;

      expect(nested[ApiKeys.accessTokenKey], '***');
    });

    test('should leave non-map, non-list values untouched', () {
      expect(NetworkLoggingInterceptor.redactTokens(null), isNull);
      expect(NetworkLoggingInterceptor.redactTokens('plain'), 'plain');
      expect(NetworkLoggingInterceptor.redactTokens(42), 42);
      expect(
        NetworkLoggingInterceptor.redactTokens(<String>['a', 'b']),
        <String>['a', 'b'],
      );
    });

    test('should not mutate the original body', () {
      final body = <String, dynamic>{ApiKeys.accessTokenKey: 'secret-access'};

      NetworkLoggingInterceptor.redactTokens(body);

      expect(body[ApiKeys.accessTokenKey], 'secret-access');
    });
  });

  group('NetworkLoggingInterceptor.sanitizeHeaders', () {
    test('should mask Authorization Bearer token in headers', () {
      final headers = <String, dynamic>{
        'Accept': 'application/json',
        ApiKeys.authorizationHeaderKey: 'Bearer secret_token_xyz',
      };

      final sanitized = NetworkLoggingInterceptor.sanitizeHeaders(headers);

      expect(sanitized[ApiKeys.authorizationHeaderKey], 'Bearer ***');
      expect(sanitized['Accept'], 'application/json');
    });

    test('should leave headers untouched if Authorization header is absent', () {
      final headers = <String, dynamic>{
        'Accept': 'application/json',
        'X-Client-Type': 'Flutter',
      };

      final sanitized = NetworkLoggingInterceptor.sanitizeHeaders(headers);

      expect(sanitized, equals(headers));
    });
  });
}
