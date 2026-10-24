import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/auth/presentation/widgets/auth_navigation_link.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  group('AuthNavigationLink', () {
    testWidgets('should render the prompt and action and call onTap once', (
      tester,
    ) async {
      var taps = 0;
      await pumpWidget(
        tester,
        AuthNavigationLink(
          prompt: 'New to Orbit?',
          action: 'Create an account',
          onTap: () => taps++,
        ),
      );

      expect(find.text('New to Orbit?'), findsOneWidget);
      expect(find.text('Create an account'), findsOneWidget);

      await tester.tap(find.text('Create an account'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('should announce the whole link as one button', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpWidget(
        tester,
        AuthNavigationLink(
          prompt: 'Already have an account?',
          action: 'Sign in',
          onTap: () {},
        ),
      );

      expect(
        find.bySemanticsLabel('Already have an account? Sign in'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
