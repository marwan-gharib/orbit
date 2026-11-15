import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/errors/error_mapper.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/failures.dart';

void main() {
  group('ErrorMapper.toFailure', () {
    test('should map a network exception with its reason and copy', () {
      final failure = ErrorMapper.toFailure(
        const NetworkException(
          message: 'offline',
          reason: NetworkErrorReason.noInternet,
        ),
      );

      expect(failure, isA<NetworkFailure>());
      final network = failure as NetworkFailure;
      expect(network.reason, NetworkErrorReason.noInternet);
      expect(
        network.message,
        "You're offline. Check your internet connection and try again.",
      );
    });

    test('should map a validation exception and keep safe field messages', () {
      final failure = ErrorMapper.toFailure(
        const ValidationException(
          message: 'validation failed',
          statusCode: 422,
          fieldErrors: {
            ApiKeys.titleKey: ['Title is required', 'SQL constraint violated'],
          },
        ),
      );

      expect(failure, isA<ValidationFailure>());
      final validation = failure as ValidationFailure;
      expect(validation.fieldErrors, {
        ApiKeys.titleKey: ['Title is required'],
      });
    });

    test('should pass a safe backend message on 400 but drop it on 401', () {
      final on400 = ErrorMapper.toFailure(
        const ClientErrorException(
          message: 'bad request',
          statusCode: 400,
          serverMessage: 'The title is too long',
        ),
      ) as RequestFailure;
      final on401 = ErrorMapper.toFailure(
        const UnauthorizedException(
          message: 'unauthorized',
          statusCode: 401,
          serverMessage: 'The title is too long',
        ),
      ) as UnauthorizedFailure;

      expect(on400.message, 'The title is too long');
      expect(on401.message, contains('sign in again'));
    });

    test('should map 503 with a retry-after wait phrase', () {
      final failure = ErrorMapper.toFailure(
        const ServerErrorException(
          message: 'unavailable',
          statusCode: 503,
          retryAfter: Duration(seconds: 90),
        ),
      ) as ServerFailure;

      expect(failure.message, contains('2 minutes'));
      expect(failure.retryAfter, const Duration(seconds: 90));
    });

    test('should map rate limiting with its copy and wait phrase', () {
      final failure = ErrorMapper.toFailure(
        const RateLimitException(
          message: 'rate limited',
          statusCode: 429,
          retryAfter: Duration(seconds: 45),
        ),
      ) as RateLimitFailure;

      expect(failure.message, contains('45 seconds'));
    });

    test('should map the remaining exception kinds to their failure type', () {
      final cancelled = ErrorMapper.toFailure(
        const RequestCancelledException(message: 'cancelled'),
      );
      final forbidden = ErrorMapper.toFailure(
        const ForbiddenException(message: 'forbidden'),
      );
      final gone = ErrorMapper.toFailure(
        const NotFoundException(message: 'gone', statusCode: 410),
      ) as NotFoundFailure;
      final parsing = ErrorMapper.toFailure(
        const ParsingException(message: 'bad json'),
      );
      final cache = ErrorMapper.toFailure(
        const CacheException(message: 'cache'),
      );
      final storage = ErrorMapper.toFailure(
        const SecureStorageException(message: 'secure'),
      );
      final unknown = ErrorMapper.toFailure(
        const UnknownException(message: 'unknown'),
      );

      expect(cancelled, isA<CancelledFailure>());
      expect(forbidden, isA<ForbiddenFailure>());
      expect(gone.message, 'This is no longer available.');
      expect(parsing, isA<ParsingFailure>());
      expect(cache, isA<CacheFailure>());
      expect(storage, isA<StorageFailure>());
      expect(unknown, isA<UnknownFailure>());
    });

    test('should map any non-AppException error through the Dio handler', () {
      final failure = ErrorMapper.toFailure(FormatException('bad body'));

      expect(failure, isA<Failure>());
      expect(failure.message, isNotEmpty);
    });

    test('should never throw, even when handed a crashing error', () {
      final failure = ErrorMapper.toFailure(_ThrowingError());

      expect(failure, isA<UnknownFailure>());
      expect(failure.message, isNotEmpty);
    });
  });
}

class _ThrowingError extends Error {
  @override
  String toString() => throw StateError('boom');
}
