import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/features/auth/presentation/mappers/signup_field_errors_mapper.dart';

void main() {
  group('mappedSignupFieldErrors', () {
    test('should keep the first message of each known field', () {
      const failure = ValidationFailure(
        message: 'validation',
        fieldErrors: {
          ApiKeys.firstNameKey: ['Taken', 'Second message'],
          ApiKeys.workEmailKey: ['Already registered'],
        },
      );

      expect(mappedSignupFieldErrors(failure), {
        ApiKeys.firstNameKey: 'Taken',
        ApiKeys.workEmailKey: 'Already registered',
      });
    });

    test('should drop unknown fields and empty message lists', () {
      const failure = ValidationFailure(
        message: 'validation',
        fieldErrors: {
          ApiKeys.roleKey: ['Unknown slot'],
          ApiKeys.passwordKey: [],
        },
      );

      expect(mappedSignupFieldErrors(failure), isEmpty);
    });

    test('should return nothing for a non-validation failure', () {
      const failure = NetworkFailure(
        message: 'offline',
        reason: NetworkErrorReason.noInternet,
      );

      expect(mappedSignupFieldErrors(failure), isEmpty);
    });
  });

  group('signupFailureHasUnmappedErrors', () {
    test('should be false when every field has an inline slot', () {
      const failure = ValidationFailure(
        message: 'validation',
        fieldErrors: {
          ApiKeys.firstNameKey: ['Taken'],
          ApiKeys.passwordKey: ['Too weak'],
        },
      );

      expect(signupFailureHasUnmappedErrors(failure), isFalse);
    });

    test('should be true for an unknown field, an empty map or no fields', () {
      expect(
        signupFailureHasUnmappedErrors(
          const ValidationFailure(
            message: 'validation',
            fieldErrors: {
              ApiKeys.roleKey: ['Unknown slot'],
            },
          ),
        ),
        isTrue,
      );
      expect(
        signupFailureHasUnmappedErrors(
          const ValidationFailure(message: 'validation'),
        ),
        isTrue,
      );
      expect(
        signupFailureHasUnmappedErrors(
          const NetworkFailure(
            message: 'offline',
            reason: NetworkErrorReason.noInternet,
          ),
        ),
        isTrue,
      );
    });
  });
}
