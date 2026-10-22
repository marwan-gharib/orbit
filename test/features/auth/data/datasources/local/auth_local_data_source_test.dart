import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/local/cache/cache_service.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
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
  late AuthLocalDataSource dataSource;
  late LoginResponseModel session;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    cache = _MockCacheService();
    secureStorage = _MockSecureStorage();
    dataSource = AuthLocalDataSource(
      cache: cache,
      secureStorage: secureStorage,
    );
    session = _tSession();

    when(() => secureStorage.write(any(), any())).thenAnswer((_) async => {});
    when(() => secureStorage.delete(any())).thenAnswer((_) async => {});
    when(() => cache.writeJsonMap(any(), any())).thenAnswer((_) async {});
    when(() => cache.delete(any())).thenAnswer((_) async {});
  });

  group('saveSession', () {
    test(
      'should write both tokens to secure storage and the user to cache',
      () async {
        final result = await dataSource.saveSession(session);
        final userMap = session.user.toJson();

        expect(result.isSuccess, isTrue);
        verifyInOrder([
          () => secureStorage.write(AppConsts.accessTokenKey, 'access-1'),
          () => secureStorage.write(AppConsts.refreshTokenKey, 'refresh-1'),
          () => cache.writeJsonMap(AppConsts.authUserCacheKey, userMap),
        ]);
      },
    );

    test('should never write token keys into the cache (A2)', () async {
      await dataSource.saveSession(session);

      final cached =
          verify(
                () => cache.writeJsonMap(
                  AppConsts.authUserCacheKey,
                  captureAny(),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(cached.containsKey(ApiKeys.accessTokenKey), isFalse);
      expect(cached.containsKey(ApiKeys.refreshTokenKey), isFalse);
    });

    test(
      'should roll everything back when the last write fails (B6)',
      () async {
        when(() => cache.writeJsonMap(any(), any()))
            .thenThrow(const CacheException());

        final result = await dataSource.saveSession(session);

        expect(result.isFailure, isTrue);
        expect((result as ResultFailure).failure, isA<CacheFailure>());
        verifyInOrder([
          () => secureStorage.write(AppConsts.accessTokenKey, 'access-1'),
          () => secureStorage.write(AppConsts.refreshTokenKey, 'refresh-1'),
          () => cache.writeJsonMap(any(), any()),
          () => secureStorage.delete(AppConsts.accessTokenKey),
          () => secureStorage.delete(AppConsts.refreshTokenKey),
          () => cache.delete(AppConsts.authUserCacheKey),
        ]);
      },
    );

    test('should roll back when only the first token write fails', () async {
      when(() => secureStorage.write(AppConsts.accessTokenKey, any()))
          .thenThrow(const SecureStorageException());

      final result = await dataSource.saveSession(session);

      expect(result.isFailure, isTrue);
      expect((result as ResultFailure).failure, isA<StorageFailure>());
      verify(() => secureStorage.delete(AppConsts.accessTokenKey)).called(1);
      verify(() => secureStorage.delete(AppConsts.refreshTokenKey)).called(1);
    });
  });

  group('clearSession', () {
    test('should delete both tokens and the cached user', () async {
      final result = await dataSource.clearSession();

      expect(result.isSuccess, isTrue);
      verifyInOrder([
        () => secureStorage.delete(AppConsts.accessTokenKey),
        () => secureStorage.delete(AppConsts.refreshTokenKey),
        () => cache.delete(AppConsts.authUserCacheKey),
      ]);
    });

    test('should map a delete failure to a failure result', () async {
      when(() => secureStorage.delete(AppConsts.accessTokenKey))
          .thenThrow(const SecureStorageException());

      final result = await dataSource.clearSession();

      expect(result.isFailure, isTrue);
      expect((result as ResultFailure).failure, isA<StorageFailure>());
    });
  });

  group('readRefreshToken', () {
    test('should return null when no token was ever saved', () async {
      when(() => secureStorage.read(AppConsts.refreshTokenKey))
          .thenAnswer((_) async => null);

      final result = await dataSource.readRefreshToken();

      expect((result as Success).data, isNull);
    });

    test('should return the stored refresh token', () async {
      when(() => secureStorage.read(AppConsts.refreshTokenKey))
          .thenAnswer((_) async => 'refresh-1');

      final result = await dataSource.readRefreshToken();

      expect((result as Success).data, 'refresh-1');
    });

    test('should map storage failures', () async {
      when(() => secureStorage.read(AppConsts.refreshTokenKey))
          .thenThrow(const SecureStorageException());

      final result = await dataSource.readRefreshToken();

      expect((result as ResultFailure).failure, isA<StorageFailure>());
    });
  });

  group('readSessionInfo', () {
    test(
      'should authenticate on a stored token and carry the cached user',
      () async {
        when(() => secureStorage.read(AppConsts.accessTokenKey))
            .thenAnswer((_) async => 'access-1');
        when(() => cache.readJsonMap(AppConsts.authUserCacheKey))
            .thenAnswer((_) async => session.user.toJson());

        final result = await dataSource.readSessionInfo();

        final model = (result as Success).data;
        expect(model.isAuthenticated, isTrue);
        expect(model.user, isNotNull);
        expect(model.user!.email, 'adam@orbit.app');
      },
    );

    test('should treat an empty token as signed out', () async {
      when(() => secureStorage.read(AppConsts.accessTokenKey))
          .thenAnswer((_) async => '');

      final result = await dataSource.readSessionInfo();

      expect((result as Success).data.isAuthenticated, isFalse);
    });

    test(
      'should keep authentication when the cached user is corrupt (B5)',
      () async {
        when(() => secureStorage.read(AppConsts.accessTokenKey))
            .thenAnswer((_) async => 'access-1');
        when(() => cache.readJsonMap(AppConsts.authUserCacheKey))
            .thenThrow(const CacheException());

        final result = await dataSource.readSessionInfo();

        final model = (result as Success).data;
        expect(model.isAuthenticated, isTrue);
        expect(model.user, isNull);
      },
    );

    test(
      'should keep authentication when the cached user shape changed',
      () async {
        when(() => secureStorage.read(AppConsts.accessTokenKey))
            .thenAnswer((_) async => 'access-1');
        when(
          () => cache.readJsonMap(AppConsts.authUserCacheKey),
        ).thenAnswer((_) async => <String, dynamic>{ApiKeys.firstNameKey: 42});

        final result = await dataSource.readSessionInfo();

        final model = (result as Success).data;
        expect(model.isAuthenticated, isTrue);
        expect(model.user, isNull);
      },
    );

    test('should map a secure-storage failure', () async {
      when(() => secureStorage.read(AppConsts.accessTokenKey))
          .thenThrow(const SecureStorageException());

      final result = await dataSource.readSessionInfo();

      expect((result as ResultFailure).failure, isA<StorageFailure>());
    });
  });
}
