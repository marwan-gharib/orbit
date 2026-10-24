import 'package:flutter/widgets.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/utils/field_rules.dart';
import 'package:orbit/core/utils/validators.dart';

/// Stable ids of the signup password policy, in checklist order.
///
/// The same ids drive the form validator, the live checklist and the strength
/// meter, so the three can never disagree (single rule source).
enum PasswordRuleId { minLength, uppercase, lowercase, digit, special }

bool _isTooShort(String text) =>
    !Validators.hasMinLength(text, Validators.passwordMinLength);

bool _hasNoUppercase(String text) => !Validators.hasUppercase(text);

bool _hasNoLowercase(String text) => !Validators.hasLowercase(text);

bool _hasNoDigit(String text) => !Validators.hasDigit(text);

bool _hasNoSpecialCharacter(String text) =>
    !Validators.hasSpecialCharacter(text);

/// The one signup password policy. Predicates live in [Validators] so the
/// regexes exist once for the whole app.
const FieldRuleSet passwordRules = FieldRuleSet([
  FieldRule(id: PasswordRuleId.minLength, isViolated: _isTooShort),
  FieldRule(id: PasswordRuleId.uppercase, isViolated: _hasNoUppercase),
  FieldRule(id: PasswordRuleId.lowercase, isViolated: _hasNoLowercase),
  FieldRule(id: PasswordRuleId.digit, isViolated: _hasNoDigit),
  FieldRule(id: PasswordRuleId.special, isViolated: _hasNoSpecialCharacter),
]);

/// The first policy rule [text] breaks, or `null` when it satisfies all.
PasswordRuleId? firstViolatedPasswordRule(String text) =>
    passwordRules.firstViolated(text) as PasswordRuleId?;

/// How many policy rules [text] currently satisfies.
int satisfiedPasswordRuleCount(String text) => passwordRules
    .violations(text)
    .values
    .where((isViolated) => !isViolated)
    .length;

/// Coarse strength derived only from the checklist, never from a second
/// scoring model.
enum PasswordStrength { weak, fair, good, strong }

/// Maps checklist progress onto a strength level. With the current five
/// rules: 0–2 weak, 3 fair, 4 good, 5 strong.
PasswordStrength passwordStrengthOf(String text) {
  final satisfied = satisfiedPasswordRuleCount(text);
  final total = passwordRules.rules.length;
  if (satisfied >= total) return PasswordStrength.strong;
  if (satisfied == total - 1) return PasswordStrength.good;
  if (satisfied == total - 2) return PasswordStrength.fair;
  return PasswordStrength.weak;
}

/// Localized copy for the policy ids. The domain and validators stay copy-free;
/// the UI resolves these at build time.
extension PasswordRuleIdCopy on PasswordRuleId {
  /// Short checklist label, e.g. "At least 8 characters".
  String label(BuildContext context) => switch (this) {
    PasswordRuleId.minLength => context.t.auth.signup.requirements.minLength(
      n: Validators.passwordMinLength,
    ),
    PasswordRuleId.uppercase => context.t.auth.signup.requirements.uppercase,
    PasswordRuleId.lowercase => context.t.auth.signup.requirements.lowercase,
    PasswordRuleId.digit => context.t.auth.signup.requirements.digit,
    PasswordRuleId.special => context.t.auth.signup.requirements.special,
  };

  /// Full validator sentence for the first broken rule.
  String errorText(BuildContext context) => switch (this) {
    PasswordRuleId.minLength => context.t.validators.passwordLength,
    PasswordRuleId.uppercase => context.t.validators.passwordUppercase,
    PasswordRuleId.lowercase => context.t.validators.passwordLowercase,
    PasswordRuleId.digit => context.t.validators.passwordDigit,
    PasswordRuleId.special => context.t.validators.passwordSpecial,
  };
}

/// Localized strength label.
extension PasswordStrengthCopy on PasswordStrength {
  String label(BuildContext context) => switch (this) {
    PasswordStrength.weak => context.t.auth.signup.strength.weak,
    PasswordStrength.fair => context.t.auth.signup.strength.fair,
    PasswordStrength.good => context.t.auth.signup.strength.good,
    PasswordStrength.strong => context.t.auth.signup.strength.strong,
  };
}
