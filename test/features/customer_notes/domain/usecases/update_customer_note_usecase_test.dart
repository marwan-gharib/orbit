import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/customer_notes/domain/params/update_customer_note_params.dart';
import 'package:orbit/features/customer_notes/domain/usecases/update_customer_note_usecase.dart';

import '../../customer_notes_test_mocks.dart';

void main() {
  setUpAll(registerCustomerNotesFallbacks);

  late MockCustomerNotesRepository repository;
  late UpdateCustomerNoteUseCase useCase;

  setUp(() {
    repository = MockCustomerNotesRepository();
    useCase = UpdateCustomerNoteUseCase(repository);
  });

  const params = UpdateCustomerNoteParams(noteId: 3, noteText: 'Rewritten.');

  test('should forward the params and customer id exactly when the repository succeeds', () async {
    // Arrange
    when(
      () => repository.updateCustomerNote(
        any(),
        customerId: any(named: 'customerId'),
      ),
    ).thenAnswer((_) async => const Success<void>(null));

    // Act
    final result = await useCase(params, customerId: 7);

    // Assert
    expect(result.isSuccess, isTrue);
    final captured = verify(
      () => repository.updateCustomerNote(
        captureAny(),
        customerId: captureAny(named: 'customerId'),
      ),
    ).captured;
    expect(captured.first, equals(params));
    expect(captured.last, 7);
  });

  test(
    'should carry only the note id and note text in the forwarded params',
    () async {
      // Arrange — the customer id travels separately and is never serialized.
      when(
        () => repository.updateCustomerNote(
          any(),
          customerId: any(named: 'customerId'),
        ),
      ).thenAnswer((_) async => const Success<void>(null));

      // Act
      await useCase(params, customerId: 7);

      // Assert
      final forwarded =
          verify(
                () => repository.updateCustomerNote(
                  captureAny(),
                  customerId: captureAny(named: 'customerId'),
                ),
              ).captured.first
              as UpdateCustomerNoteParams;
      expect(forwarded.noteId, 3);
      expect(forwarded.noteText, 'Rewritten.');
    },
  );

  test('should return the failure when the repository fails', () async {
    // Arrange
    when(
      () => repository.updateCustomerNote(
        any(),
        customerId: any(named: 'customerId'),
      ),
    ).thenAnswer(
      (_) async => const ResultFailure<void>(NotFoundFailure(message: 'gone')),
    );

    // Act
    final result = await useCase(params, customerId: 7);

    // Assert
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<NotFoundFailure>());
  });

  test('should call the repository exactly once', () async {
    // Arrange
    when(
      () => repository.updateCustomerNote(
        any(),
        customerId: any(named: 'customerId'),
      ),
    ).thenAnswer((_) async => const Success<void>(null));

    // Act
    await useCase(params, customerId: 7);

    // Assert
    verify(() => repository.updateCustomerNote(params, customerId: 7))
        .called(1);
    verifyNoMoreInteractions(repository);
  });
}
