import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:orbit/features/auth/domain/params/login_params.dart';

class _MockClient extends Mock implements BaseApiClient {}

const tLoginBody = <String, Object>{
  ApiKeys.emailKey: 'adam@orbit.app',
  ApiKeys.passwordKey: 'secret',
};

const tLoginResponse = <String, dynamic>{
  ApiKeys.accessTokenKey: 'access-1',
  ApiKeys.refreshTokenKey: 'refresh-1',
  ApiKeys.userKey: <String, dynamic>{
    ApiKeys.firstNameKey: 'Adam',
    ApiKeys.lastNameKey: 'Orbit',
    ApiKeys.codeKey: 'EMP-2026-9582',
    ApiKeys.emailKey: 'adam@orbit.app',
    ApiKeys.roleKey: 6,
    ApiKeys.roleNameKey: 'PM',
    ApiKeys.permissionsKey: <Object?>[],
  },
};

void main() {
  late _MockClient client;
  late AuthRemoteDataSource dataSource;

  void stubPost({
    required String path,
    Object? body,
    required Object? answer,
  }) => when(
    () => client.post(
      any(that: equals(path)),
      queryParameters: any(named: 'queryParameters'),
      headers: any(named: 'headers'),
      data: any(that: body == null ? isNull : equals(body), named: 'data'),
      extra: any(named: 'extra'),
    ),
  ).thenAnswer((_) async => answer);

  setUp(() {
    client = _MockClient();
    dataSource = AuthRemoteDataSource(client);
  });

  test(
    'should post the wire body with the public-request extra and parse it',
    () async {
      stubPost(
        path: Endpoints.authLogin,
        body: tLoginBody,
        answer: tLoginResponse,
      );

      final result = await dataSource.login(
        const LoginParams(email: 'adam@orbit.app', password: 'secret'),
      );

      expect(result.isSuccess, isTrue);
      final model = (result as Success).data;
      expect(model.accessToken, 'access-1');
      expect(model.refreshToken, 'refresh-1');
      expect(model.user.email, 'adam@orbit.app');
      verify(
        () => client.post(
          Endpoints.authLogin,
          queryParameters: null,
          headers: null,
          data: tLoginBody,
          extra: const {ApiKeys.requiresAuthExtraKey: false},
        ),
      ).called(1);
    },
  );

  test(
    'should reclassify a login 401 into InvalidCredentialsFailure (B4)',
    () async {
      when(
        () => client.post(
          Endpoints.authLogin,
          queryParameters: null,
          headers: null,
          data: tLoginBody,
          extra: const {ApiKeys.requiresAuthExtraKey: false},
        ),
      ).thenThrow(
        const UnauthorizedException(
          message: 'expired',
          serverMessage: 'Invalid credentials.',
        ),
      );

      final result = await dataSource.login(
        const LoginParams(email: 'adam@orbit.app', password: 'secret'),
      );

      expect(result.isFailure, isTrue);
      final failure = (result as ResultFailure).failure;
      expect(failure, isA<InvalidCredentialsFailure>());
      expect(
        (failure as InvalidCredentialsFailure).serverMessage,
        'Invalid credentials.',
      );
      expect(failure.statusCode, 401);
    },
  );

  test('should keep a network failure untouched', () async {
    when(
      () => client.post(
        any(),
        queryParameters: any(named: 'queryParameters'),
        headers: any(named: 'headers'),
        data: any(named: 'data'),
        extra: any(named: 'extra'),
      ),
    ).thenThrow(const NetworkException(reason: NetworkErrorReason.noInternet));

    final result = await dataSource.login(
      const LoginParams(email: 'adam@orbit.app', password: 'secret'),
    );

    final failure = (result as ResultFailure).failure;
    expect(failure, isA<NetworkFailure>());
    expect((failure as NetworkFailure).reason, NetworkErrorReason.noInternet);
  });

  test('should keep a handle-provided validation failure untouched', () async {
    when(
      () => client.post(
        any(),
        queryParameters: any(named: 'queryParameters'),
        headers: any(named: 'headers'),
        data: any(named: 'data'),
        extra: any(named: 'extra'),
      ),
    ).thenThrow(
      ValidationException(
        fieldErrors: {
          ApiKeys.emailKey: ['Taken.'],
        },
      ),
    );

    final result = await dataSource.login(
      const LoginParams(email: 'adam@orbit.app', password: 'secret'),
    );

    final failure = (result as ResultFailure).failure;
    expect(failure, isA<ValidationFailure>());
    expect((failure as ValidationFailure).fieldErrors, {
      ApiKeys.emailKey: ['Taken.'],
    });
  });

  test(
    'should classify a non-map response body as a parsing failure',
    () async {
      stubPost(
        path: Endpoints.authLogin,
        body: tLoginBody,
        answer: 'not-a-map',
      );

      final result = await dataSource.login(
        const LoginParams(email: 'adam@orbit.app', password: 'secret'),
      );

      expect((result as ResultFailure).failure, isA<ParsingFailure>());
    },
  );
}
