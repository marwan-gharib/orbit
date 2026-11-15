import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/interactions/domain/entities/interaction_context.dart';
import 'package:orbit/features/interactions/domain/params/update_interaction_params.dart';
import 'package:orbit/features/interactions/domain/usecases/delete_interaction_usecase.dart';
import 'package:orbit/features/interactions/domain/usecases/update_interaction_usecase.dart';

import '../../interactions_test_mocks.dart';

void main() {
  setUpAll(registerInteractionsFallbacks);

  late MockInteractionsRepository repository;

  setUp(() {
    repository = MockInteractionsRepository();
  });

  test('update passes the params and the context through', () async {
    final updateUseCase = UpdateInteractionUseCase(repository);
    const context = InteractionContext(customerId: 7, opportunityId: 2);
    final params = UpdateInteractionParams(
      interactionId: 8,
      type: InteractionType.meeting,
      subject: 'Sync meeting',
      description: 'Notes',
      interactionDate: DateTime.utc(2025, 6, 1),
    );
    when(
      () => repository.updateInteraction(any(), context: any(named: 'context')),
    ).thenAnswer((_) async => const Success<void>(null));

    final result = await updateUseCase(params, context: context);

    expect(result.isSuccess, isTrue);
    final captured = verify(
      () => repository.updateInteraction(
        captureAny(),
        context: captureAny(named: 'context'),
      ),
    ).captured;
    expect(captured.first, params);
    expect(captured.last, context);
  });

  test('delete passes the id and the context through', () async {
    final deleteUseCase = DeleteInteractionUseCase(repository);
    const context = InteractionContext(customerId: 7);
    when(
      () => repository.deleteInteraction(any(), context: any(named: 'context')),
    ).thenAnswer((_) async => const Success<void>(null));

    final result = await deleteUseCase(8, context: context);

    expect(result.isSuccess, isTrue);
    expect(
      verify(
        () => repository.deleteInteraction(
          captureAny(),
          context: captureAny(named: 'context'),
        ),
      ).captured,
      [8, context],
    );
  });
}
