import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
import 'package:orbit/core/network/dio_api_client.dart';

class _MockSecureStorage extends Mock implements SecureStorageClient {}

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
  // The interceptor reads the token from the shared secure-storage constant
  // (AppConsts.accessTokenKey); the mock answers for exactly that key.
  final secureStorage = _MockSecureStorage();
  late _RecordingAdapter adapter;
  late DioApiClient client;

  setUpAll(() {
    when(() => secureStorage.read(any())).thenAnswer((_) async => 'token');
  });

  setUp(() {
    adapter = _RecordingAdapter();
    final dio = DioApiClient.buildDio(
      baseUrl: 'https://api.example.com',
      secureStorage: secureStorage,
      localeProvider: () => 'en',
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
