import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/di/injection_container.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/customer_notes/domain/params/add_customer_note_params.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_note_form/customer_note_form_cubit.dart';
import 'package:orbit/features/customer_notes/presentation/widgets/customer_note_composer.dart';

import '../../../../core/widgets/harness.dart';
import '../../customer_notes_test_mocks.dart';

void main() {
  late MockAddCustomerNoteUseCase addNote;
  late MockUpdateCustomerNoteUseCase updateNote;

  setUpAll(registerCustomerNotesFallbacks);

  setUp(() {
    addNote = MockAddCustomerNoteUseCase();
    updateNote = MockUpdateCustomerNoteUseCase();
    getIt.registerFactory<CustomerNoteFormCubit>(
      () => CustomerNoteFormCubit(addNote, updateNote),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> pumpComposer(WidgetTester tester) => pumpWidget(
    tester,
    Align(
      alignment: Alignment.bottomCenter,
      child: const CustomerNoteComposer(customerId: 7),
    ),
  );

  group('CustomerNoteComposer', () {
    testWidgets('should keep send disabled while the field is empty', (
      tester,
    ) async {
      await pumpComposer(tester);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      verifyNever(() => addNote(any()));
    });

    testWidgets('should send the typed text for the customer', (tester) async {
      when(() => addNote(any())).thenAnswer((_) async => const Success(null));

      await pumpComposer(tester);
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pumpAndSettle();

      verify(
        () => addNote(
          const AddCustomerNoteParams(customerId: 7, noteText: 'Hello'),
        ),
      ).called(1);
    });

    testWidgets('should clear the field and show the sent state on success', (
      tester,
    ) async {
      when(() => addNote(any())).thenAnswer((_) async => const Success(null));

      await pumpComposer(tester);
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsNothing);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should keep the text and show the failure on error', (
      tester,
    ) async {
      when(() => addNote(any())).thenAnswer(
        (_) async => const ResultFailure(ServerFailure(message: 'boom')),
      );

      await pumpComposer(tester);
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
      expect(
        find.text('Something went wrong on our side. Please try again later.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.priority_high), findsOneWidget);
    });

    testWidgets('should block a second send while the first is in flight', (
      tester,
    ) async {
      final pending = Completer<ApiResult<void>>();
      when(() => addNote(any())).thenAnswer((_) => pending.future);

      await pumpComposer(tester);
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      verify(() => addNote(any())).called(1);

      pending.complete(const Success(null));
      await tester.pumpAndSettle();
    });
  });
}
