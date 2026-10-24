import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/utils/validators.dart';

void main() {
  group('Validators predicates', () {
    test('should accept well-formed email addresses when trimmed', () {
      expect(Validators.isEmailValid('  adam@orbit.app  '), isTrue);
      expect(Validators.isEmailValid('adam@orbit'), isFalse);
    });

    test('should accept Unicode letters only', () {
      expect(Validators.isLettersOnly('Ahmed'), isTrue);
      expect(Validators.isLettersOnly('محمد'), isTrue);
      expect(Validators.isLettersOnly('Ahmed Ali'), isFalse);
      expect(Validators.isLettersOnly('Ahmed2'), isFalse);
      expect(Validators.isLettersOnly('Ahmed-Ali'), isFalse);
    });

    test('should require one character per password class', () {
      expect(Validators.hasUppercase('Orbit1!'), isTrue);
      expect(Validators.hasUppercase('orbit1!'), isFalse);
      expect(Validators.hasLowercase('Orbit1!'), isTrue);
      expect(Validators.hasLowercase('ORBIT1!'), isFalse);
      expect(Validators.hasDigit('Orbit1!'), isTrue);
      expect(Validators.hasDigit('Orbit!'), isFalse);
    });

    test('should count underscores and symbols as special characters', () {
      expect(Validators.hasSpecialCharacter('Orbit_1'), isTrue);
      expect(Validators.hasSpecialCharacter('Orbit!1'), isTrue);
      expect(Validators.hasSpecialCharacter('Orbit11'), isFalse);
      expect(Validators.hasSpecialCharacter('Orbit 11'), isFalse);
    });

    test('should compare the length against the minimum', () {
      expect(Validators.hasMinLength('12345678', 8), isTrue);
      expect(Validators.hasMinLength('1234567', 8), isFalse);
      expect(Validators.passwordMinLength, 8);
    });
  });

  group('Validators factories', () {
    test('should return the message for a non-letter value', () {
      final validator = Validators.lettersOnly(message: 'letters only');

      expect(validator('  '), isNull);
      expect(validator('Ahmed'), isNull);
      expect(validator('Ahmed 1'), 'letters only');
    });

    test('should read the original value at validation time', () {
      var password = 'Orbit1!';
      final validator = Validators.matches(
        original: () => password,
        message: 'mismatch',
      );

      expect(validator('Orbit1!'), isNull);
      password = 'Orbit2!';
      expect(validator('Orbit1!'), 'mismatch');
    });

    test('should keep the existing password policy behavior', () {
      final validator = Validators.password(message: 'weak');

      expect(validator(''), isNull);
      expect(validator('Orbit1'), 'weak');
      expect(validator('Orbit12'), 'weak');
      expect(validator('Orbit12!'), isNull);
    });
  });
}
