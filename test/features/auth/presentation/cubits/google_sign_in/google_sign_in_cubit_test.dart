import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/auth/data/datasources/google/google_auth_client.dart';
import 'package:orbit/features/auth/domain/entities/auth_session_entity.dart';
import 'package:orbit/features/auth/domain/entities/google_sign_in_result.dart';
import 'package:orbit/features/auth/domain/entities/permission_entity.dart';
import 'package:orbit/features/auth/domain/entities/signup_result_entity.dart';
import 'package:orbit/features/auth/domain/entities/user_entity.dart';
import 'package:orbit/features/auth/domain/enums/user_role.dart';
import 'package:orbit/features/auth/domain/params/google_payload.dart';
import 'package:orbit/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:orbit/features/auth/presentation/cubits/google_sign_in/google_sign_in_cubit.dart';
import 'package:orbit/features/auth/presentation/cubits/google_sign_in/google_sign_in_state.dart';

class _MockGoogleAuthClient extends Mock implements GoogleAuthClient {}

class _MockSignInWithGoogleUseCase extends Mock implements SignInWithGoogleUseCase {}

String createTestJwt(Map<String, dynamic> payload) {
  final header = base64Url.encode(utf8.encode('{"alg":"RS256"}')).replaceAll('=', '');
  final body = base64Url.encode(utf8.encode(jsonEncode(payload))).replaceAll('=', '');
  return '$header.$body.signature';
}

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

const tSignupResult = SignupResult(
  firstName: 'Adam',
  lastName: 'Orbit',
  email: 'adam@orbit.app',
);

void main() {
  late _MockGoogleAuthClient mockGoogleAuthClient;
  late _MockSignInWithGoogleUseCase mockUseCase;

  setUpAll(() {
    registerFallbackValue(
      const GooglePayload(
        iss: 'https://accounts.google.com',
        sub: 'sub_123',
        email: 'adam@orbit.app',
        givenName: 'Adam',
        familyName: 'Orbit',
        idToken: 'token',
      ),
    );
  });

  setUp(() {
    mockGoogleAuthClient = _MockGoogleAuthClient();
    mockUseCase = _MockSignInWithGoogleUseCase();
  });

  final validJwt = createTestJwt({
    'iss': 'https://accounts.google.com',
    'sub': 'sub_123',
    'email': 'adam@orbit.app',
    'given_name': 'Adam',
    'family_name': 'Orbit',
  });

  group('GoogleSignInCubit', () {
    test('initial state is GoogleSignInIdle', () {
      final cubit = GoogleSignInCubit(
        mockGoogleAuthClient,
        mockUseCase,
      );
      expect(cubit.state, const GoogleSignInIdle());
      cubit.close();
    });

    blocTest<GoogleSignInCubit, GoogleSignInState>(
      'emits [Loading, Idle] when user cancels Google authentication',
      build: () {
        when(() => mockGoogleAuthClient.authenticate())
            .thenAnswer((_) async => const GoogleAuthCancelled());
        return GoogleSignInCubit(
          mockGoogleAuthClient,
          mockUseCase,
        );
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => const [
        GoogleSignInLoading(),
        GoogleSignInIdle(),
      ],
      verify: (_) {
        verifyNever(() => mockUseCase(any()));
      },
    );

    blocTest<GoogleSignInCubit, GoogleSignInState>(
      'emits [Loading, Error] when Google client returns failure',
      build: () {
        const failure = NetworkFailure(
          message: 'Offline',
          reason: NetworkErrorReason.noInternet,
        );
        when(() => mockGoogleAuthClient.authenticate())
            .thenAnswer((_) async => const GoogleAuthFailure(failure));
        return GoogleSignInCubit(
          mockGoogleAuthClient,
          mockUseCase,
        );
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => const [
        GoogleSignInLoading(),
        GoogleSignInError(
          NetworkFailure(
            message: 'Offline',
            reason: NetworkErrorReason.noInternet,
          ),
        ),
      ],
    );

    blocTest<GoogleSignInCubit, GoogleSignInState>(
      'emits [Loading, Authenticated] when login succeeds',
      build: () {
        when(() => mockGoogleAuthClient.authenticate()).thenAnswer(
          (_) async => GoogleAuthSuccess(
            idToken: validJwt,
            displayName: 'Adam Orbit',
            email: 'adam@orbit.app',
          ),
        );
        when(() => mockUseCase(any())).thenAnswer(
          (_) async => const Success(GoogleLoggedIn(tSession)),
        );
        return GoogleSignInCubit(
          mockGoogleAuthClient,
          mockUseCase,
        );
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => const [
        GoogleSignInLoading(),
        GoogleSignInAuthenticated(tSession),
      ],
    );

    blocTest<GoogleSignInCubit, GoogleSignInState>(
      'emits [Loading, Pending] when signup succeeds',
      build: () {
        when(() => mockGoogleAuthClient.authenticate()).thenAnswer(
          (_) async => GoogleAuthSuccess(
            idToken: validJwt,
            displayName: 'Adam Orbit',
            email: 'adam@orbit.app',
          ),
        );
        when(() => mockUseCase(any())).thenAnswer(
          (_) async => const Success(GoogleRegistered(tSignupResult)),
        );
        return GoogleSignInCubit(
          mockGoogleAuthClient,
          mockUseCase,
        );
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => const [
        GoogleSignInLoading(),
        GoogleSignInPending(tSignupResult),
      ],
    );

    const tBackendFailure = RequestFailure(message: 'Invalid request', statusCode: 400);

    blocTest<GoogleSignInCubit, GoogleSignInState>(
      'emits [Loading, Error] when backend returns failure',
      build: () {
        when(() => mockGoogleAuthClient.authenticate()).thenAnswer(
          (_) async => GoogleAuthSuccess(
            idToken: validJwt,
            displayName: 'Adam Orbit',
            email: 'adam@orbit.app',
          ),
        );
        when(() => mockUseCase(any())).thenAnswer(
          (_) async => const ResultFailure<GoogleSignInResult>(tBackendFailure),
        );
        return GoogleSignInCubit(
          mockGoogleAuthClient,
          mockUseCase,
        );
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => const [
        GoogleSignInLoading(),
        GoogleSignInError(tBackendFailure),
      ],
    );

    blocTest<GoogleSignInCubit, GoogleSignInState>(
      'emits [Loading, Error] when token decoding fails with FormatException',
      build: () {
        when(() => mockGoogleAuthClient.authenticate()).thenAnswer(
          (_) async => const GoogleAuthSuccess(
            idToken: 'invalid.token',
            displayName: 'Adam Orbit',
            email: 'adam@orbit.app',
          ),
        );
        return GoogleSignInCubit(
          mockGoogleAuthClient,
          mockUseCase,
        );
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        const GoogleSignInLoading(),
        predicate<GoogleSignInState>((state) {
          return state is GoogleSignInError && state.failure is ParsingFailure;
        }),
      ],
    );
  });
}
