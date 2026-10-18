import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/onboarding/domain/entities/onboarding_page.dart';
import 'package:orbit/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:orbit/features/onboarding/domain/usecases/get_onboarding_pages_usecase.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late MockOnboardingRepository repository;
  late GetOnboardingPagesUseCase useCase;

  setUp(() {
    repository = MockOnboardingRepository();
    useCase = GetOnboardingPagesUseCase(repository);
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

  test('should return the four pages when the repository succeeds', () async {
    when(() => repository.getPages())
        .thenAnswer((_) async => const Success<List<OnboardingPage>>(tPages));

    final result = await useCase();

    expect(result, const Success<List<OnboardingPage>>(tPages));
    verify(() => repository.getPages()).called(1);
  });

  test('should return the failure when the repository fails', () async {
    when(() => repository.getPages()).thenAnswer(
      (_) async => const ResultFailure<List<OnboardingPage>>(tFailure),
    );

    final result = await useCase();

    expect(result, const ResultFailure<List<OnboardingPage>>(tFailure));
    verify(() => repository.getPages()).called(1);
  });
}
