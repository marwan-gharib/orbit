import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/core/widgets/empty_state.dart';

import 'harness.dart';

void main() {
  group('EmptyState', () {
    testWidgets('should render title and icon', (tester) async {
      await pumpWidget(
        tester,
        const EmptyState(title: 'No items', icon: Icons.inbox),
      );
      expect(find.text('No items'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('should render message when provided', (tester) async {
      await pumpWidget(
        tester,
        const EmptyState(
          title: 'No items',
          message: 'Pull to refresh to load items',
        ),
      );
      expect(find.text('Pull to refresh to load items'), findsOneWidget);
    });

    testWidgets('should render primary action button when provided', (
      tester,
    ) async {
      var tapped = false;
      await pumpWidget(
        tester,
        EmptyState(
          title: 'No items',
          primaryAction: (label: 'Refresh', onPressed: () => tapped = true),
        ),
      );
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);

      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });

    testWidgets('should use default icon when not provided', (tester) async {
      await pumpWidget(tester, const EmptyState(title: 'No items'));
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('should not render action button when not provided', (
      tester,
    ) async {
      await pumpWidget(tester, const EmptyState(title: 'No items'));
      expect(find.byType(AppButton), findsNothing);
    });
  });
}
