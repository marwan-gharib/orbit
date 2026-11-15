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

/// Filter replace-semantics cases that no longer fit inside
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

  InteractionsListBloc makeBloc() {
    when(() => changes.changes).thenAnswer((_) => changesController.stream);
    return InteractionsListBloc(
      GetInteractionsUseCase(repo),
      WatchInteractionChangesUseCase(changes),
      searchDebounce: Duration.zero,
    );
  }

  Future<void> untilSuccess(InteractionsListBloc bloc) {
    return bloc.stream.firstWhere((state) => state is InteractionsListSuccess);
  }

  blocTest<InteractionsListBloc, InteractionsListState>(
    'FiltersChanged replaces the field set: a null clears only that field',
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
          type: InteractionType.meeting,
          customerId: 7,
        ),
      );
      await untilSuccess(bloc);
      bloc.add(const InteractionsListFiltersChanged(type: null, customerId: 7));
      await untilSuccess(bloc);
    },
    expect: () => [
      isA<InteractionsListLoading>(),
      isA<InteractionsListSuccess>(),
      isA<InteractionsListLoading>(),
      isA<InteractionsListSuccess>(),
      isA<InteractionsListLoading>(),
      isA<InteractionsListSuccess>(),
    ],
    verify: (bloc) {
      final fetched = verify(() => repo.getInteractions(captureAny())).captured
          .cast<InteractionsCriteria>();
      expect(
        fetched[1],
        const InteractionsCriteria(
          type: InteractionType.meeting,
          customerId: 7,
        ),
      );
      expect(fetched[2], const InteractionsCriteria(customerId: 7));
    },
  );

  blocTest<InteractionsListBloc, InteractionsListState>(
    'FiltersCleared resets search text and type but keeps the record scope',
    build: () {
      final bloc = makeBloc();
      stubRepo(Success<List<Interaction>>([tInteraction(id: 1)]));
      return bloc;
    },
    act: (bloc) async {
      bloc.add(const InteractionsListStarted());
      await untilSuccess(bloc);
      bloc.add(const InteractionsListSearchChanged('hello'));
      await untilSuccess(bloc);
      bloc.add(
        const InteractionsListFiltersChanged(
          type: InteractionType.call,
          customerId: 7,
          opportunityId: 9,
        ),
      );
      await untilSuccess(bloc);
      bloc.add(const InteractionsListFiltersCleared());
      await untilSuccess(bloc);
    },
    expect: () => [
      isA<InteractionsListLoading>(),
      isA<InteractionsListSuccess>(),
      isA<InteractionsListLoading>(),
      isA<InteractionsListSuccess>(),
      isA<InteractionsListLoading>(),
      isA<InteractionsListSuccess>(),
      isA<InteractionsListLoading>(),
      isA<InteractionsListSuccess>(),
    ],
    verify: (bloc) {
      final fetched = verify(() => repo.getInteractions(captureAny())).captured
          .cast<InteractionsCriteria>();
      expect(
        fetched.last,
        const InteractionsCriteria(customerId: 7, opportunityId: 9),
      );
      expect(
        bloc.state.criteria,
        const InteractionsCriteria(customerId: 7, opportunityId: 9),
      );
    },
  );
}
