import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

  final fetches = <InteractionsCriteria>[];

  setUp(() {
    repo = MockInteractionsRepository();
    changes = MockCrmDataChangeService();
    changesController = StreamController<CrmDataChange>();
    fetches.clear();
    addTearDown(changesController.close);
  });

  void stubRepo(ApiResult<List<Interaction>> result) {
    when(() => repo.getInteractions(any())).thenAnswer((invocation) async {
      fetches.add(
        invocation.positionalArguments.single as InteractionsCriteria,
      );
      return result;
    });
  }

  InteractionsListBloc makeBloc() {
    when(() => changes.changes).thenAnswer((_) => changesController.stream);
    return InteractionsListBloc(
      GetInteractionsUseCase(repo),
      WatchInteractionChangesUseCase(changes),
      searchDebounce: Duration.zero,
    );
  }

  /// Event-loop polling helper bounded by a generous real-time cap so a
  /// regression cannot hang the suite.
  Future<void> untilState(
    InteractionsListBloc bloc,
    bool Function(InteractionsListState state) match,
  ) async {
    for (var attempt = 0; attempt < 60 && !match(bloc.state); attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  test(
    'collapses rapid search keystrokes into one fetch of the last text',
    () async {
      final bloc = makeBloc();
      addTearDown(bloc.close);
      stubRepo(Success<List<Interaction>>([tInteraction(id: 1)]));

      bloc.add(const InteractionsListStarted());
      await untilState(bloc, (state) => state is InteractionsListSuccess);

      bloc
        ..add(const InteractionsListSearchChanged('a'))
        ..add(const InteractionsListSearchChanged('ab'))
        ..add(const InteractionsListSearchChanged('abc'));
      await untilState(
        bloc,
        (state) =>
            state is InteractionsListSuccess &&
            state.criteria.searchText == 'abc',
      );

      expect(fetches, [
        const InteractionsCriteria(),
        const InteractionsCriteria(searchText: 'abc'),
      ]);
    },
  );

  test(
    'a change for the listed customer silently refreshes under the criteria',
    () async {
      final bloc = makeBloc();
      addTearDown(bloc.close);
      stubRepo(Success<List<Interaction>>([tInteraction(id: 1)]));

      bloc.add(const InteractionsListStarted());
      await untilState(bloc, (state) => state is InteractionsListSuccess);
      bloc.add(const InteractionsListFiltersChanged(customerId: 7));
      await untilState(
        bloc,
        (state) =>
            state is InteractionsListSuccess && state.criteria.customerId == 7,
      );

      changesController.add(
        const CrmDataChange(kind: CrmDataKind.interaction, customerId: 7),
      );
      await untilState(
        bloc,
        (state) =>
            state is InteractionsListSuccess &&
            state.isRefreshing, // guard against a stale match
      );
      await untilState(
        bloc,
        (state) => state is InteractionsListSuccess && !state.isRefreshing,
      );

      expect(fetches, hasLength(3));
      expect(fetches.last, const InteractionsCriteria(customerId: 7));
    },
  );

  test('a change for another customer does not refresh', () async {
    final bloc = makeBloc();
    addTearDown(bloc.close);
    stubRepo(Success<List<Interaction>>([tInteraction(id: 1)]));

    bloc.add(const InteractionsListStarted());
    await untilState(bloc, (state) => state is InteractionsListSuccess);
    bloc.add(const InteractionsListFiltersChanged(customerId: 7));
    await untilState(
      bloc,
      (state) =>
          state is InteractionsListSuccess && state.criteria.customerId == 7,
    );

    changesController.add(
      const CrmDataChange(kind: CrmDataKind.interaction, customerId: 9),
    );
    await Future<void>.delayed(const Duration(milliseconds: 150));

    expect(fetches, hasLength(2));
    expect(bloc.state, isA<InteractionsListSuccess>());
  });

  test(
    'opportunity-bound list refreshes only for the same opportunity',
    () async {
      final bloc = makeBloc();
      addTearDown(bloc.close);
      stubRepo(Success<List<Interaction>>([tInteraction(id: 1)]));

      bloc.add(const InteractionsListStarted());
      await untilState(bloc, (state) => state is InteractionsListSuccess);
      bloc.add(
        const InteractionsListFiltersChanged(customerId: 7, opportunityId: 2),
      );
      await untilState(
        bloc,
        (state) =>
            state is InteractionsListSuccess &&
            state.criteria.opportunityId == 2,
      );

      changesController.add(
        const CrmDataChange(
          kind: CrmDataKind.interaction,
          customerId: 7,
          opportunityId: 3,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(fetches, hasLength(2));

      changesController.add(
        const CrmDataChange(
          kind: CrmDataKind.interaction,
          customerId: 7,
          opportunityId: 2,
        ),
      );
      await untilState(
        bloc,
        (state) => state is InteractionsListSuccess && state.isRefreshing,
      );
      await untilState(
        bloc,
        (state) => state is InteractionsListSuccess && !state.isRefreshing,
      );

      expect(fetches, hasLength(3));
      expect(
        fetches.last,
        const InteractionsCriteria(customerId: 7, opportunityId: 2),
      );
    },
  );
}
