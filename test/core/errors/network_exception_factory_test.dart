import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/network_exception_factory.dart';

void main() {
  group('reasonOf', () {
    test(
      'should report no internet when the cause chain carries DNS wording',
      () {
        final error = DioException(
          requestOptions: RequestOptions(path: Endpoints.authLogin),
          error: const SocketException(
            'Failed host lookup: api.orbit.app',
            osError: OSError('', 11001),
          ),
        );

        expect(
          NetworkExceptionFactory.reasonOf(error),
          NetworkErrorReason.noInternet,
        );
      },
    );

    test(
      'should report the server as unreachable for a refused connection',
      () {
        final error = DioException(
          requestOptions: RequestOptions(path: Endpoints.authLogin),
          error: const SocketException('Connection refused'),
        );

        expect(
          NetworkExceptionFactory.reasonOf(error),
          NetworkErrorReason.serverUnreachable,
        );
      },
    );
  });

  group('of', () {
    test('should carry a 408 status when the reason is a request timeout', () {
      final exception = NetworkExceptionFactory.of(
        NetworkErrorReason.requestTimeout,
        'HTTP 408',
        null,
        null,
      );

      expect(exception.statusCode, 408);
      expect(exception.reason, NetworkErrorReason.requestTimeout);
    });

    test('should carry no status for any other reason', () {
      final exception = NetworkExceptionFactory.of(
        NetworkErrorReason.noInternet,
        'offline',
        null,
        null,
      );

      expect(exception.statusCode, isNull);
    });
  });
}
