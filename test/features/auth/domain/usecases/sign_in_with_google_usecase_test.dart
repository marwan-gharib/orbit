import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/auth/domain/entities/auth_session_entity.dart';
import 'package:orbit/features/auth/domain/entities/google_sign_in_result.dart';
import 'package:orbit/features/auth/domain/entities/permission_entity.dart';
import 'package:orbit/features/auth/domain/entities/signup_result_entity.dart';
import 'package:orbit/features/auth/domain/entities/user_entity.dart';
import 'package:orbit/features/auth/domain/enums/user_role.dart';
import 'package:orbit/features/auth/domain/params/google_payload.dart';
import 'package:orbit/features/auth/domain/repositories/auth_repository.dart';
import 'package:orbit/features/auth/domain/usecases/sign_in_with_google_usecase.dart';

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

const tPayload = GooglePayload(
  iss: 'https://accounts.google.com',
  sub: 'sub_12345',
  email: 'adam@orbit.app',
  givenName: 'Adam',
  familyName: 'Orbit',
  idToken: 'jwt.token.here',
);

void main() {
  late _MockAuthRepository repository;
  late SignInWithGoogleUseCase useCase;

  setUpAll(() {
    registerFallbackValue(tPayload);
  });

  setUp(() {
    repository = _MockAuthRepository();
    useCase = SignInWithGoogleUseCase(repository);
  });

  test('should delegate to repository and return GoogleLoggedIn', () async {
    const expected = GoogleLoggedIn(tSession);
    when(() => repository.signInWithGoogle(any()))
        .thenAnswer((_) async => const Success(expected));

    final result = await useCase(tPayload);

    expect(result, const Success<GoogleSignInResult>(expected));
    verify(() => repository.signInWithGoogle(tPayload)).called(1);
  });

  test('should delegate to repository and return GoogleRegistered', () async {
    const expected = GoogleRegistered(
      SignupResult(
        firstName: 'Adam',
        lastName: 'Orbit',
        email: 'adam@orbit.app',
      ),
    );
    when(() => repository.signInWithGoogle(any()))
        .thenAnswer((_) async => const Success(expected));

    final result = await useCase(tPayload);

    expect(result, const Success<GoogleSignInResult>(expected));
    verify(() => repository.signInWithGoogle(tPayload)).called(1);
  });

  test('should forward repository failures untouched', () async {
    const failure = NetworkFailure(
      message: 'Offline',
      reason: NetworkErrorReason.noInternet,
    );
    when(() => repository.signInWithGoogle(any()))
        .thenAnswer((_) async => const ResultFailure(failure));

    final result = await useCase(tPayload);

    expect(result, const ResultFailure<GoogleSignInResult>(failure));
  });
}
