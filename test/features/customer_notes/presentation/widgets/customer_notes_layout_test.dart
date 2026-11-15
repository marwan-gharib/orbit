import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/customer_notes/presentation/cubits/customer_notes_list/customer_notes_list_state.dart';
import 'package:orbit/features/customer_notes/presentation/widgets/customer_notes_view.dart';

import '../../../../core/widgets/harness.dart';
import '../../customer_notes_test_mocks.dart';

void main() {
  final notes = [
    tCustomerNote(
      id: 3,
      noteText:
          'Reviewed the renewal timeline with the customer and agreed to '
          'send a revised proposal before the end of the month.',
    ),
    tCustomerNote(id: 2, noteText: 'Short follow-up note.'),
    tCustomerNote(id: 1, noteText: 'First note on the account.'),
  ];

  Future<void> pumpView(
    WidgetTester tester, {
    required Size surfaceSize,
    required double textScaleFactor,
  }) => pumpApp(
    tester,
    surfaceSize: surfaceSize,
    textScaleFactor: textScaleFactor,
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomerNotesView(
            state: CustomerNotesListSuccess(notes: notes, total: notes.length),
            onRetry: () {},
            onEdit: (_) {},
            onDelete: (_) {},
          ),
        ),
      ),
    ),
  );

  group('CustomerNotesView layout', () {
    testWidgets('should not overflow a 360x640 phone at 1.5 text scale', (
      tester,
    ) async {
      await pumpView(
        tester,
        surfaceSize: const Size(360, 640),
        textScaleFactor: 1.5,
      );

      expect(tester.takeException(), isNull);
      expect(find.text('3 notes'), findsOneWidget);
    });

    testWidgets('should not overflow a tablet width at 1.5 text scale', (
      tester,
    ) async {
      await pumpView(
        tester,
        surfaceSize: const Size(800, 1000),
        textScaleFactor: 1.5,
      );

      expect(tester.takeException(), isNull);
    });
  });
}
