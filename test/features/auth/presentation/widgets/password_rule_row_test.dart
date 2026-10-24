import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/auth/presentation/widgets/password_rule_row.dart';
import 'package:orbit/features/auth/presentation/widgets/password_rules.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  group('PasswordRuleRow', () {
    testWidgets('should leave a violated rule unchecked without strike', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const PasswordRuleRow(rule: PasswordRuleId.minLength, satisfied: false),
      );

      final label = PasswordRuleId.minLength.label(
        tester.element(find.byType(PasswordRuleRow)),
      );
      expect(find.text(label), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(
        tester.widget<Text>(find.text(label)).style?.decoration,
        isNot(TextDecoration.lineThrough),
      );
    });

    testWidgets('should strike and check a satisfied rule', (tester) async {
      await pumpWidget(
        tester,
        const PasswordRuleRow(rule: PasswordRuleId.digit, satisfied: true),
      );

      final label = PasswordRuleId.digit.label(
        tester.element(find.byType(PasswordRuleRow)),
      );
      expect(find.text(label), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
      expect(
        tester.widget<Text>(find.text(label)).style?.decoration,
        TextDecoration.lineThrough,
      );
    });

    testWidgets(
      'should announce the rule and whether it is met through semantics',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpWidget(
          tester,
          const PasswordRuleRow(rule: PasswordRuleId.special, satisfied: true),
        );

        expect(
          find.bySemanticsLabel(RegExp('One special character, Met')),
          findsOneWidget,
        );
        handle.dispose();
      },
    );
  });
}
