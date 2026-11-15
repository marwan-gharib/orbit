import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/crm_dashboard/domain/entities/dashboard_overview_entity.dart';
import 'package:orbit/features/crm_dashboard/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:orbit/features/crm_dashboard/presentation/cubits/dashboard/dashboard_state.dart';

import '../../../crm_dashboard_test_mocks.dart';

void main() {
  setUpAll(() => registerDashboardFallbacks());

  late MockGetDashboardOverviewUseCase useCase;
  late DashboardOverview freshOverview;

  setUp(() {
    useCase = MockGetDashboardOverviewUseCase();
    freshOverview = tOverview(openValue: 250000, openCount: 9);
  });

  void succeedWith(DashboardOverview overview) {
    when(() => useCase()).thenAnswer((_) async => Success(overview));
  }

  void failWith(Failure failure) {
    when(() => useCase()).thenAnswer((_) async => ResultFailure(failure));
  }

  group('DashboardCubit.load', () {
    blocTest<DashboardCubit, DashboardState>(
      'should emit loading then success on the first load',
      build: () {
        succeedWith(tOverview());
        return DashboardCubit(getOverview: useCase);
      },
      act: (cubit) => cubit.load(),
      expect: () => [isA<DashboardLoading>(), isA<DashboardSuccess>()],
      verify: (bloc) {
        final success = bloc.state as DashboardSuccess;
        expect(success.overview, tOverview());
        expect(success.isRefreshing, isFalse);
        expect(success.refreshFailure, isNull);
        verify(() => useCase()).called(1);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'should emit error when the first load fails',
      build: () {
        failWith(const ServerFailure(message: 'down'));
        return DashboardCubit(getOverview: useCase);
      },
      act: (cubit) => cubit.load(),
      expect: () => [isA<DashboardLoading>(), isA<DashboardError>()],
      verify: (bloc) {
        final error = bloc.state as DashboardError;
        expect(error.failure, isA<ServerFailure>());
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'should not reload when the dashboard already shows data',
      seed: () => DashboardSuccess(overview: tOverview()),
      build: () => DashboardCubit(getOverview: useCase),
      act: (cubit) => cubit.load(),
      expect: () => <DashboardState>[],
      verify: (_) => verifyNever(() => useCase()),
    );

    test(
      'should not start a second fetch while one is already loading',
      () async {
        final pending = Completer<ApiResult<DashboardOverview>>();
        when(() => useCase()).thenAnswer((_) => pending.future);

        final cubit = DashboardCubit(getOverview: useCase);
        unawaited(cubit.load());
        await Future<void>.delayed(Duration.zero);
        expect(cubit.state, isA<DashboardLoading>());

        await cubit.load();

        verify(() => useCase()).called(1);
        verifyNoMoreInteractions(useCase);

        pending.complete(Success(tOverview()));
        await Future<void>.delayed(Duration.zero);
        expect(cubit.state, isA<DashboardSuccess>());
      },
    );
  });

  group('DashboardCubit.refresh', () {
    blocTest<DashboardCubit, DashboardState>(
      'should keep the current data visible while refreshing and on success',
      seed: () => DashboardSuccess(overview: tOverview()),
      build: () {
        succeedWith(freshOverview);
        return DashboardCubit(getOverview: useCase);
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [
        DashboardSuccess(overview: tOverview(), isRefreshing: true),
        DashboardSuccess(overview: freshOverview),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'should keep the current data and set a refresh failure when the '
      'refresh fails',
      seed: () => DashboardSuccess(overview: tOverview()),
      build: () {
        failWith(tDashboardFailure());
        return DashboardCubit(getOverview: useCase);
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [
        DashboardSuccess(overview: tOverview(), isRefreshing: true),
        DashboardSuccess(
          overview: tOverview(),
          refreshFailure: tDashboardFailure(),
        ),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'should fall back to a full load when refreshing from the error state',
      seed: () => const DashboardError(ServerFailure(message: 'down')),
      build: () {
        succeedWith(tOverview());
        return DashboardCubit(getOverview: useCase);
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [isA<DashboardLoading>(), isA<DashboardSuccess>()],
      verify: (bloc) {
        final success = bloc.state as DashboardSuccess;
        expect(success.overview, tOverview());
        expect(success.isRefreshing, isFalse);
      },
    );
  });

  group('DashboardCubit stale response guard', () {
    test('should ignore a stale response that resolves after a newer fetch '
        'has already completed', () async {
      final first = Completer<ApiResult<DashboardOverview>>();
      final second = Completer<ApiResult<DashboardOverview>>();
      var callCount = 0;
      when(() => useCase()).thenAnswer((_) {
        callCount++;
        return callCount == 1 ? first.future : second.future;
      });

      final cubit = DashboardCubit(getOverview: useCase);
      final loadFuture = cubit.load();
      await Future<void>.delayed(Duration.zero);
      final refreshFuture = cubit.refresh();
      await Future<void>.delayed(Duration.zero);

      second.complete(Success(freshOverview));
      await Future<void>.delayed(Duration.zero);
      first.complete(Success(tOverview()));
      await loadFuture;
      await refreshFuture;
      await Future<void>.delayed(Duration.zero);

      final success = cubit.state as DashboardSuccess;
      expect(success.overview, freshOverview);
    });

    test('should not emit after the cubit is closed mid-fetch', () async {
      final pending = Completer<ApiResult<DashboardOverview>>();
      when(() => useCase()).thenAnswer((_) => pending.future);

      final cubit = DashboardCubit(getOverview: useCase);
      final loadFuture = cubit.load();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, isA<DashboardLoading>());

      await cubit.close();
      pending.complete(Success(tOverview()));
      await loadFuture;
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<DashboardLoading>());
    });
  });
}
