import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/network/base_api_client.dart';

import 'package:orbit/features/opportunities/data/datasources/remote/opportunities_remote_data_source.dart';
import 'package:orbit/features/opportunities/domain/params/opportunities_criteria.dart';

import '../../../opportunities_test_mocks.dart';

class _MockClient extends Mock implements BaseApiClient {}

void main() {
  late _MockClient client;
  late OpportunitiesRemoteDataSource dataSource;

  setUp(() {
    client = _MockClient();
    dataSource = OpportunitiesRemoteDataSource(client);
  });

  group('fetchOpportunitiesPage', () {
    test('should GET with page, page_size and filters', () async {
      when(
        () => client.get(
          any(that: equals(Endpoints.crmOpportunitiesView)),
          queryParameters: any(named: 'queryParameters'),
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
        ),
      ).thenAnswer((_) async => tPageResponseJson());

      final result = await dataSource.fetchOpportunitiesPage(
        criteria: const OpportunitiesCriteria(title: 'ERP', customerId: 1),
        page: 2,
        pageSize: 10,
      );

      expect(result.isSuccess, isTrue);
      verify(
        () => client.get(
          any(that: equals(Endpoints.crmOpportunitiesView)),
          queryParameters: <String, dynamic>{
            ApiKeys.pageKey: 2,
            ApiKeys.pageSizeKey: 10,
            ApiKeys.titleKey: 'ERP',
            ApiKeys.customerIdKey: 1,
          },
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
        ),
      );
    });

    test('should omit empty title filter', () async {
      when(
        () => client.get(
          any(that: equals(Endpoints.crmOpportunitiesView)),
          queryParameters: any(named: 'queryParameters'),
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
        ),
      ).thenAnswer((_) async => tPageResponseJson());

      final result = await dataSource.fetchOpportunitiesPage(
        criteria: const OpportunitiesCriteria(title: ''),
        page: 1,
        pageSize: 10,
      );

      expect(result.isSuccess, isTrue);
      verify(
        () => client.get(
          any(that: equals(Endpoints.crmOpportunitiesView)),
          queryParameters: <String, dynamic>{
            ApiKeys.pageKey: 1,
            ApiKeys.pageSizeKey: 10,
          },
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
        ),
      );
    });

    test('should return ParsingFailure on malformed body', () async {
      when(
        () => client.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
        ),
      ).thenAnswer((_) async => 'not a map');

      final result = await dataSource.fetchOpportunitiesPage(
        criteria: const OpportunitiesCriteria(),
        page: 1,
        pageSize: 10,
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ParsingFailure>());
    });
  });

  group('fetchOpportunity', () {
    test('should GET with opportunity_id, page=1, page_size=1', () async {
      when(
        () => client.get(
          any(that: equals(Endpoints.crmOpportunitiesView)),
          queryParameters: any(named: 'queryParameters'),
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
        ),
      ).thenAnswer((_) async => tPageResponseJson());

      final result = await dataSource.fetchOpportunity(42);

      expect(result.isSuccess, isTrue);
      verify(
        () => client.get(
          any(that: equals(Endpoints.crmOpportunitiesView)),
          queryParameters: <String, dynamic>{
            ApiKeys.pageKey: 1,
            ApiKeys.pageSizeKey: 1,
            ApiKeys.opportunityIdKey: 42,
          },
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
        ),
      );
    });
  });
}
