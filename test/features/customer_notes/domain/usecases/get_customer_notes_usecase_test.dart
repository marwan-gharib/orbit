import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/customer_notes/domain/entities/customer_notes_result_entity.dart';
import 'package:orbit/features/customer_notes/domain/usecases/get_customer_notes_usecase.dart';

import '../../customer_notes_test_mocks.dart';

void main() {
  setUpAll(registerCustomerNotesFallbacks);

  late MockCustomerNotesRepository repository;
  late GetCustomerNotesUseCase useCase;

  setUp(() {
    repository = MockCustomerNotesRepository();
    useCase = GetCustomerNotesUseCase(repository);
  });

  const customerId = 7;

  test('should return the notes result when the repository succeeds', () async {
    // Arrange
    final notesResult = CustomerNotesResult(
      notes: [tCustomerNote(id: 2), tCustomerNote(id: 1)],
      total: 2,
    );
    when(() => repository.getCustomerNotes(customerId))
        .thenAnswer((_) async => Success(notesResult));

    // Act
    final result = await useCase(customerId);

    // Assert
    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, equals(notesResult));
  });

  test('should return the failure when the repository fails', () async {
    // Arrange
    when(() => repository.getCustomerNotes(customerId)).thenAnswer(
      (_) async => const ResultFailure<CustomerNotesResult>(
        ServerFailure(message: 'boom'),
      ),
    );

    // Act
    final result = await useCase(customerId);

    // Assert
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ServerFailure>());
  });

  test('should forward the customer id and call the repository once', () async {
    // Arrange
    when(() => repository.getCustomerNotes(any())).thenAnswer(
      (_) async => Success(const CustomerNotesResult(notes: [], total: 0)),
    );

    // Act
    await useCase(customerId);

    // Assert
    verify(() => repository.getCustomerNotes(customerId)).called(1);
    verifyNoMoreInteractions(repository);
  });
}
