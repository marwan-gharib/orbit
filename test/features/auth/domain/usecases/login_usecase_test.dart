import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/auth/domain/entities/auth_session_entity.dart';
import 'package:orbit/features/auth/domain/entities/permission_entity.dart';
import 'package:orbit/features/auth/domain/entities/user_entity.dart';
import 'package:orbit/features/auth/domain/enums/user_role.dart';
import 'package:orbit/features/auth/domain/params/login_params.dart';
import 'package:orbit/features/auth/domain/repositories/auth_repository.dart';
import 'package:orbit/features/auth/domain/usecases/login_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const tUser = User(
  firstName: 'Adam',
  lastName: 'Orbit',
  code: 'EMP-2026-9582',
  email: 'adam@orbit.app',
  role: UserRole.admin,
  roleName: 'Admin',
  permissions: [Permission(module: 'projects', permission: 'view')],
);

const tSession = AuthSession(
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  user: tUser,
);

const tParams = LoginParams(email: 'adam@orbit.app', password: 'secret');

void main() {
  late _MockAuthRepository repository;
  late LoginUseCase useCase;

  setUpAll(() {
    registerFallbackValue(tParams);
  });

  setUp(() {
    repository = _MockAuthRepository();
    useCase = LoginUseCase(repository);
  });

  test(
    'should call the repository with the same params and return its result',
    () async {
      when(() => repository.login(any()))
          .thenAnswer((_) async => const Success(tSession));

      final result = await useCase(tParams);

      expect(result, const Success(tSession));
      verify(() => repository.login(tParams)).called(1);
    },
  );

  test('should return the repository failure untouched', () async {
    const tFailure = InvalidCredentialsFailure(message: 'wrong');
    when(() => repository.login(any()))
        .thenAnswer((_) async => const ResultFailure(tFailure));

    final result = await useCase(tParams);

    expect(result, const ResultFailure<AuthSession>(tFailure));
  });
}
