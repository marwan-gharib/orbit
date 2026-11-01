import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/interactions/domain/params/add_interaction_params.dart';
import 'package:orbit/features/interactions/domain/usecases/add_interaction_usecase.dart';

import '../../interactions_test_mocks.dart';

void main() {
  setUpAll(registerInteractionsFallbacks);

  late MockInteractionsRepository repository;
  late MockCurrentEmployeeIdProvider employeeIdProvider;
  late AddInteractionUseCase useCase;

  setUp(() {
    repository = MockInteractionsRepository();
    employeeIdProvider = MockCurrentEmployeeIdProvider();
    useCase = AddInteractionUseCase(repository, employeeIdProvider);
  });

  final params = AddInteractionParams(
    type: InteractionType.call,
    subject: 'Kickoff call',
    description: 'Intro',
    interactionDate: DateTime.utc(2025, 6, 1),
    customerId: 7,
    opportunityId: 2,
  );

  test(
    'resolves the employee id from the provider and forwards the write',
    () async {
      when(() => employeeIdProvider.currentEmployeeId())
          .thenAnswer((_) async => Success(46));
      when(
        () => repository.addInteraction(
          any(),
          employeeId: any(named: 'employeeId'),
        ),
      ).thenAnswer((_) async => const Success<void>(null));

      final result = await useCase(params);

      expect(result.isSuccess, isTrue);
      final employeeId =
          verify(
                () => repository.addInteraction(
                  captureAny(),
                  employeeId: captureAny(named: 'employeeId'),
                ),
              ).captured.last
              as int;
      expect(employeeId, 46);
    },
  );

  test(
    'propagates an unauthorized provider failure and never writes',
    () async {
      when(() => employeeIdProvider.currentEmployeeId()).thenAnswer(
        (_) async => const ResultFailure<int>(
          UnauthorizedFailure(message: 'no employee id'),
        ),
      );

      final result = await useCase(params);

      expect(result.failureOrNull, isA<UnauthorizedFailure>());
      verifyZeroInteractions(repository);
    },
  );
}
