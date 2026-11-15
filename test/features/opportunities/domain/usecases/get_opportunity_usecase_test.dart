import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/domain/usecases/get_opportunity_usecase.dart';

import '../../opportunities_test_mocks.dart';

void main() {
  setUpAll(registerOpportunitiesFallbacks);

  group('GetOpportunityUseCase', () {
    late MockOpportunitiesRepository repo;
    late GetOpportunityUseCase useCase;

    setUp(() {
      repo = MockOpportunitiesRepository();
      useCase = GetOpportunityUseCase(repo);
    });

    test('should forward the opportunity id to the repository', () async {
      final opportunity = tOpportunity(id: 42);
      when(() => repo.getOpportunity(42))
          .thenAnswer((_) async => Success<Opportunity>(opportunity));

      final result = await useCase(42);

      expect(result, Success<Opportunity>(opportunity));
      verify(() => repo.getOpportunity(42)).called(1);
    });

    test('should pass through a repository failure', () async {
      when(() => repo.getOpportunity(any())).thenAnswer(
        (_) async => ResultFailure<Opportunity>(
          NotFoundFailure(message: 'no such opportunity'),
        ),
      );

      final result = await useCase(999);

      expect(result, isA<ResultFailure<Opportunity>>());
      verify(() => repo.getOpportunity(999)).called(1);
    });
  });
}
