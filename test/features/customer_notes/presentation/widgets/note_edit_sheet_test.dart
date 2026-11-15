import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/features/customer_notes/domain/params/update_customer_note_params.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_note_form/customer_note_form_cubit.dart';
import 'package:orbit/features/customer_notes/presentation/widgets/note_edit_sheet.dart';

import '../../../../core/widgets/harness.dart';
import '../../customer_notes_test_mocks.dart';

void main() {
  late MockAddCustomerNoteUseCase addNote;
  late MockUpdateCustomerNoteUseCase updateNote;
  late CustomerNoteFormCubit formCubit;

  setUpAll(registerCustomerNotesFallbacks);

  setUp(() {
    addNote = MockAddCustomerNoteUseCase();
    updateNote = MockUpdateCustomerNoteUseCase();
    formCubit = CustomerNoteFormCubit(addNote, updateNote)
      ..startEdit(tCustomerNote(id: 4, noteText: 'Original note'));
  });

  tearDown(() async {
    await formCubit.close();
  });

  Future<void> pumpSheet(WidgetTester tester) => pumpWidget(
    tester,
    BlocProvider<CustomerNoteFormCubit>.value(
      value: formCubit,
      child: const NoteEditSheet(noteId: 4, initialText: 'Original note'),
    ),
  );

  AppButton saveButton(WidgetTester tester) =>
      tester.widget<AppButton>(find.widgetWithText(AppButton, 'Save'));

  group('NoteEditSheet', () {
    testWidgets('should prefill the current text', (tester) async {
      await pumpSheet(tester);

      expect(find.text('Original note'), findsOneWidget);
      expect(find.text('Edit note'), findsOneWidget);
    });

    testWidgets('should keep Save disabled until the text changes', (
      tester,
    ) async {
      await pumpSheet(tester);

      expect(saveButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'Original note updated');
      await tester.pump();

      expect(saveButton(tester).onPressed, isNotNull);
    });

    testWidgets('should submit the edited text with the customer id', (
      tester,
    ) async {
      when(() => updateNote(any(), customerId: any(named: 'customerId')))
          .thenAnswer((_) async => const Success<void>(null));

      await pumpSheet(tester);
      await tester.enterText(find.byType(TextField), 'Updated note');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(
        () => updateNote(
          const UpdateCustomerNoteParams(noteId: 4, noteText: 'Updated note'),
          customerId: 7,
        ),
      ).called(1);
    });

    testWidgets('should ask before discarding unsaved edits', (tester) async {
      await pumpSheet(tester);
      await tester.enterText(find.byType(TextField), 'Half typed');
      await tester.pump();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsOneWidget);

      await tester.tap(find.text('Cancel').last);
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsNothing);
      expect(find.byType(NoteEditSheet), findsOneWidget);
    });
  });
}
