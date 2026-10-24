import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/auth/domain/entities/employee_status_info_entity.dart';
import 'package:orbit/features/auth/domain/enums/employment_status.dart';
import 'package:orbit/features/auth/domain/usecases/get_employee_status_usecase.dart';
import 'package:orbit/features/auth/presentation/cubits/employee_status/employee_status_cubit.dart';
import 'package:orbit/features/auth/presentation/cubits/employee_status/employee_status_state.dart';

class MockGetEmployeeStatusUseCase extends Mock
    implements GetEmployeeStatusUseCase {}

const tInfo = EmployeeStatusInfo(
  firstName: 'Adam',
  lastName: 'Orbit',
  status: EmploymentStatus.pending,
);

const tFailure = NotFoundFailure(message: 'unknown account');

void main() {
  late MockGetEmployeeStatusUseCase getEmployeeStatus;

  setUp(() {
    getEmployeeStatus = MockGetEmployeeStatusUseCase();
  });

  EmployeeStatusCubit newCubit() => EmployeeStatusCubit(getEmployeeStatus);

  group('EmployeeStatusCubit', () {
    final pending = Completer<ApiResult<EmployeeStatusInfo>>();

    test('should have EmployeeStatusInitial as the initial state', () {
      expect(newCubit().state, const EmployeeStatusInitial());
    });

    blocTest<EmployeeStatusCubit, EmployeeStatusState>(
      'should emit Loading then Success carrying the status info',
      build: () {
        when(() => getEmployeeStatus())
            .thenAnswer((_) async => const Success(tInfo));
        return newCubit();
      },
      act: (cubit) => cubit.check(),
      expect: () => [
        isA<EmployeeStatusLoading>(),
        isA<EmployeeStatusSuccess>().having((s) => s.info, 'info', tInfo),
      ],
    );

    blocTest<EmployeeStatusCubit, EmployeeStatusState>(
      'should emit Loading then Failure carrying the failure',
      build: () {
        when(() => getEmployeeStatus())
            .thenAnswer((_) async => const ResultFailure(tFailure));
        return newCubit();
      },
      act: (cubit) => cubit.check(),
      expect: () => [
        isA<EmployeeStatusLoading>(),
        isA<EmployeeStatusError>().having(
          (s) => s.failure,
          'failure',
          tFailure,
        ),
      ],
    );

    blocTest<EmployeeStatusCubit, EmployeeStatusState>(
      'should ignore a second check while one is in flight',
      build: () {
        when(() => getEmployeeStatus()).thenAnswer((_) async => pending.future);
        return newCubit();
      },
      act: (cubit) async {
        final first = cubit.check();
        await Future<void>.delayed(Duration.zero);
        await cubit.check();
        pending.complete(const Success(tInfo));
        await first;
      },
      expect: () => [
        isA<EmployeeStatusLoading>(),
        isA<EmployeeStatusSuccess>().having((s) => s.info, 'info', tInfo),
      ],
      verify: (_) => verify(() => getEmployeeStatus()).called(1),
    );
  });
}
