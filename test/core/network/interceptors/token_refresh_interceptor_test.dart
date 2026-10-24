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
import 'package:orbit/core/network/dio_api_client.dart';
import 'package:orbit/core/network/interceptors/token_refresh_interceptor.dart';
import 'package:orbit/core/network/refresh/token_refresh_service.dart';
import 'package:orbit/core/network/session/session_cleaner.dart';
import 'package:orbit/core/network/session/session_expired_notifier.dart';

class _MockSecureStorage extends Mock implements SecureStorageClient {}
class _MockTokenRefreshService extends Mock implements TokenRefreshService {}
class _MockSessionCleaner extends Mock implements SessionCleaner {}

class _TestAdapter implements HttpClientAdapter {
  late Future<ResponseBody> Function(RequestOptions options) onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return onFetch(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(Map<String, dynamic> data, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  late _MockSecureStorage secureStorage;
  late _MockTokenRefreshService refreshService;
  late _MockSessionCleaner sessionCleaner;
  late SessionExpiredNotifier sessionNotifier;
  late _TestAdapter adapter;
  late Dio dio;
  late TokenRefreshInterceptor interceptor;

  setUp(() {
    secureStorage = _MockSecureStorage();
    refreshService = _MockTokenRefreshService();
    sessionCleaner = _MockSessionCleaner();
    sessionNotifier = SessionExpiredNotifier();
    adapter = _TestAdapter();

    dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
    dio.httpClientAdapter = adapter;

    interceptor = TokenRefreshInterceptor(
      dio: dio,
      secureStorage: secureStorage,
      refreshService: refreshService,
      sessionCleaner: sessionCleaner,
      sessionExpiredNotifier: sessionNotifier,
    );
    dio.interceptors.add(interceptor);

    when(() => secureStorage.read(AppConsts.accessTokenKey))
        .thenAnswer((_) async => 'old_access_token');
    when(() => sessionCleaner.clearSession()).thenAnswer((_) async {});
  });

  group('TokenRefreshInterceptor (Unit & FIFO Behavior)', () {
    test('T-01: single-flight: concurrent 401s trigger exactly 1 refresh call', () async {
      when(() => refreshService.refresh(capturedGeneration: any(named: 'capturedGeneration')))
          .thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return 'new_access_token';
      });

      var requestCount = 0;
      adapter.onFetch = (options) async {
        requestCount++;
        final authHeader = options.headers[ApiKeys.authorizationHeaderKey];
        if (authHeader == 'Bearer old_access_token') {
          return _jsonResponse({'error': 'Unauthorized'}, 401);
        }
        return _jsonResponse({'data': 'success'}, 200);
      };

      final futures = List.generate(
        5,
        (_) => dio.get<dynamic>(
          '/api/projects/',
          options: Options(headers: {ApiKeys.authorizationHeaderKey: 'Bearer old_access_token'}),
        ),
      );

      final responses = await Future.wait(futures);

      for (final res in responses) {
        expect(res.statusCode, 200);
      }
      verify(() => refreshService.refresh(capturedGeneration: any(named: 'capturedGeneration'))).called(1);
      // 5 initial 401s + 5 retries with new token = 10 calls
      expect(requestCount, 10);
    });

    test('T-02: retry constraint: a second 401 after retry fails without a second refresh', () async {
      when(() => refreshService.refresh(capturedGeneration: any(named: 'capturedGeneration')))
          .thenAnswer((_) async => 'new_access_token');

      adapter.onFetch = (options) async {
        return _jsonResponse({'error': 'Still 401'}, 401);
      };

      await expectLater(
        () => dio.get<dynamic>(
          '/api/projects/',
          options: Options(headers: {ApiKeys.authorizationHeaderKey: 'Bearer old_access_token'}),
        ),
        throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 401)),
      );

      verify(() => refreshService.refresh(capturedGeneration: any(named: 'capturedGeneration'))).called(1);
    });

    test('T-03: excluded endpoints pass 401 through untouched without refresh', () async {
      adapter.onFetch = (options) async {
        return _jsonResponse({'error': 'Invalid credentials'}, 401);
      };

      await expectLater(
        () => dio.post<dynamic>(
          Endpoints.authLogin,
          options: Options(headers: {ApiKeys.authorizationHeaderKey: 'Bearer old_access_token'}),
        ),
        throwsA(isA<DioException>()),
      );

      verifyNever(() => refreshService.refresh(capturedGeneration: any(named: 'capturedGeneration')));
    });

    test('T-04: unauthenticated requests lacking Authorization header pass through untouched', () async {
      adapter.onFetch = (options) async {
        return _jsonResponse({'error': 'Unauthorized'}, 401);
      };

      await expectLater(
        () => dio.get<dynamic>('/api/public/'),
        throwsA(isA<DioException>()),
      );

      verifyNever(() => refreshService.refresh(capturedGeneration: any(named: 'capturedGeneration')));
    });

    test('T-05: network failure during refresh preserves session and passes error', () async {
      when(() => refreshService.refresh(capturedGeneration: any(named: 'capturedGeneration')))
          .thenThrow(const NetworkException(reason: NetworkErrorReason.noInternet));

      adapter.onFetch = (options) async {
        return _jsonResponse({'error': 'Unauthorized'}, 401);
      };

      await expectLater(
        () => dio.get<dynamic>(
          '/api/projects/',
          options: Options(headers: {ApiKeys.authorizationHeaderKey: 'Bearer old_access_token'}),
        ),
        throwsA(isA<DioException>()),
      );

      verifyNever(() => sessionCleaner.clearSession());
      expect(sessionNotifier.isExpired, isFalse);
    });

    test('T-06: terminal rejection during refresh calls SessionCleaner and fires signalExpired', () async {
      when(() => refreshService.refresh(capturedGeneration: any(named: 'capturedGeneration')))
          .thenThrow(const SessionExpiredException());

      adapter.onFetch = (options) async {
        return _jsonResponse({'error': 'Unauthorized'}, 401);
      };

      await expectLater(
        () => dio.get<dynamic>(
          '/api/projects/',
          options: Options(headers: {ApiKeys.authorizationHeaderKey: 'Bearer old_access_token'}),
        ),
        throwsA(isA<DioException>().having((e) => e.error, 'error', isA<SessionExpiredException>())),
      );

      verify(() => sessionCleaner.clearSession()).called(1);
      expect(sessionNotifier.isExpired, isTrue);
    });

    test('T-07: token already changed optimization retries directly without refresh call', () async {
      when(() => secureStorage.read(AppConsts.accessTokenKey))
          .thenAnswer((_) async => 'newer_token_already_stored');

      adapter.onFetch = (options) async {
        final authHeader = options.headers[ApiKeys.authorizationHeaderKey];
        if (authHeader == 'Bearer old_access_token') {
          return _jsonResponse({'error': 'Unauthorized'}, 401);
        }
        expect(authHeader, 'Bearer newer_token_already_stored');
        return _jsonResponse({'ok': true}, 200);
      };

      final response = await dio.get<dynamic>(
        '/api/projects/',
        options: Options(headers: {ApiKeys.authorizationHeaderKey: 'Bearer old_access_token'}),
      );

      expect(response.statusCode, 200);
      verifyNever(() => refreshService.refresh(capturedGeneration: any(named: 'capturedGeneration')));
    });

    test('T-08: stale session exception fails neutrally without clearing session', () async {
      when(() => refreshService.refresh(capturedGeneration: any(named: 'capturedGeneration')))
          .thenThrow(const StaleSessionException());

      adapter.onFetch = (options) async {
        return _jsonResponse({'error': 'Unauthorized'}, 401);
      };

      await expectLater(
        () => dio.get<dynamic>(
          '/api/projects/',
          options: Options(headers: {ApiKeys.authorizationHeaderKey: 'Bearer old_access_token'}),
        ),
        throwsA(isA<DioException>().having((e) => e.error, 'error', isA<StaleSessionException>())),
      );

      verifyNever(() => sessionCleaner.clearSession());
      expect(sessionNotifier.isExpired, isFalse);
    });
  });

  group('DioApiClient.buildDio End-to-End Interceptor Order Tests', () {
    test('T-10: real Dio stack refreshes and retries successfully', () async {
      final realAdapter = _TestAdapter();
      when(() => refreshService.refresh(capturedGeneration: any(named: 'capturedGeneration')))
          .thenAnswer((_) async {
        when(() => secureStorage.read(AppConsts.accessTokenKey))
            .thenAnswer((_) async => 'refreshed_bearer');
        return 'refreshed_bearer';
      });

      realAdapter.onFetch = (options) async {
        final auth = options.headers[ApiKeys.authorizationHeaderKey];
        if (auth == 'Bearer old_access_token') {
          return _jsonResponse({'detail': 'Token expired'}, 401);
        }
        if (auth == 'Bearer refreshed_bearer') {
          return _jsonResponse({'projects': ['Alpha', 'Beta']}, 200);
        }
        return _jsonResponse({'error': 'Unknown'}, 500);
      };

      final realDio = DioApiClient.buildDio(
        baseUrl: 'https://api.example.com',
        secureStorage: secureStorage,
        localeProvider: () => 'en',
        tokenRefreshService: refreshService,
        sessionCleaner: sessionCleaner,
        sessionExpiredNotifier: sessionNotifier,
      );
      realDio.httpClientAdapter = realAdapter;
      final apiClient = DioApiClient(realDio);

      final result = await apiClient.get('/api/projects/');

      expect(result, isA<Map>());
      expect((result as Map)['projects'], ['Alpha', 'Beta']);
      verify(() => refreshService.refresh(capturedGeneration: any(named: 'capturedGeneration'))).called(1);
    });

    test('T-11: real Dio stack with rejected refresh terminates session cleanly', () async {
      final realAdapter = _TestAdapter();
      when(() => refreshService.refresh(capturedGeneration: any(named: 'capturedGeneration')))
          .thenThrow(const SessionExpiredException());

      realAdapter.onFetch = (options) async {
        return _jsonResponse({'detail': 'Token expired'}, 401);
      };

      final realDio = DioApiClient.buildDio(
        baseUrl: 'https://api.example.com',
        secureStorage: secureStorage,
        localeProvider: () => 'en',
        tokenRefreshService: refreshService,
        sessionCleaner: sessionCleaner,
        sessionExpiredNotifier: sessionNotifier,
      );
      realDio.httpClientAdapter = realAdapter;
      final apiClient = DioApiClient(realDio);

      await expectLater(
        () => apiClient.get('/api/projects/'),
        throwsA(isA<SessionExpiredException>()),
      );

      verify(() => sessionCleaner.clearSession()).called(1);
      expect(sessionNotifier.isExpired, isTrue);
    });
  });
}
