import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:orbit/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late MockOnboardingRepository repository;
  late CompleteOnboardingUseCase useCase;

  setUp(() {
    repository = MockOnboardingRepository();
    useCase = CompleteOnboardingUseCase(repository);
  });

  const tFailure = CacheFailure(message: 'Storage unavailable');

  test('should return success when the repository succeeds', () async {
    when(() => repository.completeOnboarding())
        .thenAnswer((_) async => const Success<void>(null));

    final result = await useCase();

    expect(result, const Success<void>(null));
    verify(() => repository.completeOnboarding()).called(1);
  });

  test('should return the failure when the repository fails', () async {
    when(() => repository.completeOnboarding())
        .thenAnswer((_) async => const ResultFailure<void>(tFailure));

    final result = await useCase();

    expect(result, const ResultFailure<void>(tFailure));
    verify(() => repository.completeOnboarding()).called(1);
  });
}
