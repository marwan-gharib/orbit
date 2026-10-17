import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/onboarding/data/datasources/local/onboarding_local_data_source.dart';
import 'package:orbit/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:orbit/features/onboarding/domain/entities/onboarding_page.dart';

class MockOnboardingLocalDataSource extends Mock
    implements OnboardingLocalDataSource {}

void main() {
  late MockOnboardingLocalDataSource localDataSource;
  late OnboardingRepositoryImpl repository;

  setUp(() {
    localDataSource = MockOnboardingLocalDataSource();
    repository = OnboardingRepositoryImpl(localDataSource);
  });

  const tPages = <OnboardingPage>[
    OnboardingPage(
      id: 0,
      illustrationType: OnboardingIllustrationType.projects,
    ),
    OnboardingPage(id: 1, illustrationType: OnboardingIllustrationType.people),
    OnboardingPage(id: 2, illustrationType: OnboardingIllustrationType.finance),
    OnboardingPage(
      id: 3,
      illustrationType: OnboardingIllustrationType.insights,
    ),
  ];

  const tFailure = CacheFailure(message: 'Storage unavailable');

  test(
    'should return the four static pages without touching the data source',
    () async {
      final result = await repository.getPages();

      expect(result, isA<Success<List<OnboardingPage>>>());
      expect((result as Success<List<OnboardingPage>>).data, equals(tPages));
      verifyNever(() => localDataSource.setOnboardingSeen());
    },
  );

  test('should complete when the data source succeeds', () async {
    when(() => localDataSource.setOnboardingSeen())
        .thenAnswer((_) async => const Success<void>(null));

    final result = await repository.completeOnboarding();

    expect(result, const Success<void>(null));
    verify(() => localDataSource.setOnboardingSeen()).called(1);
  });

  test('should return the failure when the data source fails', () async {
    when(() => localDataSource.setOnboardingSeen())
        .thenAnswer((_) async => const ResultFailure<void>(tFailure));

    final result = await repository.completeOnboarding();

    expect(result, const ResultFailure<void>(tFailure));
    verify(() => localDataSource.setOnboardingSeen()).called(1);
  });
}
