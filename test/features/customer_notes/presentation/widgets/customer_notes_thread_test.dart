import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/di/injection_container.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/customer_notes/domain/entities/customer_notes_result_entity.dart';
import 'package:orbit/features/customer_notes/domain/params/update_customer_note_params.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_note_delete/customer_note_delete_cubit.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_note_form/customer_note_form_cubit.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_notes_list/customer_notes_list_cubit.dart';
import 'package:orbit/features/customer_notes/presentation/widgets/customer_notes_thread.dart';
import 'package:orbit/features/customer_notes/presentation/widgets/note_edit_sheet.dart';
import 'package:orbit/features/customer_notes/presentation/widgets/note_thread_skeleton.dart';

import '../../../../core/widgets/harness.dart';
import '../../customer_notes_test_mocks.dart';

void main() {
  late MockGetCustomerNotesUseCase getNotes;
  late MockWatchNoteChangesUseCase watchChanges;
  late MockAddCustomerNoteUseCase addNote;
  late MockUpdateCustomerNoteUseCase updateNote;
  late MockDeleteCustomerNoteUseCase deleteNote;

  setUpAll(registerCustomerNotesFallbacks);

  setUp(() {
    getNotes = MockGetCustomerNotesUseCase();
    watchChanges = MockWatchNoteChangesUseCase();
    addNote = MockAddCustomerNoteUseCase();
    updateNote = MockUpdateCustomerNoteUseCase();
    deleteNote = MockDeleteCustomerNoteUseCase();

    when(() => watchChanges()).thenAnswer((_) => const Stream.empty());
    when(() => getNotes(any())).thenAnswer(
      (_) async =>
          Success(CustomerNotesResult(notes: [tCustomerNote()], total: 1)),
    );
    when(() => addNote(any())).thenAnswer((_) async => const Success(null));
    when(() => updateNote(any(), customerId: any(named: 'customerId')))
        .thenAnswer((_) async => const Success(null));
    when(() => deleteNote(any(), customerId: any(named: 'customerId')))
        .thenAnswer((_) async => const Success(null));

    getIt.registerFactory<CustomerNotesListCubit>(
      () => CustomerNotesListCubit(
        getCustomerNotes: getNotes,
        watchNoteChanges: watchChanges,
      ),
    );
    getIt.registerFactory<CustomerNoteFormCubit>(
      () => CustomerNoteFormCubit(addNote, updateNote),
    );
    getIt.registerFactory<CustomerNoteDeleteCubit>(
      () => CustomerNoteDeleteCubit(deleteNote),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> pumpThread(WidgetTester tester, {bool settle = true}) => pumpApp(
    tester,
    surfaceSize: const Size(800, 1000),
    home: const Scaffold(body: CustomerNotesThread(customerId: 7)),
    settle: settle,
  );

  group('CustomerNotesThread', () {
    testWidgets('should show the skeleton, then load the customer notes', (
      tester,
    ) async {
      final pending = Completer<ApiResult<CustomerNotesResult>>();
      when(() => getNotes(7)).thenAnswer((_) => pending.future);

      await pumpThread(tester, settle: false);
      expect(find.byType(NoteThreadSkeleton), findsOneWidget);

      pending.complete(
        Success(CustomerNotesResult(notes: [tCustomerNote()], total: 1)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Follow up next week.'), findsOneWidget);
      verify(() => getNotes(7)).called(1);
    });

    testWidgets('should open the edit sheet prefilled and save the edit', (
      tester,
    ) async {
      await pumpThread(tester);

      await tester.tap(find.byTooltip('Note actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit note'));
      await tester.pumpAndSettle();

      expect(find.byType(NoteEditSheet), findsOneWidget);
      final field = tester.widget<EditableText>(
        find.descendant(
          of: find.byType(NoteEditSheet),
          matching: find.byType(EditableText),
        ),
      );
      expect(field.controller.text, 'Follow up next week.');

      await tester.enterText(find.byType(TextField), 'Edited note');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(
        () => updateNote(
          const UpdateCustomerNoteParams(noteId: 1, noteText: 'Edited note'),
          customerId: 7,
        ),
      ).called(1);
      expect(find.byType(NoteEditSheet), findsNothing);
    });

    testWidgets('should confirm and delete the note', (tester) async {
      await pumpThread(tester);

      await tester.tap(find.byTooltip('Note actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete note'));
      await tester.pumpAndSettle();

      expect(find.text('Delete note?'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(() => deleteNote(1, customerId: 7)).called(1);
    });

    testWidgets('should keep the edit sheet open when the barrier is tapped', (
      tester,
    ) async {
      await pumpThread(tester);

      await tester.tap(find.byTooltip('Note actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit note'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Half typed');
      await tester.pump();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(NoteEditSheet), findsOneWidget);
      expect(find.text('Half typed'), findsOneWidget);
    });

    testWidgets('should keep the delete confirmation open on a barrier tap', (
      tester,
    ) async {
      await pumpThread(tester);

      await tester.tap(find.byTooltip('Note actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete note'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Delete note?'), findsOneWidget);
    });
  });
}
