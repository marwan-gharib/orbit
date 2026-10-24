import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/utils/field_rules.dart';

enum _RuleId { minLength, hasDigit }

const _rules = FieldRuleSet([
  FieldRule(id: _RuleId.minLength, isViolated: _shorterThanThree),
  FieldRule(id: _RuleId.hasDigit, isViolated: _hasNoDigit),
]);

bool _shorterThanThree(String text) => text.length < 3;

bool _hasNoDigit(String text) => !text.contains(RegExp('[0-9]'));

void main() {
  group('FieldRuleSet', () {
    test('should return null when every rule passes', () {
      expect(_rules.firstViolated('abc1'), isNull);
    });

    test('should return the first violated rule in order', () {
      expect(_rules.firstViolated('a'), _RuleId.minLength);
      expect(_rules.firstViolated('abc'), _RuleId.hasDigit);
    });

    test('should report every rule state keyed by id', () {
      expect(_rules.violations('a1'), {
        _RuleId.minLength: true,
        _RuleId.hasDigit: false,
      });
      expect(_rules.violations('abc'), {
        _RuleId.minLength: false,
        _RuleId.hasDigit: true,
      });
    });

    test('should expose an empty rule list when constructed empty', () {
      const empty = FieldRuleSet([]);

      expect(empty.firstViolated('anything'), isNull);
      expect(empty.violations('anything'), isEmpty);
    });
  });
}
