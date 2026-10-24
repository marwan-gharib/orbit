import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/local/cache/cache_service.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
import 'package:orbit/core/router/pending_signup_session.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:orbit/features/auth/data/models/login_response_model.dart';

class _MockCacheService extends Mock implements CacheService {}

class _MockSecureStorage extends Mock implements SecureStorageClient {}

LoginResponseModel _tSession() {
  final user = <String, dynamic>{
    ApiKeys.firstNameKey: 'Adam',
    ApiKeys.lastNameKey: 'Orbit',
    ApiKeys.codeKey: 'EMP-2026-9582',
    ApiKeys.emailKey: 'adam@orbit.app',
    ApiKeys.roleKey: 1,
    ApiKeys.roleNameKey: 'Admin',
    ApiKeys.permissionsKey: const <Object?>[],
  };
  return LoginResponseModel.fromJson(<String, dynamic>{
    ApiKeys.accessTokenKey: 'access-1',
    ApiKeys.refreshTokenKey: 'refresh-1',
    ApiKeys.userKey: user,
  });
}

void main() {
  late _MockCacheService cache;
  late _MockSecureStorage secureStorage;
  late PendingSignupSession pendingSession;
  late AuthLocalDataSource dataSource;
  late LoginResponseModel session;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    cache = _MockCacheService();
    secureStorage = _MockSecureStorage();
    pendingSession = PendingSignupSession();
    dataSource = AuthLocalDataSource(
      cache: cache,
      secureStorage: secureStorage,
      pendingSession: pendingSession,
    );
    session = _tSession();

    when(() => secureStorage.write(any(), any())).thenAnswer((_) async => {});
    when(() => secureStorage.delete(any())).thenAnswer((_) async => {});
    when(() => cache.writeJsonMap(any(), any())).thenAnswer((_) async {});
    when(() => cache.writeString(any(), any())).thenAnswer((_) async {});
    when(() => cache.readString(any())).thenAnswer((_) async => null);
    when(() => cache.delete(any())).thenAnswer((_) async {});
  });

  group('pending signup', () {
    test('should persist the email and start the session', () async {
      final result = await dataSource.savePendingSignupEmail('adam@orbit.app');

      expect(result.isSuccess, isTrue);
      verify(
        () => cache.writeString(
          AppConsts.pendingSignupEmailKey,
          'adam@orbit.app',
        ),
      ).called(1);
      expect(pendingSession.email, 'adam@orbit.app');
    });

    test('should not start the session when the write fails', () async {
      when(() => cache.writeString(any(), any()))
          .thenThrow(const CacheException());

      final result = await dataSource.savePendingSignupEmail('adam@orbit.app');

      expect((result as ResultFailure).failure, isA<CacheFailure>());
      expect(pendingSession.hasPendingSignup, isFalse);
    });

    test('should read the persisted email', () async {
      when(() => cache.readString(AppConsts.pendingSignupEmailKey))
          .thenAnswer((_) async => 'adam@orbit.app');

      final result = await dataSource.readPendingSignupEmail();

      expect((result as Success).data, 'adam@orbit.app');
    });

    test('should map a read failure', () async {
      when(() => cache.readString(any())).thenThrow(const CacheException());

      final result = await dataSource.readPendingSignupEmail();

      expect((result as ResultFailure).failure, isA<CacheFailure>());
    });

    test(
      'should clear the persisted email without ending the session',
      () async {
        pendingSession.start('adam@orbit.app');

        final result = await dataSource.clearCachedPendingSignupEmail();

        expect(result.isSuccess, isTrue);
        verify(() => cache.delete(AppConsts.pendingSignupEmailKey)).called(1);
        expect(pendingSession.email, 'adam@orbit.app');
      },
    );

    test('should clear the persisted email and the session', () async {
      pendingSession.start('adam@orbit.app');

      final result = await dataSource.clearPendingSignup();

      expect(result.isSuccess, isTrue);
      verify(() => cache.delete(AppConsts.pendingSignupEmailKey)).called(1);
      expect(pendingSession.hasPendingSignup, isFalse);
    });

    test('should end the pending flow when a sign-in succeeds', () async {
      pendingSession.start('old@orbit.app');

      final result = await dataSource.saveSession(session);

      expect(result.isSuccess, isTrue);
      verify(() => cache.delete(AppConsts.pendingSignupEmailKey)).called(1);
      expect(pendingSession.hasPendingSignup, isFalse);
    });
  });
}
