import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/auth/presentation/widgets/password_checklist.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  group('PasswordChecklist', () {
    testWidgets('should show every requirement unmet for an empty password', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const SizedBox(width: 320, child: PasswordChecklist(password: '')),
      );

      expect(find.text('Your password needs'), findsOneWidget);
      expect(find.text('At least 8 characters'), findsOneWidget);
      expect(find.text('One special character'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(5));
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('should mark every rule when the password satisfies all', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const SizedBox(
          width: 320,
          child: PasswordChecklist(password: 'Orbit123!'),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsNWidgets(5));
      expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
    });

    testWidgets('should mark only the satisfied rules', (tester) async {
      await pumpWidget(
        tester,
        const SizedBox(width: 320, child: PasswordChecklist(password: 'orbit')),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(4));
    });
  });
}
