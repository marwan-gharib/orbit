import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/services/crm_data_change.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/interactions/domain/entities/interaction_entity.dart';
import 'package:orbit/features/interactions/domain/params/interactions_criteria.dart';
import 'package:orbit/features/interactions/domain/usecases/get_interactions_usecase.dart';
import 'package:orbit/features/interactions/domain/usecases/watch_interaction_changes_usecase.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_bloc.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_event.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_state.dart';

import '../../../interactions_test_mocks.dart';

void main() {
  setUpAll(registerInteractionsFallbacks);

  late MockInteractionsRepository repo;
  late MockCrmDataChangeService changes;
  late StreamController<CrmDataChange> changesController;

  setUp(() {
    repo = MockInteractionsRepository();
    changes = MockCrmDataChangeService();
    changesController = StreamController<CrmDataChange>();
    addTearDown(changesController.close);
  });

  void stubRepo(ApiResult<List<Interaction>> result) {
    when(() => repo.getInteractions(any())).thenAnswer((_) async => result);
  }

  InteractionsListBloc makeBloc() {
    when(() => changes.changes).thenAnswer((_) => changesController.stream);
    return InteractionsListBloc(
      GetInteractionsUseCase(repo),
      WatchInteractionChangesUseCase(changes),
      searchDebounce: Duration.zero,
    );
  }

  Future<void> untilSuccess(
    InteractionsListBloc bloc, {
    bool Function(InteractionsListState)? predicate,
  }) async {
    await bloc.stream.firstWhere(
      predicate ?? (state) => state is InteractionsListSuccess,
    );
  }

  blocTest<InteractionsListBloc, InteractionsListState>(
    'loads once and ignores a repeated Started',
    build: () {
      final bloc = makeBloc();
      stubRepo(Success<List<Interaction>>([tInteraction(id: 1)]));
      return bloc;
    },
    act: (bloc) {
      bloc
        ..add(const InteractionsListStarted())
        ..add(const InteractionsListStarted());
    },
    expect: () => [
      isA<InteractionsListLoading>(),
      isA<InteractionsListSuccess>(),
    ],
    verify: (bloc) {
      final fetched = verify(() => repo.getInteractions(captureAny())).captured;
      expect(fetched, hasLength(1));
      expect(fetched.single, const InteractionsCriteria());
    },
  );

  blocTest<InteractionsListBloc, InteractionsListState>(
    'surfaces a fetch failure as Error state',
    build: () {
      final bloc = makeBloc();
      stubRepo(
        const ResultFailure<List<Interaction>>(
          UnauthorizedFailure(message: 'denied'),
        ),
      );
      return bloc;
    },
    act: (bloc) => bloc.add(const InteractionsListStarted()),
    expect: () => [
      isA<InteractionsListLoading>(),
      isA<InteractionsListError>().having(
        (state) => state.failure,
        'failure',
        isA<UnauthorizedFailure>(),
      ),
    ],
  );

  blocTest<InteractionsListBloc, InteractionsListState>(
    'surfaces an empty result as the Empty state',
    build: () {
      final bloc = makeBloc();
      stubRepo(const Success<List<Interaction>>([]));
      return bloc;
    },
    act: (bloc) => bloc.add(const InteractionsListStarted()),
    expect: () => [
      isA<InteractionsListLoading>(),
      isA<InteractionsListEmpty>(),
    ],
  );

  blocTest<InteractionsListBloc, InteractionsListState>(
    'applies filters immediately and keeps the unfiltered everything else',
    build: () {
      final bloc = makeBloc();
      stubRepo(Success<List<Interaction>>([tInteraction(id: 1)]));
      return bloc;
    },
    act: (bloc) async {
      bloc.add(const InteractionsListStarted());
      await untilSuccess(bloc);
      bloc.add(
        const InteractionsListFiltersChanged(type: InteractionType.meeting),
      );
      await untilSuccess(bloc);
    },
    expect: () => [
      isA<InteractionsListLoading>(),
      isA<InteractionsListSuccess>(),
      isA<InteractionsListLoading>(),
      isA<InteractionsListSuccess>(),
    ],
    verify: (bloc) {
      final fetched = verify(() => repo.getInteractions(captureAny())).captured;
      expect(
        fetched.last,
        const InteractionsCriteria(type: InteractionType.meeting),
      );
    },
  );

  blocTest<InteractionsListBloc, InteractionsListState>(
    'refresh keeps the rows on screen while the refetch is in flight, '
    'then replaces them',
    build: () {
      final bloc = makeBloc();
      stubRepo(Success<List<Interaction>>([tInteraction(id: 1)]));
      return bloc;
    },
    act: (bloc) async {
      bloc.add(const InteractionsListStarted());
      await untilSuccess(bloc);
      stubRepo(Success<List<Interaction>>([tInteraction(id: 2)]));
      bloc.add(const InteractionsListRefreshed());
      await untilSuccess(
        bloc,
        predicate: (state) {
          final success = state is InteractionsListSuccess;
          return success && state.isRefreshing;
        },
      );
      await untilSuccess(
        bloc,
        predicate: (state) {
          final success = state is InteractionsListSuccess;
          return success && !state.isRefreshing;
        },
      );
    },
    expect: () => [
      isA<InteractionsListLoading>(),
      isA<InteractionsListSuccess>(),
      isA<InteractionsListSuccess>().having(
        (state) => state.isRefreshing,
        'isRefreshing',
        isTrue,
      ),
      isA<InteractionsListSuccess>()
          .having((state) => state.isRefreshing, 'isRefreshing', isFalse)
          .having((state) => state.interactions, 'interactions', [
            tInteraction(id: 2),
          ]),
    ],
  );

  blocTest<InteractionsListBloc, InteractionsListState>(
    'a failed refresh keeps the previous rows and only sets refreshFailure',
    build: () {
      final bloc = makeBloc();
      stubRepo(Success<List<Interaction>>([tInteraction(id: 1)]));
      return bloc;
    },
    act: (bloc) async {
      bloc.add(const InteractionsListStarted());
      await untilSuccess(bloc);
      stubRepo(
        const ResultFailure<List<Interaction>>(ServerFailure(message: 'down')),
      );
      bloc.add(const InteractionsListRefreshed());
      await untilSuccess(
        bloc,
        predicate: (state) {
          final success = state is InteractionsListSuccess;
          return success && !state.isRefreshing;
        },
      );
    },
    expect: () => [
      isA<InteractionsListLoading>(),
      isA<InteractionsListSuccess>(),
      isA<InteractionsListSuccess>().having(
        (state) => state.isRefreshing,
        'isRefreshing',
        isTrue,
      ),
      isA<InteractionsListSuccess>()
          .having((state) => state.isRefreshing, 'isRefreshing', isFalse)
          .having((state) => state.interactions, 'interactions', [
            tInteraction(id: 1),
          ])
          .having(
            (state) => state.refreshFailure,
            'refreshFailure',
            isA<ServerFailure>(),
          ),
    ],
  );

  test('a closed bloc stops reacting to CRM change publications', () async {
    final bloc = makeBloc();
    stubRepo(Success<List<Interaction>>([tInteraction(id: 1)]));
    bloc.add(const InteractionsListStarted());
    await untilSuccess(bloc);
    await bloc.close();

    changesController.add(
      const CrmDataChange(kind: CrmDataKind.interaction, customerId: 7),
    );
    await Future<void>.delayed(Duration.zero);

    final fetched = verify(() => repo.getInteractions(captureAny())).captured;
    expect(fetched, hasLength(1));
  });
}
