import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/widgets/empty_state.dart';
import 'package:orbit/core/widgets/error_state.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_notes_list/customer_notes_list_state.dart';
import 'package:orbit/features/customer_notes/presentation/widgets/customer_notes_view.dart';
import 'package:orbit/features/customer_notes/presentation/widgets/note_thread_skeleton.dart';

import '../../../../core/widgets/harness.dart';
import '../../customer_notes_test_mocks.dart';

void main() {
  Future<void> pumpView(
    WidgetTester tester,
    CustomerNotesListState state, {
    VoidCallback? onRetry,
  }) => pumpWidget(
    tester,
    SizedBox(
      width: 400,
      child: CustomerNotesView(
        state: state,
        onRetry: onRetry ?? () {},
        onEdit: (_) {},
        onDelete: (_) {},
      ),
    ),
  );

  group('CustomerNotesView', () {
    testWidgets('should show the skeleton while loading', (tester) async {
      await pumpView(tester, CustomerNotesListLoading());

      expect(find.byType(NoteThreadSkeleton), findsOneWidget);
    });

    testWidgets('should show the plural count and the notes', (tester) async {
      await pumpView(
        tester,
        CustomerNotesListSuccess(
          notes: [
            tCustomerNote(id: 1, noteText: 'First'),
            tCustomerNote(id: 2, noteText: 'Second'),
          ],
          total: 2,
        ),
      );

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('2 notes'), findsOneWidget);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('should use singular copy for a single note', (tester) async {
      await pumpView(
        tester,
        CustomerNotesListSuccess(notes: [tCustomerNote()], total: 1),
      );

      expect(find.text('1 note'), findsOneWidget);
    });

    testWidgets('should show the empty state with a zero count', (
      tester,
    ) async {
      await pumpView(tester, const CustomerNotesListEmpty());

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('0 notes'), findsOneWidget);
    });

    testWidgets('should show the localized failure and retry', (tester) async {
      var retries = 0;
      await pumpView(
        tester,
        const CustomerNotesListError(ServerFailure(message: 'boom')),
        onRetry: () => retries++,
      );

      expect(find.byType(ErrorState), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(retries, 1);
    });

    testWidgets('should show a dismissible refresh notice after a failed '
        'silent refresh', (tester) async {
      await pumpView(
        tester,
        CustomerNotesListSuccess(
          notes: [tCustomerNote()],
          total: 1,
          refreshFailure: const ServerFailure(message: 'boom'),
        ),
      );

      expect(
        find.text("Couldn't refresh notes. Showing the last loaded notes."),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Dismiss'));
      await tester.pumpAndSettle();

      expect(
        find.text("Couldn't refresh notes. Showing the last loaded notes."),
        findsNothing,
      );
      expect(find.text('Follow up next week.'), findsOneWidget);
    });
  });
}
