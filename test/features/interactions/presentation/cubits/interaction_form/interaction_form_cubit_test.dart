import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/interactions/domain/entities/interaction_entity.dart';
import 'package:orbit/features/interactions/domain/params/add_interaction_params.dart';
import 'package:orbit/features/interactions/domain/params/update_interaction_params.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_form/interaction_form_cubit.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_form/interaction_form_state.dart';

import '../../../interactions_test_mocks.dart';

void main() {
  setUpAll(registerInteractionsFallbacks);

  late MockAddInteractionUseCase addUseCase;
  late MockUpdateInteractionUseCase updateUseCase;
  late InteractionFormCubit cubit;

  setUp(() {
    addUseCase = MockAddInteractionUseCase();
    updateUseCase = MockUpdateInteractionUseCase();
    cubit = InteractionFormCubit(addUseCase, updateUseCase);
    addTearDown(cubit.close);
  });

  test('starts in Initial', () {
    expect(cubit.state, const InteractionFormInitial());
  });

  test('startAdd clears any editing context', () {
    final interaction = Interaction(
      interactionId: 4,
      type: InteractionType.call,
      subject: 'x',
      description: 'y',
      interactionDate: DateTime(2025),
      customerId: 1,
      employeeId: 2,
      opportunityId: 2,
    );
    cubit.startEdit(interaction);
    expect(
      cubit.state,
      isA<InteractionFormReady>().having(
        (s) => s.existing,
        'existing',
        interaction,
      ),
    );

    cubit.startAdd();
    expect(cubit.state, const InteractionFormReady(existing: null));
  });

  test('startEdit prepares the form and captures the owning context', () {
    final interaction = Interaction(
      interactionId: 4,
      type: InteractionType.call,
      subject: 'x',
      description: 'y',
      interactionDate: DateTime(2025),
      customerId: 1,
      employeeId: 2,
      opportunityId: 2,
    );
    cubit.startEdit(interaction);

    expect(cubit.state, InteractionFormReady(existing: interaction));
  });

  test('submitNew emits Submitting then Success on success', () async {
    when(() => addUseCase(any()))
        .thenAnswer((_) async => const Success<void>(null));

    cubit.startAdd();
    await cubit.submitNew(
      AddInteractionParams(
        type: InteractionType.call,
        subject: 'Kickoff',
        description: 'Intro',
        interactionDate: DateTime.utc(2025, 6, 1),
        customerId: 7,
      ),
    );

    expect(cubit.state, const InteractionFormSuccess(isEdit: false));
  });

  test('submitNew emits SubmitError on failure', () async {
    const failure = UnauthorizedFailure(message: 'denied');
    when(() => addUseCase(any()))
        .thenAnswer((_) async => const ResultFailure<void>(failure));

    cubit.startAdd();
    await cubit.submitNew(
      AddInteractionParams(
        type: InteractionType.call,
        subject: 'Kickoff',
        description: 'Intro',
        interactionDate: DateTime.utc(2025, 6, 1),
        customerId: 7,
      ),
    );

    expect(
      cubit.state,
      isA<InteractionFormSubmitError>().having(
        (s) => s.failure,
        'failure',
        same(failure),
      ),
    );
  });

  test('submitUpdate without a started edit does nothing', () async {
    when(() => updateUseCase(any(), context: any(named: 'context')))
        .thenAnswer((_) async => const Success<void>(null));

    cubit.startAdd();
    await cubit.submitUpdate(
      UpdateInteractionParams(
        interactionId: 1,
        type: InteractionType.call,
        subject: 'Kickoff',
        description: 'Intro',
        interactionDate: DateTime.utc(2025, 6, 1),
      ),
    );

    verifyNever(() => updateUseCase(any(), context: any(named: 'context')));
    expect(cubit.state, const InteractionFormReady(existing: null));
  });

  test(
    'submitUpdate emits Submitting then Success(isEdit: true) on success',
    () async {
      final interaction = Interaction(
        interactionId: 4,
        type: InteractionType.call,
        subject: 'x',
        description: 'y',
        interactionDate: DateTime(2025),
        customerId: 7,
        employeeId: 2,
        opportunityId: 2,
      );
      cubit.startEdit(interaction);
      when(() => updateUseCase(any(), context: any(named: 'context')))
          .thenAnswer((_) async => const Success<void>(null));

      await cubit.submitUpdate(
        UpdateInteractionParams(
          interactionId: 4,
          type: InteractionType.call,
          subject: 'Kickoff',
          description: 'Intro',
          interactionDate: DateTime.utc(2025, 6, 1),
        ),
      );

      expect(cubit.state, const InteractionFormSuccess(isEdit: true));
      verify(
        () =>
            updateUseCase(captureAny(), context: captureAny(named: 'context')),
      );
    },
  );

  test('submitUpdate emits SubmitError on failure', () async {
    const failure = ServerFailure(message: 'down');
    final interaction = Interaction(
      interactionId: 4,
      type: InteractionType.call,
      subject: 'x',
      description: 'y',
      interactionDate: DateTime(2025),
      customerId: 7,
      employeeId: 2,
    );
    cubit.startEdit(interaction);
    when(() => updateUseCase(any(), context: any(named: 'context')))
        .thenAnswer((_) async => const ResultFailure<void>(failure));

    await cubit.submitUpdate(
      UpdateInteractionParams(
        interactionId: 4,
        type: InteractionType.call,
        subject: 'Kickoff',
        description: 'Intro',
        interactionDate: DateTime.utc(2025, 6, 1),
      ),
    );

    expect(
      cubit.state,
      isA<InteractionFormSubmitError>().having(
        (s) => s.failure,
        'failure',
        same(failure),
      ),
    );
  });
}
