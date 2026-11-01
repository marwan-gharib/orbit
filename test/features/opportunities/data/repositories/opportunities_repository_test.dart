import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/core/utils/paged_result.dart';

import 'package:orbit/features/opportunities/data/datasources/remote/opportunities_remote_data_source.dart';
import 'package:orbit/features/opportunities/data/models/opportunities_page_response_model.dart';
import 'package:orbit/features/opportunities/data/repositories/opportunities_repository_impl.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/domain/params/opportunities_criteria.dart';

import '../../opportunities_test_mocks.dart';

class _MockOpportunitiesRemoteDataSource
    extends Mock
    implements OpportunitiesRemoteDataSource {}

void main() {
  setUpAll(registerOpportunitiesFallbacks);

  late _MockOpportunitiesRemoteDataSource remote;
  late OpportunitiesRepositoryImpl repository;

  setUp(() {
    remote = _MockOpportunitiesRemoteDataSource();
    repository = OpportunitiesRepositoryImpl(remote);
  });

  test(
    'getOpportunities maps PagedResult with hasMore from next != null',
    () async {
      when(
        () => remote.fetchOpportunitiesPage(
          criteria: any(named: 'criteria'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => Success(
        OpportunitiesPageResponseModel.fromJson(tPageResponseJson(count: 6, next: '2')),
      ));

      final result = await repository.getOpportunities(
        const OpportunitiesCriteria(),
        page: 1,
        pageSize: 10,
      );

      expect(result.isSuccess, isTrue);
      final paged = result.dataOrNull!;
      expect(paged, isA<PagedResult<Opportunity>>());
      expect(paged.hasMore, isTrue);
      expect(paged.nextPage, 2);
      expect(paged.items, hasLength(1));
    },
  );

  test(
    'getOpportunities hasMore false when next is null',
    () async {
      when(
        () => remote.fetchOpportunitiesPage(
          criteria: any(named: 'criteria'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => Success(
        OpportunitiesPageResponseModel.fromJson(tPageResponseJson(count: 1, next: null)),
      ));

      final result = await repository.getOpportunities(
        const OpportunitiesCriteria(),
        page: 1,
        pageSize: 10,
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull!.hasMore, isFalse);
      expect(result.dataOrNull!.nextPage, isNull);
    },
  );

  test(
    'getOpportunity returns first result when non-empty',
    () async {
      when(
        () => remote.fetchOpportunity(any()),
      ).thenAnswer((_) async => Success(
        OpportunitiesPageResponseModel.fromJson(tPageResponseJson(count: 1, next: null)),
      ));

      final result = await repository.getOpportunity(1);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull!.opportunityId, 1);
    },
  );

  test(
    'getOpportunity returns NotFoundFailure when empty',
    () async {
      when(
        () => remote.fetchOpportunity(any()),
      ).thenAnswer((_) async => Success(
        OpportunitiesPageResponseModel.fromJson(tPageResponseJson(count: 0, next: null, results: [])),
      ));

      final result = await repository.getOpportunity(999);

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NotFoundFailure>());
    },
  );
}
