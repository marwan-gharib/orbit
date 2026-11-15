import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/customer_notes/domain/params/add_customer_note_params.dart';
import 'package:orbit/features/customer_notes/domain/usecases/add_customer_note_usecase.dart';

import '../../customer_notes_test_mocks.dart';

void main() {
  setUpAll(registerCustomerNotesFallbacks);

  late MockCustomerNotesRepository repository;
  late AddCustomerNoteUseCase useCase;

  setUp(() {
    repository = MockCustomerNotesRepository();
    useCase = AddCustomerNoteUseCase(repository);
  });

  const params = AddCustomerNoteParams(customerId: 7, noteText: 'Follow up.');

  test(
    'should forward the params and return success when the repository succeeds',
    () async {
      // Arrange
      when(() => repository.addCustomerNote(any()))
          .thenAnswer((_) async => const Success<void>(null));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
      final forwarded =
          verify(() => repository.addCustomerNote(captureAny())).captured.single
              as AddCustomerNoteParams;
      expect(forwarded, equals(params));
    },
  );

  test('should carry only customer id and note text when adding', () async {
    // Arrange — the employee is derived server-side, so the params the use
    // case forwards expose nothing about the signed-in user.
    when(() => repository.addCustomerNote(any()))
        .thenAnswer((_) async => const Success<void>(null));

    // Act
    await useCase(params);

    // Assert
    final forwarded =
        verify(() => repository.addCustomerNote(captureAny())).captured.single
            as AddCustomerNoteParams;
    expect(forwarded.customerId, 7);
    expect(forwarded.noteText, 'Follow up.');
  });

  test('should return the failure when the repository fails', () async {
    // Arrange
    when(() => repository.addCustomerNote(any())).thenAnswer(
      (_) async => const ResultFailure<void>(
        ValidationFailure(message: 'Note is too long.'),
      ),
    );

    // Act
    final result = await useCase(params);

    // Assert
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ValidationFailure>());
  });

  test('should call the repository exactly once', () async {
    // Arrange
    when(() => repository.addCustomerNote(any()))
        .thenAnswer((_) async => const Success<void>(null));

    // Act
    await useCase(params);

    // Assert
    verify(() => repository.addCustomerNote(params)).called(1);
    verifyNoMoreInteractions(repository);
  });
}
