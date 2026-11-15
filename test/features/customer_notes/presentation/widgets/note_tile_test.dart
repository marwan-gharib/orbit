import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/customer_notes/presentation/mappers/customer_note_mapper.dart';
import 'package:orbit/features/customer_notes/presentation/widgets/note_tile.dart';

import '../../../../core/widgets/harness.dart';
import '../../customer_notes_test_mocks.dart';

void main() {
  Future<void> pumpTile(
    WidgetTester tester, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) => pumpWidget(
    tester,
    SizedBox(
      width: 360,
      child: NoteTile(
        note: tCustomerNote().toViewModel(),
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    ),
  );

  group('NoteTile', () {
    testWidgets('should show the author, initials and note text', (
      tester,
    ) async {
      await pumpTile(tester, onEdit: () {}, onDelete: () {});

      expect(find.text('Omar Mohammed'), findsOneWidget);
      expect(find.text('OM'), findsOneWidget);
      expect(find.text('Follow up next week.'), findsOneWidget);
    });

    testWidgets('should open the overflow menu with Edit and Delete', (
      tester,
    ) async {
      await pumpTile(tester, onEdit: () {}, onDelete: () {});

      await tester.tap(find.byTooltip('Note actions'));
      await tester.pumpAndSettle();

      expect(find.text('Edit note'), findsOneWidget);
      expect(find.text('Delete note'), findsOneWidget);
    });

    testWidgets('should call onEdit when Edit is chosen', (tester) async {
      var edits = 0;
      await pumpTile(tester, onEdit: () => edits++, onDelete: () {});

      await tester.tap(find.byTooltip('Note actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit note'));
      await tester.pumpAndSettle();

      expect(edits, 1);
    });

    testWidgets('should call onDelete when Delete is chosen', (tester) async {
      var deletes = 0;
      await pumpTile(tester, onEdit: () {}, onDelete: () => deletes++);

      await tester.tap(find.byTooltip('Note actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete note'));
      await tester.pumpAndSettle();

      expect(deletes, 1);
    });
  });
}
