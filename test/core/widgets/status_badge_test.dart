import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/widgets/status_badge.dart';

import 'harness.dart';

void main() {
  group('StatusBadge', () {
    testWidgets('should render with success status colors', (tester) async {
      await pumpWidget(
        tester,
        const StatusBadge(label: 'Success', status: AppStatus.success),
      );
      expect(find.text('Success'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should render with warning status colors', (tester) async {
      await pumpWidget(
        tester,
        const StatusBadge(label: 'Warning', status: AppStatus.warning),
      );
      expect(find.text('Warning'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('should render with error status colors', (tester) async {
      await pumpWidget(
        tester,
        const StatusBadge(label: 'Error', status: AppStatus.error),
      );
      expect(find.text('Error'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should render with info status colors', (tester) async {
      await pumpWidget(
        tester,
        const StatusBadge(label: 'Info', status: AppStatus.info),
      );
      expect(find.text('Info'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('should render with neutral status colors', (tester) async {
      await pumpWidget(
        tester,
        const StatusBadge(label: 'Neutral', status: AppStatus.neutral),
      );
      expect(find.text('Neutral'), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
    });

    testWidgets('should use custom icon when provided', (tester) async {
      await pumpWidget(
        tester,
        const StatusBadge(
          label: 'Custom',
          status: AppStatus.success,
          icon: Icons.star,
        ),
      );
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });
  });
}
