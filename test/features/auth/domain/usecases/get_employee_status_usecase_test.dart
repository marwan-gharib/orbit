import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/auth/domain/entities/employee_status_info_entity.dart';
import 'package:orbit/features/auth/domain/enums/employment_status.dart';
import 'package:orbit/features/auth/domain/repositories/auth_repository.dart';
import 'package:orbit/features/auth/domain/usecases/get_employee_status_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const tInfo = EmployeeStatusInfo(
  firstName: 'Adam',
  lastName: 'Orbit',
  status: EmploymentStatus.pending,
);

void main() {
  late _MockAuthRepository repository;
  late GetEmployeeStatusUseCase useCase;

  setUp(() {
    repository = _MockAuthRepository();
    useCase = GetEmployeeStatusUseCase(repository);
  });

  test(
    'should pass the email through and return the repository result',
    () async {
      when(() => repository.getEmployeeStatus(any()))
          .thenAnswer((_) async => const Success(tInfo));

      final result = await useCase('adam@orbit.app');

      expect(result, const Success(tInfo));
      verify(() => repository.getEmployeeStatus('adam@orbit.app')).called(1);
    },
  );

  test('should return the repository failure untouched', () async {
    const tFailure = NotFoundFailure(message: 'unknown account');
    when(() => repository.getEmployeeStatus(any()))
        .thenAnswer((_) async => const ResultFailure(tFailure));

    final result = await useCase('unknown@orbit.app');

    expect(result, const ResultFailure<EmployeeStatusInfo>(tFailure));
  });
}
