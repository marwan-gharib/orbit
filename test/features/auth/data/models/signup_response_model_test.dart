import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/auth/data/models/signup_response_model.dart';
import 'package:orbit/features/auth/domain/entities/signup_result_entity.dart';

void main() {
  group('SignupResponseModel.fromJson', () {
    test('should map the echo fields from their wire keys', () {
      final model = SignupResponseModel.fromJson(const {
        ApiKeys.firstNameKey: 'Adam',
        ApiKeys.lastNameKey: 'Orbit',
        ApiKeys.emailKey: 'adam@orbit.app',
      });

      expect(model.firstName, 'Adam');
      expect(model.lastName, 'Orbit');
      expect(model.email, 'adam@orbit.app');
    });

    test('should throw when a required key is missing', () {
      expect(
        () => SignupResponseModel.fromJson(const {
          ApiKeys.firstNameKey: 'Adam',
          ApiKeys.lastNameKey: 'Orbit',
          ApiKeys.workEmailKey: 'ignored-key-on-response',
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('SignupResponseModel.toEntity', () {
    test('should map field by field', () {
      final entity = SignupResponseModel.fromJson(const {
        ApiKeys.firstNameKey: 'Adam',
        ApiKeys.lastNameKey: 'Orbit',
        ApiKeys.emailKey: 'adam@orbit.app',
      }).toEntity();

      expect(entity, isA<SignupResult>());
      expect(entity.firstName, 'Adam');
      expect(entity.lastName, 'Orbit');
      expect(entity.email, 'adam@orbit.app');
    });
  });
}
