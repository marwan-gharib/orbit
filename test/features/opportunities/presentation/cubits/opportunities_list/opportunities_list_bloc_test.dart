import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/core/utils/paged_result.dart';

import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/domain/usecases/get_opportunities_usecase.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_bloc.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_event.dart';
import 'package:orbit/features/opportunities/presentation/blocs/opportunities_list/opportunities_list_state.dart';

import '../../../opportunities_test_mocks.dart';

class _MockGetOpportunitiesUseCase extends Mock
    implements GetOpportunitiesUseCase {}

void main() {
  setUpAll(registerOpportunitiesFallbacks);

  late _MockGetOpportunitiesUseCase getOpportunities;

  setUp(() {
    getOpportunities = _MockGetOpportunitiesUseCase();
  });

  OpportunitiesListBloc newBloc({
    GetOpportunitiesUseCase? g,
  }) =>
      OpportunitiesListBloc(
        getOpportunities: g ?? getOpportunities,
        pageSize: 10,
        searchDebounce: Duration.zero,
      );

  test('should have OpportunitiesListInitial as the initial state', () {
    expect(newBloc().state, isA<OpportunitiesListInitial>());
  });

  test('should emit Loading then Success on first load', () async {
    when(() => getOpportunities(any()))
        .thenAnswer((_) async => Success(PagedResult(
          items: [tOpportunity()],
          hasMore: false,
          nextPage: null,
        )));

    final bloc = newBloc();
    bloc.add(OpportunitiesListStarted());
    await Future<void>.delayed(Duration.zero);

    expect(
      bloc.state,
      isA<OpportunitiesListSuccess>().having(
        (s) => s.items,
        'items',
        hasLength(1),
      ),
    );
  });

  test('should emit Loading then Empty when no results', () async {
    when(() => getOpportunities(any()))
        .thenAnswer((_) async => Success(const PagedResult(
          items: [],
          hasMore: false,
          nextPage: null,
        )));

    final bloc = newBloc();
    bloc.add(OpportunitiesListStarted());
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state, isA<OpportunitiesListEmpty>());
  });

  test('should emit Loading then Error on failure', () async {
    const failure = UnauthorizedFailure(message: 'no session');
    when(() => getOpportunities(any()))
        .thenAnswer((_) async => ResultFailure<PagedResult<Opportunity>>(failure));

    final bloc = newBloc();
    bloc.add(OpportunitiesListStarted());
    await Future<void>.delayed(Duration.zero);

    expect(
      bloc.state,
      isA<OpportunitiesListError>().having(
        (s) => s.failure,
        'failure',
        isA<UnauthorizedFailure>(),
      ),
    );
  });

  test('should append items on load-more', () async {
    var callCount = 0;
    when(() => getOpportunities(any())).thenAnswer((_) async {
      callCount++;
      return Success(PagedResult(
        items: [tOpportunity(id: callCount)],
        hasMore: callCount < 2,
        nextPage: callCount < 2 ? callCount + 1 : null,
      ));
    });

    final bloc = newBloc();
    bloc.add(OpportunitiesListStarted());
    await Future<void>.delayed(Duration.zero);

    bloc.add(OpportunitiesListLoadMoreRequested());
    await Future<void>.delayed(Duration.zero);

    final state = bloc.state as OpportunitiesListSuccess;
    expect(state.items, hasLength(2));
    expect(state.hasMore, isFalse);
  });

  test('should ignore duplicate load-more while one is in flight', () async {
    final pending = Completer<ApiResult<PagedResult<Opportunity>>>();
    when(() => getOpportunities(any())).thenAnswer((_) async => pending.future);

    final bloc = newBloc();
    bloc.add(OpportunitiesListStarted());
    await Future<void>.delayed(Duration.zero);

    bloc.add(OpportunitiesListLoadMoreRequested());
    bloc.add(OpportunitiesListLoadMoreRequested());

    pending.complete(Success(PagedResult(
      items: [tOpportunity()],
      hasMore: false,
      nextPage: null,
    )));
    await Future<void>.delayed(Duration.zero);

    verify(() => getOpportunities(any())).called(1);
  });

  test('should keep items and set loadMoreFailure on load-more failure', () async {
    when(() => getOpportunities(any()))
        .thenAnswer((_) async => Success(PagedResult(
          items: [tOpportunity()],
          hasMore: true,
          nextPage: 2,
        )));

    const failure = UnauthorizedFailure(message: 'down');
    var callCount = 0;
    when(() => getOpportunities(any())).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) {
        return Success(PagedResult(
          items: [tOpportunity()],
          hasMore: true,
          nextPage: 2,
        ));
      }
      return ResultFailure<PagedResult<Opportunity>>(failure);
    });

    final bloc = newBloc();
    bloc.add(OpportunitiesListStarted());
    await Future<void>.delayed(Duration.zero);

    bloc.add(OpportunitiesListLoadMoreRequested());
    await Future<void>.delayed(Duration.zero);

    final state = bloc.state as OpportunitiesListSuccess;
    expect(state.items, hasLength(1)); // kept
    expect(state.loadMoreFailure, isA<UnauthorizedFailure>());
  });

  test('should set hasMore false when next is null', () async {
    when(() => getOpportunities(any()))
        .thenAnswer((_) async => Success(PagedResult(
          items: [tOpportunity()],
          hasMore: false,
          nextPage: null,
        )));

    final bloc = newBloc();
    bloc.add(OpportunitiesListStarted());
    await Future<void>.delayed(Duration.zero);

    expect(
      bloc.state,
      isA<OpportunitiesListSuccess>().having(
        (s) => s.hasMore,
        'hasMore',
        isFalse,
      ),
    );
  });

  test('should not emit after close', () async {
    when(() => getOpportunities(any()))
        .thenAnswer((_) async => Success(PagedResult(
          items: [],
          hasMore: false,
          nextPage: null,
        )));

    final bloc = newBloc();
    bloc.add(OpportunitiesListStarted());
    await bloc.close();

    // Should not throw or emit after close
    expect(bloc.isClosed, isTrue);
  });
}
