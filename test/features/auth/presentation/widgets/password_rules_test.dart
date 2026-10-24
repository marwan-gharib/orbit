import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/auth/presentation/widgets/password_rules.dart';

void main() {
  group('firstViolatedPasswordRule', () {
    test('should report rules in checklist order', () {
      expect(firstViolatedPasswordRule(''), PasswordRuleId.minLength);
      expect(firstViolatedPasswordRule('Orbit1'), PasswordRuleId.minLength);
      expect(firstViolatedPasswordRule('orbit123'), PasswordRuleId.uppercase);
      expect(firstViolatedPasswordRule('ORBIT123'), PasswordRuleId.lowercase);
      expect(firstViolatedPasswordRule('Orbitabc'), PasswordRuleId.digit);
      expect(firstViolatedPasswordRule('Orbit123'), PasswordRuleId.special);
      expect(firstViolatedPasswordRule('Orbit123!'), isNull);
    });
  });

  group('satisfiedPasswordRuleCount', () {
    test('should count every satisfied rule', () {
      expect(satisfiedPasswordRuleCount(''), 0);
      expect(satisfiedPasswordRuleCount('Orbit1'), 3);
      expect(satisfiedPasswordRuleCount('Orbit123!'), 5);
    });
  });

  group('passwordStrengthOf', () {
    test('should follow the checklist count', () {
      expect(passwordStrengthOf(''), PasswordStrength.weak);
      expect(passwordStrengthOf('orbit'), PasswordStrength.weak);
      expect(passwordStrengthOf('Orbit1'), PasswordStrength.fair);
      expect(passwordStrengthOf('Orbit123'), PasswordStrength.good);
      expect(passwordStrengthOf('Orbit123!'), PasswordStrength.strong);
    });
  });
}
