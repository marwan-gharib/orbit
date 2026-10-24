import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
import 'package:orbit/core/network/dio_api_client.dart';

import 'package:orbit/core/network/refresh/token_refresh_service.dart';
import 'package:orbit/core/network/session/session_cleaner.dart';
import 'package:orbit/core/network/session/session_expired_notifier.dart';

class _MockSecureStorage extends Mock implements SecureStorageClient {}
class _MockTokenRefreshService extends Mock implements TokenRefreshService {}
class _MockSessionCleaner extends Mock implements SessionCleaner {}

/// Records the outgoing request; the body/headers are asserted in tests.
class _RecordingAdapter implements HttpClientAdapter {
  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    return ResponseBody.fromString(
      '{"ok":true}',
      200,
      headers: const {
        Headers.jsonContentType: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  final secureStorage = _MockSecureStorage();
  late _RecordingAdapter adapter;
  late DioApiClient client;
  late TokenRefreshService refreshService;
  late SessionCleaner sessionCleaner;
  late SessionExpiredNotifier sessionExpiredNotifier;

  setUpAll(() {
    when(() => secureStorage.read(any())).thenAnswer((_) async => 'token');
  });

  setUp(() {
    adapter = _RecordingAdapter();
    refreshService = _MockTokenRefreshService();
    sessionCleaner = _MockSessionCleaner();
    sessionExpiredNotifier = SessionExpiredNotifier();

    final dio = DioApiClient.buildDio(
      baseUrl: 'https://api.example.com',
      secureStorage: secureStorage,
      localeProvider: () => 'en',
      tokenRefreshService: refreshService,
      sessionCleaner: sessionCleaner,
      sessionExpiredNotifier: sessionExpiredNotifier,
    );
    dio.httpClientAdapter = adapter;
    client = DioApiClient(dio);
  });

  test('should send the static client-type header on every request', () async {
    await client.post(Endpoints.authLogin);

    expect(
      adapter.lastOptions?.headers[ApiKeys.clientTypeHeaderKey],
      ApiKeys.clientTypeHeaderValue,
    );
  });

  test('should attach the stored bearer token by default', () async {
    await client.post(Endpoints.authLogin);

    expect(
      adapter.lastOptions?.headers[ApiKeys.authorizationHeaderKey],
      'Bearer token',
    );
  });

  test('should skip the bearer token when the request opts out', () async {
    await client.post(
      Endpoints.authLogin,
      extra: const {ApiKeys.requiresAuthExtraKey: false},
    );

    expect(
      adapter.lastOptions?.headers.containsKey(ApiKeys.authorizationHeaderKey),
      isFalse,
    );
  });

  test('should send a request body on GET when data is provided', () async {
    const tBody = <String, Object>{ApiKeys.emailKey: 'a@b.c'};
    await client.get(Endpoints.authEmployeeStatus, data: tBody);

    expect(adapter.lastOptions?.method, 'GET');
    expect(adapter.lastOptions?.data, tBody);
  });
}
