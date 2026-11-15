import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/crm_dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:orbit/features/crm_dashboard/data/datasources/remote/dashboard_remote_data_source.dart';
import 'package:orbit/features/crm_dashboard/domain/entities/dashboard_overview_entity.dart';

import '../../crm_dashboard_test_mocks.dart';

class _DataSource extends Mock implements DashboardRemoteDataSource {}

void main() {
  setUpAll(() => registerDashboardFallbacks());

  late _DataSource dataSource;
  late DashboardRepositoryImpl repository;

  setUp(() {
    dataSource = _DataSource();
    repository = DashboardRepositoryImpl(dataSource);
  });

  group('DashboardRepositoryImpl.getOverview', () {
    test('should map the model into the entity on success', () async {
      when(() => dataSource.fetchOverview())
          .thenAnswer((_) async => Success(tOverviewModel()));

      final result = await repository.getOverview();

      final DashboardOverview? overview = result.dataOrNull;
      expect(overview, isNotNull);
      expect(overview?.currency, 'EGP');
      expect(overview?.openPipeline.count, 4);
      expect(overview?.stages, hasLength(2));
    });

    test('should pass a failure through unchanged', () async {
      final failure = tDashboardFailure();
      when(() => dataSource.fetchOverview())
          .thenAnswer((_) async => ResultFailure(failure));

      final result = await repository.getOverview();

      final Failure? mapped = result.failureOrNull;
      expect(mapped, same(failure));
      expect(result.dataOrNull, isNull);
    });
  });
}
