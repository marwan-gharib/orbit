import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/widgets/app_dialog.dart';
import 'package:orbit/core/widgets/confirm_dialog.dart';

import 'harness.dart';

void main() {
  group('AppDialog widget', () {
    testWidgets('should render AlertDialog with title and content', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const AppDialog(title: Text('Confirm'), content: Text('Are you sure?')),
      );
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
    });

    testWidgets('should render actions when provided', (tester) async {
      await pumpWidget(
        tester,
        AppDialog(
          title: const Text('Confirm'),
          actions: [
            TextButton(onPressed: () {}, child: const Text('Cancel')),
            FilledButton(onPressed: () {}, child: const Text('OK')),
          ],
        ),
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('should render icon when provided', (tester) async {
      await pumpWidget(
        tester,
        const AppDialog(title: Text('Info'), icon: Icon(Icons.info)),
      );
      expect(find.byIcon(Icons.info), findsOneWidget);
    });
  });

  group('ConfirmDialog.show', () {
    testWidgets('should return true when confirm is pressed', (tester) async {
      bool? result;
      await pumpWidget(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await ConfirmDialog.show(
                context: context,
                title: 'Delete',
                message: 'Are you sure?',
                confirmLabel: 'Delete',
                cancelLabel: 'Cancel',
              );
            },
            child: const Text('Open'),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('should return false when cancel is pressed', (tester) async {
      bool? result;
      await pumpWidget(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await ConfirmDialog.show(
                context: context,
                title: 'Delete',
                message: 'Are you sure?',
                confirmLabel: 'Delete',
                cancelLabel: 'Cancel',
              );
            },
            child: const Text('Open'),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('should return false when dismissed by barrier', (
      tester,
    ) async {
      bool? result;
      await pumpWidget(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await ConfirmDialog.show(
                context: context,
                title: 'Delete',
                message: 'Are you sure?',
                confirmLabel: 'Delete',
                cancelLabel: 'Cancel',
              );
            },
            child: const Text('Open'),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10)); // Tap outside dialog
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });
  });
}
