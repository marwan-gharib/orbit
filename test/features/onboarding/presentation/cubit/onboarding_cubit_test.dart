import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/onboarding/domain/entities/onboarding_page.dart';
import 'package:orbit/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:orbit/features/onboarding/domain/usecases/get_onboarding_pages_usecase.dart';
import 'package:orbit/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:orbit/features/onboarding/presentation/cubit/onboarding_state.dart';

class MockGetOnboardingPagesUseCase extends Mock
    implements GetOnboardingPagesUseCase {}

class MockCompleteOnboardingUseCase extends Mock
    implements CompleteOnboardingUseCase {}

void main() {
  late MockGetOnboardingPagesUseCase getPages;
  late MockCompleteOnboardingUseCase completeOnboarding;

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

  setUp(() {
    getPages = MockGetOnboardingPagesUseCase();
    completeOnboarding = MockCompleteOnboardingUseCase();
  });

  OnboardingCubit newCubit() => OnboardingCubit(getPages, completeOnboarding);

  group('OnboardingCubit', () {
    test('should have OnboardingLoading as the initial state', () {
      expect(newCubit().state, const OnboardingLoading());
    });

    blocTest<OnboardingCubit, OnboardingState>(
      'should emit OnboardingSuccess with the four pages at index 0 when '
      'loading succeeds',
      build: () {
        when(() => getPages()).thenAnswer((_) async => const Success(tPages));
        return newCubit();
      },
      act: (cubit) => cubit.loadPages(),
      expect: () => [
        isA<OnboardingSuccess>()
            .having((s) => s.pages, 'pages', tPages)
            .having((s) => s.currentIndex, 'currentIndex', 0),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'should emit OnboardingError carrying the failure when loading fails',
      build: () {
        when(() => getPages()).thenAnswer(
          (_) async => const ResultFailure<List<OnboardingPage>>(tFailure),
        );
        return newCubit();
      },
      act: (cubit) => cubit.loadPages(),
      expect: () => [
        isA<OnboardingError>().having((s) => s.failure, 'failure', tFailure),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'should emit Success with the new index when a valid different index is '
      'reported',
      build: () {
        when(() => getPages()).thenAnswer((_) async => const Success(tPages));
        return newCubit();
      },
      act: (cubit) async {
        await cubit.loadPages();
        cubit.onPageChanged(2);
      },
      expect: () => [
        isA<OnboardingSuccess>().having(
          (s) => s.currentIndex,
          'currentIndex',
          0,
        ),
        isA<OnboardingSuccess>().having(
          (s) => s.currentIndex,
          'currentIndex',
          2,
        ),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'should not re-emit when the same index is reported',
      build: () {
        when(() => getPages()).thenAnswer((_) async => const Success(tPages));
        return newCubit();
      },
      act: (cubit) async {
        await cubit.loadPages();
        cubit.onPageChanged(0);
      },
      expect: () => [
        isA<OnboardingSuccess>().having(
          (s) => s.currentIndex,
          'currentIndex',
          0,
        ),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'should ignore negative indices',
      build: () {
        when(() => getPages()).thenAnswer((_) async => const Success(tPages));
        return newCubit();
      },
      act: (cubit) async {
        await cubit.loadPages();
        cubit.onPageChanged(-1);
      },
      expect: () => [
        isA<OnboardingSuccess>().having(
          (s) => s.currentIndex,
          'currentIndex',
          0,
        ),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'should ignore out-of-range indices',
      build: () {
        when(() => getPages()).thenAnswer((_) async => const Success(tPages));
        return newCubit();
      },
      act: (cubit) async {
        await cubit.loadPages();
        cubit.onPageChanged(tPages.length);
      },
      expect: () => [
        isA<OnboardingSuccess>().having(
          (s) => s.currentIndex,
          'currentIndex',
          0,
        ),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'should ignore page changes while loading',
      build: () {
        when(() => getPages()).thenAnswer((_) async => const Success(tPages));
        return newCubit();
      },
      act: (cubit) => cubit.onPageChanged(1),
      expect: () => [],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'should ignore page changes while in error',
      build: () {
        when(() => getPages()).thenAnswer(
          (_) async => const ResultFailure<List<OnboardingPage>>(tFailure),
        );
        return newCubit();
      },
      act: (cubit) async {
        await cubit.loadPages();
        cubit.onPageChanged(1);
      },
      expect: () => [
        isA<OnboardingError>().having((s) => s.failure, 'failure', tFailure),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'should emit OnboardingCompleted when completion succeeds',
      build: () {
        when(() => completeOnboarding())
            .thenAnswer((_) async => const Success<void>(null));
        return newCubit();
      },
      act: (cubit) => cubit.complete(),
      expect: () => [isA<OnboardingCompleted>()],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'should still emit OnboardingCompleted when completion fails',
      build: () {
        when(() => completeOnboarding())
            .thenAnswer((_) async => const ResultFailure<void>(tFailure));
        return newCubit();
      },
      act: (cubit) => cubit.complete(),
      expect: () => [isA<OnboardingCompleted>()],
    );
  });
}
