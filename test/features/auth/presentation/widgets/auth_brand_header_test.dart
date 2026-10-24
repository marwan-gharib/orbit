import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/auth/presentation/widgets/auth_brand_header.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  group('AuthBrandHeader', () {
    testWidgets('should render the app badge, title and subtitle', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const AuthBrandHeader(
          title: 'Welcome back',
          subtitle: 'Sign in to pick up where you left off.',
        ),
      );

      expect(find.byIcon(Icons.radar), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(
        find.text('Sign in to pick up where you left off.'),
        findsOneWidget,
      );
    });
  });
}
