import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/services/crm_data_change.dart';
import 'package:orbit/core/utils/api_result.dart';

import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/domain/usecases/get_opportunity_usecase.dart';
import 'package:orbit/features/opportunities/domain/usecases/watch_crm_changes_usecase.dart';
import 'package:orbit/features/opportunities/presentation/cubits/opportunity_details/opportunity_details_cubit.dart';
import 'package:orbit/features/opportunities/presentation/cubits/opportunity_details/opportunity_details_state.dart';

import '../../../opportunities_test_mocks.dart';

class _MockGetOpportunityUseCase extends Mock
    implements GetOpportunityUseCase {}

class _MockWatchCrmChangesUseCase extends Mock
    implements WatchCrmChangesUseCase {}

void main() {
  setUpAll(registerOpportunitiesFallbacks);

  late _MockGetOpportunityUseCase getOpportunity;
  late _MockWatchCrmChangesUseCase watchCrmChanges;
  late MockCrmDataChangeService changeService;

  setUp(() {
    getOpportunity = _MockGetOpportunityUseCase();
    watchCrmChanges = _MockWatchCrmChangesUseCase();
    changeService = MockCrmDataChangeService();
    when(() => changeService.changes).thenAnswer(
      (_) => Stream.value(
        const CrmDataChange(
          kind: CrmDataKind.note,
          customerId: 7,
          opportunityId: 1,
        ),
      ),
    );
    when(() => watchCrmChanges()).thenAnswer((_) => changeService.changes);
  });

  OpportunityDetailsCubit newCubit({
    GetOpportunityUseCase? g,
    WatchCrmChangesUseCase? w,
  }) => OpportunityDetailsCubit(
    getOpportunity: g ?? getOpportunity,
    watchCrmChanges: w ?? watchCrmChanges,
  );

  test('should have OpportunityDetailsInitial as the initial state', () {
    expect(newCubit().state, isA<OpportunityDetailsInitial>());
  });

  test('should emit Loading then Success on load', () async {
    when(() => getOpportunity(1))
        .thenAnswer((_) async => Success(tOpportunity()));

    final cubit = newCubit();
    await cubit.load(1);
    await Future<void>.delayed(Duration.zero);

    expect(
      cubit.state,
      isA<OpportunityDetailsSuccess>().having(
        (s) => s.opportunity,
        'opportunity',
        tOpportunity(),
      ),
    );
  });

  test('should emit Loading then Error on failure', () async {
    const failure = NotFoundFailure(message: 'not found');
    when(() => getOpportunity(999))
        .thenAnswer((_) async => ResultFailure<Opportunity>(failure));

    final cubit = newCubit();
    await cubit.load(999);

    expect(
      cubit.state,
      isA<OpportunityDetailsError>().having(
        (s) => s.failure,
        'failure',
        isA<NotFoundFailure>(),
      ),
    );
  });

  test('should silently reload on matching CRM change', () async {
    when(() => getOpportunity(1))
        .thenAnswer((_) async => Success(tOpportunity()));

    final cubit = newCubit();
    await cubit.load(1);

    changeService.publish(
      const CrmDataChange(
        kind: CrmDataKind.note,
        customerId: 7,
        opportunityId: 1,
      ),
    );

    await Future<void>.delayed(Duration.zero);

    expect(
      cubit.state,
      isA<OpportunityDetailsSuccess>()
          .having((s) => s.isRefreshing, 'isRefreshing', isFalse)
          .having((s) => s.refreshFailure, 'refreshFailure', isNull),
    );
  });

  test('should not reload on non-matching CRM change', () async {
    when(() => getOpportunity(1))
        .thenAnswer((_) async => Success(tOpportunity()));

    final cubit = newCubit();
    await cubit.load(1);

    changeService.publish(
      const CrmDataChange(
        kind: CrmDataKind.note,
        customerId: 7,
        opportunityId: 999,
      ),
    );

    await Future<void>.delayed(Duration.zero);

    expect(
      cubit.state,
      isA<OpportunityDetailsSuccess>().having(
        (s) => s.isRefreshing,
        'isRefreshing',
        isFalse,
      ),
    );
  });

  test('should not reload on interaction kind change', () async {
    when(() => getOpportunity(1))
        .thenAnswer((_) async => Success(tOpportunity()));

    final cubit = newCubit();
    await cubit.load(1);

    changeService.publish(
      const CrmDataChange(
        kind: CrmDataKind.interaction,
        customerId: 7,
        opportunityId: 1,
      ),
    );

    await Future<void>.delayed(Duration.zero);

    expect(
      cubit.state,
      isA<OpportunityDetailsSuccess>().having(
        (s) => s.isRefreshing,
        'isRefreshing',
        isFalse,
      ),
    );
  });
}
