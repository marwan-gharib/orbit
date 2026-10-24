import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:orbit/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:orbit/features/auth/data/models/google_sso_response_model.dart';
import 'package:orbit/features/auth/data/models/login_response_model.dart';
import 'package:orbit/features/auth/data/models/signup_response_model.dart';
import 'package:orbit/features/auth/data/models/user_model.dart';
import 'package:orbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:orbit/features/auth/domain/entities/google_sign_in_result.dart';
import 'package:orbit/features/auth/domain/params/google_payload.dart';

class _MockRemote extends Mock implements AuthRemoteDataSource {}

class _MockLocal extends Mock implements AuthLocalDataSource {}

final tUserModel = UserModel.fromJson(const <String, dynamic>{
  ApiKeys.firstNameKey: 'Adam',
  ApiKeys.lastNameKey: 'Orbit',
  ApiKeys.codeKey: 'EMP-2026-9582',
  ApiKeys.emailKey: 'adam@orbit.app',
  ApiKeys.roleKey: 1,
  ApiKeys.roleNameKey: 'Admin',
  ApiKeys.permissionsKey: <Object?>[],
});

final tLoginModel = LoginResponseModel(
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  user: tUserModel,
);

const tSignupModel = SignupResponseModel(
  firstName: 'Adam',
  lastName: 'Orbit',
  email: 'adam@orbit.app',
);

const tPayload = GooglePayload(
  iss: 'https://accounts.google.com',
  sub: 'sub_123',
  email: 'adam@orbit.app',
  givenName: 'Adam',
  familyName: 'Orbit',
  idToken: 'token_123',
);

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(tPayload);
    registerFallbackValue(tLoginModel);
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    repository = AuthRepositoryImpl(remote, local);
  });

  group('signInWithGoogle', () {
    test('should persist session and return GoogleLoggedIn on login model', () async {
      final ssoModel = GoogleSsoLoginModel(tLoginModel);
      when(() => remote.signInWithGoogle(any()))
          .thenAnswer((_) async => Success(ssoModel));
      when(() => local.saveSession(any()))
          .thenAnswer((_) async => const Success<void>(null));

      final result = await repository.signInWithGoogle(tPayload);

      expect(result.isSuccess, isTrue);
      final entity = (result as Success<GoogleSignInResult>).data;
      expect(entity, isA<GoogleLoggedIn>());
      final loggedIn = entity as GoogleLoggedIn;
      expect(loggedIn.session.accessToken, 'access-1');
      expect(loggedIn.session.user.email, 'adam@orbit.app');

      verify(() => remote.signInWithGoogle(tPayload)).called(1);
      verify(() => local.saveSession(tLoginModel)).called(1);
      verifyNever(() => local.savePendingSignup(any(), registeredWithGoogle: any(named: 'registeredWithGoogle')));
    });

    test('should fail loudly when saveSession fails on login model', () async {
      final ssoModel = GoogleSsoLoginModel(tLoginModel);
      const storageFailure = StorageFailure(message: 'Disk full');
      when(() => remote.signInWithGoogle(any()))
          .thenAnswer((_) async => Success(ssoModel));
      when(() => local.saveSession(any()))
          .thenAnswer((_) async => const ResultFailure<void>(storageFailure));

      final result = await repository.signInWithGoogle(tPayload);

      expect(result.isFailure, isTrue);
      expect((result as ResultFailure<GoogleSignInResult>).failure, storageFailure);
      verify(() => local.saveSession(tLoginModel)).called(1);
    });

    test('should persist pending signup with Google flag on signup model', () async {
      const ssoModel = GoogleSsoSignupModel(tSignupModel);
      when(() => remote.signInWithGoogle(any()))
          .thenAnswer((_) async => const Success(ssoModel));
      when(() => local.savePendingSignup(any(), registeredWithGoogle: any(named: 'registeredWithGoogle')))
          .thenAnswer((_) async => const Success<void>(null));

      final result = await repository.signInWithGoogle(tPayload);

      expect(result.isSuccess, isTrue);
      final entity = (result as Success<GoogleSignInResult>).data;
      expect(entity, isA<GoogleRegistered>());
      final registered = entity as GoogleRegistered;
      expect(registered.signupResult.email, 'adam@orbit.app');

      verify(() => remote.signInWithGoogle(tPayload)).called(1);
      verify(() => local.savePendingSignup('adam@orbit.app', registeredWithGoogle: true)).called(1);
      verifyNever(() => local.saveSession(any()));
    });

    test('should fail loudly when savePendingSignup fails on signup model', () async {
      const ssoModel = GoogleSsoSignupModel(tSignupModel);
      const cacheFailure = CacheFailure(message: 'Cache write failed');
      when(() => remote.signInWithGoogle(any()))
          .thenAnswer((_) async => const Success(ssoModel));
      when(() => local.savePendingSignup(any(), registeredWithGoogle: any(named: 'registeredWithGoogle')))
          .thenAnswer((_) async => const ResultFailure<void>(cacheFailure));

      final result = await repository.signInWithGoogle(tPayload);

      expect(result.isFailure, isTrue);
      expect((result as ResultFailure<GoogleSignInResult>).failure, cacheFailure);
      verify(() => local.savePendingSignup('adam@orbit.app', registeredWithGoogle: true)).called(1);
    });

    test('should forward remote failures untouched without calling local persistence', () async {
      const requestFailure = RequestFailure(message: 'Invalid payload', statusCode: 400);
      when(() => remote.signInWithGoogle(any()))
          .thenAnswer((_) async => const ResultFailure<GoogleSsoResponseModel>(requestFailure));

      final result = await repository.signInWithGoogle(tPayload);

      expect(result.isFailure, isTrue);
      expect((result as ResultFailure<GoogleSignInResult>).failure, requestFailure);
      verifyNever(() => local.saveSession(any()));
      verifyNever(() => local.savePendingSignup(any(), registeredWithGoogle: any(named: 'registeredWithGoogle')));
    });
  });
}
