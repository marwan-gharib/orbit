import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/network/interceptors/error_interceptor.dart';

class _FailingAdapter implements HttpClientAdapter {
  _FailingAdapter(this.statusCode);

  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return Future.value(
      ResponseBody.fromString(
        jsonEncode({ApiKeys.errorMessageKey: 'backend said no'}),
        statusCode,
      ),
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  Future<DioException> runWithStatus(int statusCode) async {
    final dio = Dio()
      ..httpClientAdapter = _FailingAdapter(statusCode)
      ..options.baseUrl = 'https://api.example.test'
      ..interceptors.add(const ErrorInterceptor());
    try {
      await dio.get(Endpoints.crmOverview);
      fail('Expected the request to fail');
    } on DioException catch (e) {
      return e;
    }
  }

  group('ErrorInterceptor.onError', () {
    test('should classify a 500 response as a server error', () async {
      final err = await runWithStatus(500);

      expect(err.error, isA<ServerErrorException>());
      expect((err.error! as AppException).statusCode, 500);
    });

    test('should classify a 401 response as unauthorized', () async {
      final err = await runWithStatus(401);

      expect(err.error, isA<UnauthorizedException>());
      expect((err.error! as AppException).statusCode, 401);
    });

    test(
      'should keep the DioException as the carrier with the request on it',
      () async {
        final err = await runWithStatus(404);

        expect(err.type, DioExceptionType.badResponse);
        expect(err.requestOptions.path, Endpoints.crmOverview);
        expect(err.error, isA<NotFoundException>());
      },
    );
  });
}
