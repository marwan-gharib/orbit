import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/features/auth/presentation/widgets/google_sign_in_button.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  group('GoogleSignInButton', () {
    testWidgets('renders Google logo and text when idle', (tester) async {
      var pressed = false;
      await pumpWidget(
        tester,
        GoogleSignInButton(
          onPressed: () => pressed = true,
          isLoading: false,
        ),
      );

      expect(find.byKey(const ValueKey<String>('google_logo_image')), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.byType(GoogleSignInButton));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('shows loading spinner and loading label when isLoading is true', (tester) async {
      var pressed = false;
      await pumpWidget(
        tester,
        GoogleSignInButton(
          onPressed: () => pressed = true,
          isLoading: true,
        ),
        settle: false,
      );
      await tester.pump();

      expect(find.byKey(const ValueKey<String>('google_loading_indicator')), findsOneWidget);
      expect(find.text('Signing in…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('google_logo_image')), findsNothing);

      await tester.tap(find.byType(GoogleSignInButton));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await pumpWidget(
        tester,
        const GoogleSignInButton(
          onPressed: null,
          isLoading: false,
        ),
      );

      expect(find.text('Continue with Google'), findsOneWidget);
      // Tapping should not crash
      await tester.tap(find.byType(GoogleSignInButton));
      await tester.pumpAndSettle();
    });
  });
}
