import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/interactions/domain/entities/interaction_entity.dart';
import 'package:orbit/features/interactions/domain/params/interactions_criteria.dart';
import 'package:orbit/features/interactions/domain/usecases/get_interactions_usecase.dart';

import '../../interactions_test_mocks.dart';

void main() {
  setUpAll(registerInteractionsFallbacks);

  late MockInteractionsRepository repository;
  late GetInteractionsUseCase useCase;

  setUp(() {
    repository = MockInteractionsRepository();
    useCase = GetInteractionsUseCase(repository);
  });

  test(
    'delegates the criteria to the repository and returns its result',
    () async {
      const criteria = InteractionsCriteria(
        searchText: 'meeting',
        customerId: 7,
      );
      final interactions = [tInteraction(id: 9), tInteraction(id: 2)];
      when(() => repository.getInteractions(any()))
          .thenAnswer((_) async => Success<List<Interaction>>(interactions));

      final result = await useCase(criteria);

      expect(result.dataOrNull, interactions);
      final captured = verify(() => repository.getInteractions(captureAny()))
          .captured;
      expect(captured.single, criteria);
    },
  );

  test('propagates the repository failure', () async {
    const failure = UnauthorizedFailure(message: 'nope');
    when(
      () => repository.getInteractions(any()),
    ).thenAnswer((_) async => const ResultFailure<List<Interaction>>(failure));

    final result = await useCase(const InteractionsCriteria());

    expect(result.failureOrNull, failure);
  });
}
