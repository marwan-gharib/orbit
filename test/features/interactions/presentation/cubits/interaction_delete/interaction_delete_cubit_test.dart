import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/interactions/domain/entities/interaction_entity.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_delete/interaction_delete_cubit.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_delete/interaction_delete_state.dart';

import '../../../interactions_test_mocks.dart';

void main() {
  setUpAll(registerInteractionsFallbacks);

  late MockDeleteInteractionUseCase deleteUseCase;
  late InteractionDeleteCubit cubit;

  setUp(() {
    deleteUseCase = MockDeleteInteractionUseCase();
    cubit = InteractionDeleteCubit(deleteUseCase);
    addTearDown(cubit.close);
  });

  test('starts in Initial', () {
    expect(cubit.state, const InteractionDeleteInitial());
  });

  test('delete emits InProgress then Success on success', () async {
    final interaction = Interaction(
      interactionId: 4,
      type: InteractionType.call,
      subject: 'x',
      description: 'y',
      interactionDate: DateTime(2025),
      customerId: 1,
      employeeId: 2,
    );
    when(() => deleteUseCase(any(), context: any(named: 'context')))
        .thenAnswer((_) async => const Success<void>(null));

    await cubit.delete(interaction);

    expect(cubit.state, const InteractionDeleteSuccess(4));
    verify(
      () => deleteUseCase(captureAny(), context: captureAny(named: 'context')),
    );
  });

  test('delete emits InProgress then Failure on failure', () async {
    final interaction = Interaction(
      interactionId: 4,
      type: InteractionType.call,
      subject: 'x',
      description: 'y',
      interactionDate: DateTime(2025),
      customerId: 1,
      employeeId: 2,
    );
    const failure = UnauthorizedFailure(message: 'denied');
    when(() => deleteUseCase(any(), context: any(named: 'context')))
        .thenAnswer((_) async => const ResultFailure<void>(failure));

    await cubit.delete(interaction);

    expect(
      cubit.state,
      isA<InteractionDeleteFailure>()
          .having((s) => s.interactionId, 'interactionId', 4)
          .having((s) => s.failure, 'failure', same(failure)),
    );
  });

  test('delete ignores calls while a delete is in progress', () async {
    final interaction = Interaction(
      interactionId: 4,
      type: InteractionType.call,
      subject: 'x',
      description: 'y',
      interactionDate: DateTime(2025),
      customerId: 1,
      employeeId: 2,
    );
    late Completer<void> completion;
    when(() => deleteUseCase(any(), context: any(named: 'context')))
        .thenAnswer((_) async {
          completion = Completer<void>.sync();
          return completion.future.then((_) => const Success<void>(null));
        });

    cubit.delete(interaction);
    expect(cubit.state, const InteractionDeleteInProgress(4));

    // Second delete while in progress — must be ignored.
    await cubit.delete(interaction);
    verify(() => deleteUseCase(any(), context: any(named: 'context')))
        .called(1);

    completion.complete();
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, const InteractionDeleteSuccess(4));
  });
}
