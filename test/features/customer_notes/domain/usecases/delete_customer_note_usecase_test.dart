import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/customer_notes/domain/usecases/delete_customer_note_usecase.dart';

import '../../customer_notes_test_mocks.dart';

void main() {
  setUpAll(registerCustomerNotesFallbacks);

  late MockCustomerNotesRepository repository;
  late DeleteCustomerNoteUseCase useCase;

  setUp(() {
    repository = MockCustomerNotesRepository();
    useCase = DeleteCustomerNoteUseCase(repository);
  });

  test('should forward the note id and customer id exactly when the repository succeeds', () async {
    // Arrange
    when(
      () => repository.deleteCustomerNote(
        any(),
        customerId: any(named: 'customerId'),
      ),
    ).thenAnswer((_) async => const Success<void>(null));

    // Act
    final result = await useCase(3, customerId: 7);

    // Assert
    expect(result.isSuccess, isTrue);
    final captured = verify(
      () => repository.deleteCustomerNote(
        captureAny(),
        customerId: captureAny(named: 'customerId'),
      ),
    ).captured;
    expect(captured.first, 3);
    expect(captured.last, 7);
  });

  test('should return the failure when the repository fails', () async {
    // Arrange
    when(
      () => repository.deleteCustomerNote(
        any(),
        customerId: any(named: 'customerId'),
      ),
    ).thenAnswer(
      (_) async => const ResultFailure<void>(NotFoundFailure(message: 'gone')),
    );

    // Act
    final result = await useCase(3, customerId: 7);

    // Assert
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<NotFoundFailure>());
  });

  test('should call the repository exactly once', () async {
    // Arrange
    when(
      () => repository.deleteCustomerNote(
        any(),
        customerId: any(named: 'customerId'),
      ),
    ).thenAnswer((_) async => const Success<void>(null));

    // Act
    await useCase(3, customerId: 7);

    // Assert
    verify(() => repository.deleteCustomerNote(3, customerId: 7)).called(1);
    verifyNoMoreInteractions(repository);
  });
}
