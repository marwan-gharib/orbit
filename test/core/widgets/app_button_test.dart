import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/widgets/app_button.dart';

import 'harness.dart';

void main() {
  group('AppButton', () {
    testWidgets('should render FilledButton when variant is filled', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const AppButton(label: 'Submit', variant: AppButtonVariant.filled),
      );
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('should render ElevatedButton when variant is elevated', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const AppButton(label: 'Submit', variant: AppButtonVariant.elevated),
      );
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should render OutlinedButton when variant is outlined', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const AppButton(label: 'Submit', variant: AppButtonVariant.outlined),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('should render TextButton when variant is text', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const AppButton(label: 'Submit', variant: AppButtonVariant.text),
      );
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped and enabled', (
      tester,
    ) async {
      var tapped = false;
      await pumpWidget(
        tester,
        AppButton(label: 'Submit', onPressed: () => tapped = true),
      );
      await tester.tap(find.byType(FilledButton));
      expect(tapped, isTrue);
    });

    testWidgets('should not call onPressed when disabled', (tester) async {
      var tapped = false;
      await pumpWidget(
        tester,
        AppButton(
          label: 'Submit',
          // onPressed is null -> disabled
        ),
      );
      await tester.tap(find.byType(FilledButton));
      expect(tapped, isFalse);
    });

    testWidgets('should show loading spinner when isLoading is true', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const AppButton(label: 'Submit', isLoading: true),
        settle: false,
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('should show icon when provided', (tester) async {
      await pumpWidget(
        tester,
        const AppButton(label: 'Submit', icon: Icon(Icons.add)),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
