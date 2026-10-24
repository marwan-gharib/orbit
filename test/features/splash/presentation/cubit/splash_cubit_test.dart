import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/router/route_names.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/splash/domain/entities/splash_state_entity.dart';
import 'package:orbit/features/splash/domain/usecases/check_startup_status_usecase.dart';
import 'package:orbit/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:orbit/features/splash/presentation/cubit/splash_state.dart';

class MockCheckStartupStatusUseCase extends Mock
    implements CheckStartupStatusUseCase {}

void main() {
  const tFailure = CacheFailure(message: 'Startup checks unavailable');
  const tEntity = SplashStateEntity(
    hasAuthToken: true,
    onboardingSeen: false,
    hasPendingSignup: false,
  );

  late MockCheckStartupStatusUseCase checkStartupStatus;
  late Completer<ApiResult<SplashStateEntity>> checksCompleter;

  setUp(() {
    checkStartupStatus = MockCheckStartupStatusUseCase();
    checksCompleter = Completer<ApiResult<SplashStateEntity>>();
  });

  group('SplashCubit', () {
    blocTest<SplashCubit, SplashState>(
      'should emit SplashReady with the routing decision once the animation '
      'and the checks are both done',
      build: () {
        when(() => checkStartupStatus())
            .thenAnswer((_) async => const Success(tEntity));
        return SplashCubit(checkStartupStatus);
      },
      act: (cubit) async {
        await cubit.initialize();
        cubit.onAnimationComplete();
      },
      expect: () => [
        isA<SplashReady>().having(
          (s) => s.viewModel.nextRoute,
          'nextRoute',
          RouteNames.onboarding,
        ),
      ],
    );

    blocTest<SplashCubit, SplashState>(
      'should hold SplashLoading until the checks finish when the animation '
      'completes first',
      build: () {
        when(() => checkStartupStatus())
            .thenAnswer((_) => checksCompleter.future);
        return SplashCubit(checkStartupStatus);
      },
      act: (cubit) async {
        final checks = cubit.initialize();
        cubit.onAnimationComplete();
        await Future<void>.delayed(Duration.zero);
        expect(
          cubit.state,
          isA<SplashLoading>(),
          reason: 'no SplashReady while the checks are in flight',
        );

        checksCompleter.complete(const Success(tEntity));
        await checks;
        expect(cubit.state, isA<SplashReady>());
      },
      expect: () => [isA<SplashReady>()],
    );

    blocTest<SplashCubit, SplashState>(
      'should emit SplashError carrying the failure when the checks fail and '
      'never become ready',
      build: () {
        when(() => checkStartupStatus())
            .thenAnswer((_) async => const ResultFailure(tFailure));
        return SplashCubit(checkStartupStatus);
      },
      act: (cubit) async {
        await cubit.initialize();
        cubit.onAnimationComplete();
      },
      expect: () => [
        isA<SplashError>().having((s) => s.failure, 'failure', tFailure),
      ],
    );
  });
}
