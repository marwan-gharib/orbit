import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_note_delete/customer_note_delete_cubit.dart';
import 'package:orbit/features/customer_notes/presentation/widgets/note_delete_dialog.dart';

import '../../../../core/widgets/harness.dart';
import '../../customer_notes_test_mocks.dart';

void main() {
  late MockDeleteCustomerNoteUseCase deleteNote;
  late CustomerNoteDeleteCubit deleteCubit;

  setUpAll(registerCustomerNotesFallbacks);

  setUp(() {
    deleteNote = MockDeleteCustomerNoteUseCase();
    deleteCubit = CustomerNoteDeleteCubit(deleteNote);
  });

  tearDown(() async {
    await deleteCubit.close();
  });

  Future<void> pumpDialog(
    WidgetTester tester, {
    required VoidCallback onConfirm,
    bool settle = true,
  }) => pumpWidget(
    tester,
    BlocProvider<CustomerNoteDeleteCubit>.value(
      value: deleteCubit,
      child: NoteDeleteDialog(onConfirm: onConfirm),
    ),
    settle: settle,
  );

  group('NoteDeleteDialog', () {
    testWidgets('should ask for confirmation before deleting', (tester) async {
      var confirmed = 0;
      await pumpDialog(tester, onConfirm: () => confirmed++);

      expect(find.text('Delete note?'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(confirmed, 1);
    });

    testWidgets('should disable the actions while deleting', (tester) async {
      final pending = Completer<ApiResult<void>>();
      when(() => deleteNote(1, customerId: 7))
          .thenAnswer((_) => pending.future);
      unawaited(deleteCubit.delete(tCustomerNote()));

      var confirmed = 0;
      await pumpDialog(tester, onConfirm: () => confirmed++, settle: false);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final deleteButton = tester.widget<AppButton>(
        find.byWidgetPredicate(
          (widget) => widget is AppButton && widget.destructive,
        ),
      );
      expect(deleteButton.onPressed, isNull);

      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is AppButton && widget.destructive,
        ),
      );
      await tester.pump();
      expect(confirmed, 0);
    });

    testWidgets('should show the failure and keep the dialog usable', (
      tester,
    ) async {
      when(() => deleteNote(1, customerId: 7)).thenAnswer(
        (_) async => const ResultFailure(ServerFailure(message: 'boom')),
      );
      await deleteCubit.delete(tCustomerNote());

      await pumpDialog(tester, onConfirm: () {});

      expect(
        find.text('Something went wrong on our side. Please try again later.'),
        findsOneWidget,
      );
      expect(find.text('Delete'), findsOneWidget);
    });
  });
}
