import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/features/customer_notes/domain/entities/customer_note_entity.dart';
import 'package:orbit/features/customer_notes/presentation/widgets/note_thread_content.dart';

import '../../../../core/widgets/harness.dart';
import '../../customer_notes_test_mocks.dart';

void main() {
  Future<void> pumpContent(
    WidgetTester tester, {
    required List<CustomerNote> notes,
    bool isRefreshing = false,
    ValueChanged<CustomerNote>? onEdit,
    ValueChanged<CustomerNote>? onDelete,
    bool settle = true,
  }) => pumpWidget(
    tester,
    SizedBox(
      width: 400,
      child: NoteThreadContent(
        notes: notes,
        isRefreshing: isRefreshing,
        onEdit: onEdit ?? (_) {},
        onDelete: onDelete ?? (_) {},
      ),
    ),
    settle: settle,
  );

  group('NoteThreadContent', () {
    testWidgets('should keep the repository order, newest first', (
      tester,
    ) async {
      final newer = tCustomerNote(id: 2, noteText: 'Newer note');
      final older = tCustomerNote(id: 1, noteText: 'Older note');

      await pumpContent(tester, notes: [newer, older]);

      final newerY = tester.getTopLeft(find.text('Newer note')).dy;
      final olderY = tester.getTopLeft(find.text('Older note')).dy;
      expect(newerY, lessThan(olderY));
    });

    testWidgets('should pass the real entity to onEdit', (tester) async {
      final note = tCustomerNote(id: 9, noteText: 'Editable');
      CustomerNote? edited;

      await pumpContent(
        tester,
        notes: [note],
        onEdit: (value) => edited = value,
      );

      await tester.tap(find.byTooltip('Note actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit note'));
      await tester.pumpAndSettle();

      expect(edited, same(note));
    });

    testWidgets('should show the silent refresh line only while refreshing', (
      tester,
    ) async {
      final note = tCustomerNote();

      await pumpContent(tester, notes: [note], isRefreshing: true);
      expect(find.byType(AnimatedProgressBar), findsOneWidget);

      await pumpContent(tester, notes: [note]);
      expect(find.byType(AnimatedProgressBar), findsNothing);
    });

    testWidgets('should render the edited text after a reload', (tester) async {
      await pumpContent(tester, notes: [tCustomerNote(noteText: 'Before')]);
      await pumpContent(tester, notes: [tCustomerNote(noteText: 'After')]);

      expect(find.text('Before'), findsNothing);
      expect(find.text('After'), findsOneWidget);
    });

    testWidgets('should keep a removed note mounted for its collapse', (
      tester,
    ) async {
      await pumpContent(
        tester,
        notes: [
          tCustomerNote(id: 2, noteText: 'Kept note'),
          tCustomerNote(),
        ],
      );

      await pumpContent(
        tester,
        notes: [tCustomerNote(id: 2, noteText: 'Kept note')],
        settle: false,
      );

      expect(find.text('Follow up next week.'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Follow up next week.'), findsNothing);
      expect(find.text('Kept note'), findsOneWidget);
    });
  });
}
