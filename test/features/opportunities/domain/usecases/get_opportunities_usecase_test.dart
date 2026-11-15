import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/core/utils/paged_result.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/domain/params/get_opportunities_params.dart';
import 'package:orbit/features/opportunities/domain/params/opportunities_criteria.dart';
import 'package:orbit/features/opportunities/domain/usecases/get_opportunities_usecase.dart';

import '../../opportunities_test_mocks.dart';

void main() {
  setUpAll(registerOpportunitiesFallbacks);

  group('GetOpportunitiesUseCase', () {
    late MockOpportunitiesRepository repo;
    late GetOpportunitiesUseCase useCase;

    setUp(() {
      repo = MockOpportunitiesRepository();
      useCase = GetOpportunitiesUseCase(repo);
    });

    test(
      'should forward criteria, page and pageSize to the repository',
      () async {
        final params = GetOpportunitiesParams(
          criteria: const OpportunitiesCriteria(title: 'ERP'),
          page: 2,
          pageSize: 25,
        );
        const page = PagedResult<Opportunity>(
          items: [],
          hasMore: false,
          nextPage: null,
        );
        when(
          () => repo.getOpportunities(
            any(),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer(
          (_) async => const Success<PagedResult<Opportunity>>(page),
        );

        final result = await useCase(params);

        expect(result, const Success<PagedResult<Opportunity>>(page));
        verify(
          () => repo.getOpportunities(
            const OpportunitiesCriteria(title: 'ERP'),
            page: 2,
            pageSize: 25,
          ),
        ).called(1);
      },
    );

    test('should pass through a repository failure', () async {
      final failure = ServerFailure(message: 'down');
      when(
        () => repo.getOpportunities(
          any(),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer(
        (_) async => ResultFailure<PagedResult<Opportunity>>(failure),
      );

      final result = await useCase(
        GetOpportunitiesParams(
          criteria: const OpportunitiesCriteria(),
          page: 1,
          pageSize: 10,
        ),
      );

      expect(result, isA<ResultFailure<PagedResult<Opportunity>>>());
    });
  });
}
