import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/interactions/data/models/interactions_response_model.dart';
import 'package:orbit/features/interactions/data/repositories/interactions_repository_impl.dart';
import 'package:orbit/features/interactions/data/datasources/remote/interactions_remote_data_source.dart';
import 'package:orbit/features/interactions/domain/params/interactions_criteria.dart';

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

  void stubBase(
    ApiResult<InteractionsResponseModel> result, {
    InteractionType? type,
    int? customerId,
  }) {
    when(
      () => remote.fetchInteractions(
        subject: null,
        description: null,
        type: type,
        customerId: customerId,
        contactId: null,
        opportunityId: null,
      ),
    ).thenAnswer((_) async => result);
  }

  void stubSubjectSearch(
    String text,
    ApiResult<InteractionsResponseModel> result,
  ) {
    when(
      () => remote.fetchInteractions(
        subject: text,
        description: null,
        type: null,
        customerId: null,
        contactId: null,
        opportunityId: null,
      ),
    ).thenAnswer((_) async => result);
  }

  void stubDescriptionSearch(
    String text,
    ApiResult<InteractionsResponseModel> result,
  ) {
    when(
      () => remote.fetchInteractions(
        subject: null,
        description: text,
        type: null,
        customerId: null,
        contactId: null,
        opportunityId: null,
      ),
    ).thenAnswer((_) async => result);
  }

  void stubBaseWithType(
    ApiResult<InteractionsResponseModel> result,
    InteractionType type,
  ) {
    when(
      () => remote.fetchInteractions(
        subject: null,
        description: null,
        type: type,
        customerId: null,
        contactId: null,
        opportunityId: null,
      ),
    ).thenAnswer((_) async => result);
  }

  ApiResult<InteractionsResponseModel> okOf(List<Map<String, dynamic>> items) =>
      Success(
        InteractionsResponseModel.fromJson({
          ApiKeys.interactionsRootKey: items,
        }),
      );

  ApiResult<InteractionsResponseModel> failureOf(String message) =>
      ResultFailure<InteractionsResponseModel>(
        UnauthorizedFailure(message: message),
      );

  test(
    'single GET sorts interaction_date desc, then interaction_id desc',
    () async {
      stubBase(
        okOf([
          tInteractionJson(id: 5, date: '2025-01-01T00:00:00Z'),
          tInteractionJson(id: 9, date: '2025-06-01T00:00:00Z'),
          tInteractionJson(id: 2, date: '2025-06-01T00:00:00Z'),
        ]),
      );

      final result = await repository.getInteractions(
        const InteractionsCriteria(),
      );

      expect(result.isSuccess, isTrue);
      expect(
        result.dataOrNull!.map((interaction) => interaction.interactionId),
        [9, 2, 5],
      );
      verifyNever(() => changeService.publish(any()));
    },
  );

  test('single GET passes the active filters through', () async {
    stubBaseWithType(okOf([tInteractionJson(id: 1)]), InteractionType.call);

    final result = await repository.getInteractions(
      const InteractionsCriteria(type: InteractionType.call),
    );

    expect(result.isSuccess, isTrue);
    verify(
      () => remote.fetchInteractions(
        subject: null,
        description: null,
        type: InteractionType.call,
        customerId: null,
        contactId: null,
        opportunityId: null,
      ),
    );
  });

  test(
    'search merges the two GETs, dedupes by id and sorts, subject copy wins',
    () async {
      stubSubjectSearch(
        'norm',
        okOf([
          tInteractionJson(id: 10, date: '2025-06-01T00:00:00Z'),
          tInteractionJson(id: 3, date: '2025-05-01T00:00:00Z'),
        ]),
      );
      stubDescriptionSearch(
        'norm',
        okOf([
          tInteractionJson(id: 10, date: '2025-04-01T00:00:00Z'),
          tInteractionJson(id: 7, date: '2025-02-01T00:00:00Z'),
        ]),
      );

      final result = await repository.getInteractions(
        const InteractionsCriteria(searchText: 'norm'),
      );

      expect(result.isSuccess, isTrue);
      // Subject copy of id 10 kept (June), others sorted date desc.
      expect(
        result.dataOrNull!.map((interaction) => interaction.interactionDate),
        [
          DateTime.utc(2025, 6, 1),
          DateTime.utc(2025, 5, 1),
          DateTime.utc(2025, 2, 1),
        ],
      );
      expect(
        result.dataOrNull!.map((interaction) => interaction.interactionId),
        [10, 3, 7],
      );
    },
  );

  test('a failing subject GET fails the whole search', () async {
    final subjectFailure = failureOf('subject down');
    stubSubjectSearch('norm', subjectFailure);
    stubDescriptionSearch('norm', okOf([tInteractionJson(id: 7)]));

    final result = await repository.getInteractions(
      const InteractionsCriteria(searchText: 'norm'),
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<UnauthorizedFailure>());
    verifyNever(() => changeService.publish(any()));
  });

  test('a failing description GET fails the whole search', () async {
    stubSubjectSearch('norm', okOf([tInteractionJson(id: 7)]));
    stubDescriptionSearch('norm', failureOf('description down'));

    final result = await repository.getInteractions(
      const InteractionsCriteria(searchText: 'norm'),
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<UnauthorizedFailure>());
  });

  test('when both GETs fail, the subject failure wins', () async {
    stubSubjectSearch('norm', failureOf('subject down'));
    stubDescriptionSearch('norm', failureOf('description down'));

    final result = await repository.getInteractions(
      const InteractionsCriteria(searchText: 'norm'),
    );

    expect(result.isFailure, isTrue);
    verifyNever(() => changeService.publish(any()));
  });
}
