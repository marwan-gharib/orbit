import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/services/crm_data_change.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/interactions/data/datasources/remote/interactions_remote_data_source.dart';
import 'package:orbit/features/interactions/data/repositories/interactions_repository_impl.dart';
import 'package:orbit/features/interactions/domain/entities/interaction_context.dart';
import 'package:orbit/features/interactions/domain/params/add_interaction_params.dart';
import 'package:orbit/features/interactions/domain/params/update_interaction_params.dart';

import '../../interactions_test_mocks.dart';

class _MockInteractionsRemoteDataSource extends Mock
    implements InteractionsRemoteDataSource {}

void main() {
  setUpAll(registerInteractionsFallbacks);

  late _MockInteractionsRemoteDataSource remote;
  late MockCrmDataChangeService changeService;
  late InteractionsRepositoryImpl repository;

  setUp(() {
    remote = _MockInteractionsRemoteDataSource();
    changeService = MockCrmDataChangeService();
    repository = InteractionsRepositoryImpl(remote, changeService);
  });

  final tAddParams = AddInteractionParams(
    type: InteractionType.call,
    subject: 'Kickoff call',
    description: 'Intro',
    interactionDate: DateTime.utc(2025, 6, 1),
    customerId: 7,
    opportunityId: 2,
  );

  final tUpdateParams = UpdateInteractionParams(
    interactionId: 8,
    type: InteractionType.call,
    subject: 'Kickoff call',
    description: 'Intro',
    interactionDate: DateTime.utc(2025, 6, 1),
  );

  const tContext = InteractionContext(customerId: 7, opportunityId: 2);

  void stubAdd(ApiResult<void> result) {
    when(
      () => remote.addInteraction(any(), employeeId: any(named: 'employeeId')),
    ).thenAnswer((_) async => result);
  }

  void stubUpdate(ApiResult<void> result) {
    when(() => remote.updateInteraction(any())).thenAnswer((_) async => result);
  }

  void stubDelete(ApiResult<void> result) {
    when(() => remote.deleteInteraction(any())).thenAnswer((_) async => result);
  }

  test('add publishes the exact change payload once on success', () async {
    stubAdd(const Success<void>(null));

    final result = await repository.addInteraction(tAddParams, employeeId: 46);

    expect(result.isSuccess, isTrue);
    final published = verify(() => changeService.publish(captureAny()))
        .captured;
    expect(published, hasLength(1));
    expect(
      published.single,
      const CrmDataChange(
        kind: CrmDataKind.interaction,
        customerId: 7,
        opportunityId: 2,
      ),
    );
  });

  test(
    'add never publishes on failure and passes the failure through',
    () async {
      const failure = UnauthorizedFailure(message: 'denied');
      stubAdd(const ResultFailure<void>(failure));

      final result = await repository.addInteraction(
        tAddParams,
        employeeId: 46,
      );

      expect(result.failureOrNull, same(failure));
      verifyNever(() => changeService.publish(any()));
    },
  );

  test('update publishes the context payload once on success', () async {
    stubUpdate(const Success<void>(null));

    final result = await repository.updateInteraction(
      tUpdateParams,
      context: tContext,
    );

    expect(result.isSuccess, isTrue);
    expect(
      verify(() => changeService.publish(captureAny())).captured.single,
      const CrmDataChange(
        kind: CrmDataKind.interaction,
        customerId: 7,
        opportunityId: 2,
      ),
    );
  });

  test('update never publishes on failure', () async {
    const failure = UnauthorizedFailure(message: 'denied');
    stubUpdate(const ResultFailure<void>(failure));

    final result = await repository.updateInteraction(
      tUpdateParams,
      context: tContext,
    );

    expect(result.failureOrNull, same(failure));
    verifyNever(() => changeService.publish(any()));
  });

  test('delete publishes the context payload once on success', () async {
    stubDelete(const Success<void>(null));

    final result = await repository.deleteInteraction(8, context: tContext);

    expect(result.isSuccess, isTrue);
    expect(
      verify(() => changeService.publish(captureAny())).captured.single,
      const CrmDataChange(
        kind: CrmDataKind.interaction,
        customerId: 7,
        opportunityId: 2,
      ),
    );
  });

  test('delete never publishes on failure', () async {
    const failure = UnauthorizedFailure(message: 'denied');
    stubDelete(const ResultFailure<void>(failure));

    final result = await repository.deleteInteraction(8, context: tContext);

    expect(result.failureOrNull, same(failure));
    verifyNever(() => changeService.publish(any()));
  });
}
