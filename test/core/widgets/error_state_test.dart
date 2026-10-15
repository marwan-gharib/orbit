import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/core/widgets/error_state.dart';

import 'harness.dart';

void main() {
  group('ErrorState', () {
    testWidgets('should render message and icon', (tester) async {
      await pumpWidget(
        tester,
        const ErrorState(message: 'Something went wrong', icon: Icons.error),
      );
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should render title when provided', (tester) async {
      await pumpWidget(
        tester,
        const ErrorState(title: 'Error', message: 'Something went wrong'),
      );
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('should render retry action button when provided', (
      tester,
    ) async {
      var tapped = false;
      await pumpWidget(
        tester,
        ErrorState(
          message: 'Something went wrong',
          retryAction: (label: 'Retry', onPressed: () => tapped = true),
        ),
      );
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });

    testWidgets('should use default icon when not provided', (tester) async {
      await pumpWidget(
        tester,
        const ErrorState(message: 'Something went wrong'),
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should not render action button when not provided', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const ErrorState(message: 'Something went wrong'),
      );
      expect(find.byType(AppButton), findsNothing);
    });
  });
}
