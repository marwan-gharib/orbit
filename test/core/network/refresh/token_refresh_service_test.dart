import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
import 'package:orbit/core/network/refresh/refresh_dio_client.dart';
import 'package:orbit/core/network/refresh/token_refresh_service_impl.dart';
import 'package:orbit/core/network/session/session_expired_notifier.dart';

class _MockSecureStorage extends Mock implements SecureStorageClient {}

class _FakeAdapter implements HttpClientAdapter {
  late ResponseBody Function(RequestOptions options) onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return onFetch(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _MockSecureStorage secureStorage;
  late SessionExpiredNotifier sessionNotifier;
  late _FakeAdapter adapter;
  late Dio refreshDio;
  late TokenRefreshServiceImpl service;

  setUp(() {
    secureStorage = _MockSecureStorage();
    sessionNotifier = SessionExpiredNotifier();
    adapter = _FakeAdapter();

    refreshDio = RefreshDioClient.create(baseUrl: 'https://api.example.com');
    refreshDio.httpClientAdapter = adapter;

    service = TokenRefreshServiceImpl(
      refreshDio: refreshDio,
      secureStorage: secureStorage,
      sessionNotifier: sessionNotifier,
    );

    when(() => secureStorage.write(any(), any())).thenAnswer((_) async {});
  });

  ResponseBody jsonResponse(Map<String, dynamic> data, int statusCode) {
    return ResponseBody.fromString(
      jsonEncode(data),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  group('TokenRefreshService', () {
    test('S-01: throws SessionExpiredException immediately if refresh token is null or empty in storage', () async {
      when(() => secureStorage.read(AppConsts.refreshTokenKey))
          .thenAnswer((_) async => null);

      expect(
        () => service.refresh(capturedGeneration: 0),
        throwsA(isA<SessionExpiredException>()),
      );

      when(() => secureStorage.read(AppConsts.refreshTokenKey))
          .thenAnswer((_) async => '   ');

      expect(
        () => service.refresh(capturedGeneration: 0),
        throwsA(isA<SessionExpiredException>()),
      );
    });

    test('S-02: on 200 with "access", writes token to storage and returns token string', () async {
      when(() => secureStorage.read(AppConsts.refreshTokenKey))
          .thenAnswer((_) async => 'valid_refresh_token');

      adapter.onFetch = (options) {
        expect(options.path, Endpoints.authRefresh);
        final body = options.data as Map;
        expect(body[ApiKeys.refreshKey], 'valid_refresh_token');
        return jsonResponse({ApiKeys.refreshAccessKey: 'new_access_token'}, 200);
      };

      final result = await service.refresh(capturedGeneration: 0);

      expect(result, 'new_access_token');
      verify(() => secureStorage.write(AppConsts.accessTokenKey, 'new_access_token')).called(1);
      verifyNever(() => secureStorage.write(AppConsts.refreshTokenKey, any()));
    });

    test('S-03: on 200 with "access" and "refresh", writes both tokens to storage (rotation)', () async {
      when(() => secureStorage.read(AppConsts.refreshTokenKey))
          .thenAnswer((_) async => 'valid_refresh_token');

      adapter.onFetch = (options) {
        return jsonResponse({
          ApiKeys.refreshAccessKey: 'new_access_token',
          ApiKeys.refreshKey: 'new_refresh_token',
        }, 200);
      };

      final result = await service.refresh(capturedGeneration: 0);

      expect(result, 'new_access_token');
      verify(() => secureStorage.write(AppConsts.accessTokenKey, 'new_access_token')).called(1);
      verify(() => secureStorage.write(AppConsts.refreshTokenKey, 'new_refresh_token')).called(1);
    });

    test('S-04: on 401 response from refresh endpoint, throws SessionExpiredException', () async {
      when(() => secureStorage.read(AppConsts.refreshTokenKey))
          .thenAnswer((_) async => 'expired_refresh_token');

      adapter.onFetch = (options) {
        return jsonResponse({'detail': 'Token expired'}, 401);
      };

      expect(
        () => service.refresh(capturedGeneration: 0),
        throwsA(isA<SessionExpiredException>()),
      );
    });

    test('S-05: on 400 response from refresh endpoint, throws SessionExpiredException', () async {
      when(() => secureStorage.read(AppConsts.refreshTokenKey))
          .thenAnswer((_) async => 'invalid_refresh_token');

      adapter.onFetch = (options) {
        return jsonResponse({'error': 'Token invalid'}, 400);
      };

      expect(
        () => service.refresh(capturedGeneration: 0),
        throwsA(isA<SessionExpiredException>()),
      );
    });

    test('S-06: on 500 response from refresh endpoint, throws ServerErrorException without writing storage', () async {
      when(() => secureStorage.read(AppConsts.refreshTokenKey))
          .thenAnswer((_) async => 'valid_refresh_token');

      adapter.onFetch = (options) {
        return jsonResponse({'message': 'Internal Server Error'}, 500);
      };

      expect(
        () => service.refresh(capturedGeneration: 0),
        throwsA(isA<ServerErrorException>()),
      );
      verifyNever(() => secureStorage.write(any(), any()));
    });

    test('S-07: on connection timeout, throws NetworkException without writing storage', () async {
      when(() => secureStorage.read(AppConsts.refreshTokenKey))
          .thenAnswer((_) async => 'valid_refresh_token');

      adapter.onFetch = (options) {
        throw DioException.connectionTimeout(
          timeout: const Duration(seconds: 5),
          requestOptions: options,
        );
      };

      expect(
        () => service.refresh(capturedGeneration: 0),
        throwsA(isA<NetworkException>()),
      );
      verifyNever(() => secureStorage.write(any(), any()));
    });

    test('S-08: on 200 with missing "access" key, throws ServerErrorException', () async {
      when(() => secureStorage.read(AppConsts.refreshTokenKey))
          .thenAnswer((_) async => 'valid_refresh_token');

      adapter.onFetch = (options) {
        return jsonResponse({'wrong_key': 'abc'}, 200);
      };

      expect(
        () => service.refresh(capturedGeneration: 0),
        throwsA(isA<ServerErrorException>()),
      );
      verifyNever(() => secureStorage.write(any(), any()));
    });

    test('S-09: if session generation changed in flight, throws StaleSessionException without writing storage', () async {
      when(() => secureStorage.read(AppConsts.refreshTokenKey))
          .thenAnswer((_) async => 'valid_refresh_token');

      adapter.onFetch = (options) {
        // Simulate a logout happening while refresh HTTP call is pending
        sessionNotifier.incrementGeneration();
        return jsonResponse({ApiKeys.refreshAccessKey: 'late_access_token'}, 200);
      };

      expect(
        () => service.refresh(capturedGeneration: 0),
        throwsA(isA<StaleSessionException>()),
      );
      verifyNever(() => secureStorage.write(any(), any()));
    });
  });
}
