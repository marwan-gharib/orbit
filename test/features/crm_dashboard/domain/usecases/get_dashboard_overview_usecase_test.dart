import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/crm_dashboard/domain/usecases/get_dashboard_overview_usecase.dart';

import '../../crm_dashboard_test_mocks.dart';

void main() {
  setUpAll(() => registerDashboardFallbacks());

  late MockDashboardRepository repository;
  late GetDashboardOverviewUseCase useCase;

  setUp(() {
    repository = MockDashboardRepository();
    useCase = GetDashboardOverviewUseCase(repository);
  });

  group('GetDashboardOverviewUseCase', () {
    test('should return the repository result unchanged on success', () async {
      final overview = tOverview();
      when(() => repository.getOverview())
          .thenAnswer((_) async => Success(overview));

      final result = await useCase();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, same(overview));
      verify(() => repository.getOverview()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('should return the repository failure unchanged', () async {
      final failure = tDashboardFailure();
      when(() => repository.getOverview())
          .thenAnswer((_) async => ResultFailure(failure));

      final result = await useCase();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, same(failure));
    });
  });
}
