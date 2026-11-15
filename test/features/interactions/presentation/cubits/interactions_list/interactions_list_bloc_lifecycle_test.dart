import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/services/crm_data_change.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/domain/entities/interaction_entity.dart';
import 'package:orbit/features/interactions/domain/params/interactions_criteria.dart';
import 'package:orbit/features/interactions/domain/usecases/get_interactions_usecase.dart';
import 'package:orbit/features/interactions/domain/usecases/watch_interaction_changes_usecase.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_bloc.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_event.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_state.dart';

import '../../../interactions_test_mocks.dart';

/// Search-debounce and restartable-reload cases that no longer fit inside
/// `interactions_list_bloc_test.dart` under the 300-line cap, so they live
/// here; the original file stays untouched.
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

  InteractionsListBloc makeBloc({Duration searchDebounce = Duration.zero}) {
    when(() => changes.changes).thenAnswer((_) => changesController.stream);
    return InteractionsListBloc(
      GetInteractionsUseCase(repo),
      WatchInteractionChangesUseCase(changes),
      searchDebounce: searchDebounce,
    );
  }

  /// One Completer per refresh fetch, filled in call order; used by the
  /// cancellation test to suspend refresh handlers mid-flight.
  final refreshFetches = <Completer<ApiResult<List<Interaction>>>>[];

  Future<void> untilSuccess(
    InteractionsListBloc bloc, {
    bool Function(InteractionsListState)? predicate,
  }) {
    return bloc.stream.firstWhere(
      predicate ?? (state) => state is InteractionsListSuccess,
    );
  }

  blocTest<InteractionsListBloc, InteractionsListState>(
    'Started reaches Success and the state carries the items and its criteria',
    build: () {
      final bloc = makeBloc();
      stubRepo(
        Success<List<Interaction>>([tInteraction(id: 1), tInteraction(id: 2)]),
      );
      return bloc;
    },
    act: (bloc) => bloc.add(const InteractionsListStarted()),
    expect: () => [
      isA<InteractionsListLoading>(),
      isA<InteractionsListSuccess>()
          .having((state) => state.interactions, 'interactions', [
            tInteraction(id: 1),
            tInteraction(id: 2),
          ])
          .having(
            (state) => state.criteria,
            'criteria',
            const InteractionsCriteria(),
          ),
    ],
  );

  blocTest<InteractionsListBloc, InteractionsListState>(
    'rapid keystrokes debounce ~300ms so only the last text issues a fetch',
    build: () {
      final bloc = makeBloc(searchDebounce: const Duration(milliseconds: 300));
      stubRepo(Success<List<Interaction>>([tInteraction(id: 1)]));
      return bloc;
    },
    act: (bloc) => bloc
      ..add(const InteractionsListSearchChanged('a'))
      ..add(const InteractionsListSearchChanged('ab'))
      ..add(const InteractionsListSearchChanged('abc')),
    wait: const Duration(milliseconds: 350),
    expect: () => [
      isA<InteractionsListLoading>(),
      isA<InteractionsListSuccess>(),
    ],
    verify: (bloc) {
      final fetched = verify(() => repo.getInteractions(captureAny())).captured
          .cast<InteractionsCriteria>();
      expect(fetched, hasLength(1));
      expect(fetched.single, const InteractionsCriteria(searchText: 'abc'));
    },
  );

  blocTest<InteractionsListBloc, InteractionsListState>(
    'a second Refreshed cancels the first: only the newest result lands',
    build: () {
      final bloc = makeBloc();
      // The first load resolves instantly; every refresh fetch suspends on
      // its own Completer so the restartable transformer can actually cancel
      // a handler that is still awaiting.
      var call = 0;
      when(() => repo.getInteractions(any())).thenAnswer((_) {
        call++;
        if (call == 1) {
          return Future.value(
            Success<List<Interaction>>([tInteraction(id: 1)]),
          );
        }
        final completer = Completer<ApiResult<List<Interaction>>>();
        refreshFetches.add(completer);
        return completer.future;
      });
      return bloc;
    },
    act: (bloc) async {
      bloc.add(const InteractionsListStarted());
      await untilSuccess(bloc);
      bloc.add(const InteractionsListRefreshed());
      await untilSuccess(
        bloc,
        predicate: (state) =>
            state is InteractionsListSuccess && state.isRefreshing,
      );
      // Second refresh cancels the suspended first one.
      bloc.add(const InteractionsListRefreshed());
      while (refreshFetches.length < 2) {
        await Future<void>.delayed(Duration.zero);
      }
      refreshFetches.last.complete(
        Success<List<Interaction>>([tInteraction(id: 2)]),
      );
      await untilSuccess(
        bloc,
        predicate: (state) =>
            state is InteractionsListSuccess && !state.isRefreshing,
      );
    },
    expect: () => [
      isA<InteractionsListLoading>(),
      isA<InteractionsListSuccess>().having(
        (state) => state.isRefreshing,
        'isRefreshing',
        isFalse,
      ),
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
    verify: (bloc) {
      verify(() => repo.getInteractions(captureAny())).called(3);
    },
  );

  blocTest<InteractionsListBloc, InteractionsListState>(
    'Refreshed reloads under the active criteria',
    build: () {
      final bloc = makeBloc();
      stubRepo(Success<List<Interaction>>([tInteraction(id: 1)]));
      return bloc;
    },
    act: (bloc) async {
      bloc.add(const InteractionsListStarted());
      await untilSuccess(bloc);
      bloc.add(
        const InteractionsListFiltersChanged(
          type: InteractionType.call,
          customerId: 7,
        ),
      );
      await untilSuccess(
        bloc,
        predicate: (state) =>
            state is InteractionsListSuccess &&
            state.criteria.type == InteractionType.call &&
            state.criteria.customerId == 7,
      );
      bloc.add(const InteractionsListRefreshed());
      await untilSuccess(
        bloc,
        predicate: (state) =>
            state is InteractionsListSuccess && !state.isRefreshing,
      );
    },
    expect: () => [
      isA<InteractionsListLoading>(),
      isA<InteractionsListSuccess>(),
      isA<InteractionsListLoading>(),
      isA<InteractionsListSuccess>(),
      isA<InteractionsListSuccess>().having(
        (state) => state.isRefreshing,
        'isRefreshing',
        isTrue,
      ),
      isA<InteractionsListSuccess>().having(
        (state) => state.isRefreshing,
        'isRefreshing',
        isFalse,
      ),
    ],
    verify: (bloc) {
      final fetched = verify(() => repo.getInteractions(captureAny())).captured
          .cast<InteractionsCriteria>();
      expect(
        fetched.last,
        const InteractionsCriteria(type: InteractionType.call, customerId: 7),
      );
      expect(fetched, hasLength(3));
    },
  );
}
