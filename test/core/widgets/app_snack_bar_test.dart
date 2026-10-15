import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/animations/animations.dart';

import 'harness.dart';

void main() {
  group('AppSnackbar', () {
    testWidgets('should show snackbar with message and type', (tester) async {
      await pumpWidget(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              AppSnackbar.show(
                context,
                message: 'Item saved',
                type: AppSnackbarType.success,
              );
            },
            child: const Text('Show'),
          ),
        ),
      );
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Item saved'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('should show error type with error icon', (tester) async {
      await pumpWidget(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              AppSnackbar.show(
                context,
                message: 'Error occurred',
                type: AppSnackbarType.error,
              );
            },
            child: const Text('Show'),
          ),
        ),
      );
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should show warning type with warning icon', (tester) async {
      await pumpWidget(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              AppSnackbar.show(
                context,
                message: 'Warning message',
                type: AppSnackbarType.warning,
              );
            },
            child: const Text('Show'),
          ),
        ),
      );
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });

    testWidgets('should show info type with info icon', (tester) async {
      await pumpWidget(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              AppSnackbar.show(
                context,
                message: 'Info message',
                type: AppSnackbarType.info,
              );
            },
            child: const Text('Show'),
          ),
        ),
      );
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('should execute action callback when action is pressed', (
      tester,
    ) async {
      var actionTapped = false;
      await pumpWidget(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              AppSnackbar.show(
                context,
                message: 'Item deleted',
                action: (label: 'Undo', onPressed: () => actionTapped = true),
              );
            },
            child: const Text('Show'),
          ),
        ),
      );
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(actionTapped, isTrue);
    });

    testWidgets('should return actionInvoked when action is pressed', (
      tester,
    ) async {
      AppSnackbarResult? result;
      await pumpWidget(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await AppSnackbar.show(
                context,
                message: 'Item deleted',
                action: (label: 'Undo', onPressed: () {}),
              );
            },
            child: const Text('Show'),
          ),
        ),
      );
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(result, AppSnackbarResult.actionInvoked);
    });
  });
}
