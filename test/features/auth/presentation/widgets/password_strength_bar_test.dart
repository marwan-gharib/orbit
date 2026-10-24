import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/features/auth/presentation/widgets/password_strength_bar.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  group('PasswordStrengthBar', () {
    testWidgets('should label a weak password and leave the bar empty', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const SizedBox(
          width: 320,
          child: PasswordStrengthBar(password: 'orbit'),
        ),
      );

      expect(find.text('Password strength'), findsOneWidget);
      expect(find.text('Weak'), findsOneWidget);
      final bar = tester.widget<AnimatedProgressBar>(
        find.byType(AnimatedProgressBar),
      );
      expect(bar.progress, closeTo(0.2, 0.0001));
    });

    testWidgets('should label a fair password from the checklist count', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const SizedBox(
          width: 320,
          child: PasswordStrengthBar(password: 'Orbit1'),
        ),
      );

      expect(find.text('Fair'), findsOneWidget);
      final bar = tester.widget<AnimatedProgressBar>(
        find.byType(AnimatedProgressBar),
      );
      expect(bar.progress, closeTo(0.6, 0.0001));
    });

    testWidgets('should label a strong password when every rule passes', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const SizedBox(
          width: 320,
          child: PasswordStrengthBar(password: 'Orbit123!'),
        ),
      );

      expect(find.text('Strong'), findsOneWidget);
      final bar = tester.widget<AnimatedProgressBar>(
        find.byType(AnimatedProgressBar),
      );
      expect(bar.progress, closeTo(1.0, 0.0001));
    });
  });
}
