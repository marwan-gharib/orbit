import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/core/local/secure/secure_storage_client.dart';
import 'package:orbit/core/network/interceptors/auth_interceptor.dart';

class _MockSecureStorage extends Mock implements SecureStorageClient {}

class _CapturingAdapter implements HttpClientAdapter {
  final Map<String, dynamic> capturedHeaders = {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    capturedHeaders
      ..clear()
      ..addAll(options.headers);
    return Future.value(ResponseBody.fromString(jsonEncode({'ok': true}), 200));
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _MockSecureStorage secureStorage;
  late _CapturingAdapter adapter;
  late Dio dio;

  setUp(() {
    secureStorage = _MockSecureStorage();
    adapter = _CapturingAdapter();
    dio = Dio()
      ..httpClientAdapter = adapter
      ..options.baseUrl = 'https://api.example.test'
      ..interceptors.add(AuthInterceptor(secureStorage));
  });

  group('AuthInterceptor', () {
    test('should attach the stored token as a Bearer header', () async {
      when(() => secureStorage.read(AppConsts.accessTokenKey))
          .thenAnswer((_) async => 'tok-1');

      await dio.get(Endpoints.crmOverview);

      expect(
        adapter.capturedHeaders[ApiKeys.authorizationHeaderKey],
        'Bearer tok-1',
      );
    });

    test(
      'should send no Authorization header without a stored token',
      () async {
        when(() => secureStorage.read(AppConsts.accessTokenKey))
            .thenAnswer((_) async => null);

        await dio.get(Endpoints.crmOverview);

        expect(
          adapter.capturedHeaders.containsKey(ApiKeys.authorizationHeaderKey),
          isFalse,
        );
      },
    );

    test('should skip the header when the request opts out of auth', () async {
      when(() => secureStorage.read(AppConsts.accessTokenKey))
          .thenAnswer((_) async => 'tok-1');

      await dio.get(
        Endpoints.authLogin,
        options: Options(extra: {ApiKeys.requiresAuthExtraKey: false}),
      );

      expect(
        adapter.capturedHeaders.containsKey(ApiKeys.authorizationHeaderKey),
        isFalse,
      );
      verifyNever(() => secureStorage.read(AppConsts.accessTokenKey));
    });

    test('should still complete the request when the storage throws', () async {
      when(() => secureStorage.read(AppConsts.accessTokenKey))
          .thenThrow(Exception('locked'));

      final response = await dio.get(Endpoints.crmOverview);

      expect(response.statusCode, 200);
      expect(
        adapter.capturedHeaders.containsKey(ApiKeys.authorizationHeaderKey),
        isFalse,
      );
    });
  });
}
