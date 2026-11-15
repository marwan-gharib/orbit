import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/features/crm_dashboard/data/datasources/remote/dashboard_remote_data_source.dart';
import 'package:orbit/features/crm_dashboard/data/models/dashboard_overview_model.dart';

import '../../../crm_dashboard_test_mocks.dart';

class _Client extends MockBaseApiClient {}

void main() {
  setUpAll(() => registerDashboardFallbacks());

  late _Client client;
  late DashboardRemoteDataSource dataSource;

  setUp(() {
    client = _Client();
    dataSource = DashboardRemoteDataSource(client);
  });

  group('fetchOverview', () {
    test('should GET the overview endpoint and parse the body', () async {
      when(() => client.get(any())).thenAnswer((_) async => tOverviewJson());

      final result = await dataSource.fetchOverview();

      expect(result.isSuccess, isTrue);
      final DashboardOverviewModel? model = result.dataOrNull;
      expect(model?.currency, 'EGP');
      expect(model?.openPipeline.count, 4);
      verify(() => client.get(any())).called(1);
    });

    test('should fail with a Failure when the body is not an object', () async {
      when(() => client.get(any())).thenAnswer((_) async => ['not a map']);

      final result = await dataSource.fetchOverview();

      expect(result.isFailure, isTrue);
      final Failure? failure = result.failureOrNull;
      expect(failure, isA<Failure>());
    });

    test('should fail with a Failure when the client throws', () async {
      when(() => client.get(any())).thenThrow(Exception('network down'));

      final result = await dataSource.fetchOverview();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<Failure>());
    });

    test(
      'should fail with a Failure when a list field has the wrong shape',
      () async {
        when(() => client.get(any()))
            .thenAnswer((_) async => tOverviewJson(pipelineByStage: 42));

        final result = await dataSource.fetchOverview();

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<Failure>());
      },
    );
  });
}
