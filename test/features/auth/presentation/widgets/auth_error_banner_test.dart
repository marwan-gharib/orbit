import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/auth/presentation/widgets/auth_error_banner.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  group('AuthErrorBanner', () {
    testWidgets('should render the title and message', (tester) async {
      await pumpWidget(
        tester,
        const AuthErrorBanner(
          title: "Couldn't sign you in",
          message: 'Check your connection and try again.',
        ),
      );

      expect(find.text("Couldn't sign you in"), findsOneWidget);
      expect(find.text('Check your connection and try again.'), findsOneWidget);
    });

    testWidgets('should announce the banner once through semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpWidget(
        tester,
        const AuthErrorBanner(
          title: "Couldn't sign you in",
          message: 'Check your connection and try again.',
        ),
      );

      expect(
        find.bySemanticsLabel(
          "Couldn't sign you in. Check your connection and try again.",
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
