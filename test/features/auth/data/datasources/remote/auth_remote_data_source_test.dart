import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:orbit/features/auth/domain/enums/employment_status.dart';
import 'package:orbit/features/auth/domain/params/signup_params.dart';

class _MockClient extends Mock implements BaseApiClient {}

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

  void stubGet({required String path, Object? body, required Object? answer}) =>
      when(
        () => client.get(
          any(that: equals(path)),
          queryParameters: any(named: 'queryParameters'),
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
          data: any(that: body == null ? isNull : equals(body), named: 'data'),
        ),
      ).thenAnswer((_) async => answer);

  setUp(() {
    client = _MockClient();
    dataSource = AuthRemoteDataSource(client);
  });

  group('signup', () {
    const tSignupBody = <String, Object>{
      ApiKeys.firstNameKey: 'Adam',
      ApiKeys.lastNameKey: 'Orbit',
      ApiKeys.workEmailKey: 'adam@orbit.app',
      ApiKeys.passwordKey: 'secret',
    };

    test(
      'should post the signup wire keys with the public-request extra',
      () async {
        stubPost(
          path: Endpoints.authSignup,
          body: tSignupBody,
          answer: <String, dynamic>{
            ApiKeys.firstNameKey: 'Adam',
            ApiKeys.lastNameKey: 'Orbit',
            ApiKeys.emailKey: 'adam@orbit.app',
          },
        );

        final result = await dataSource.signup(
          const SignupParams(
            firstName: 'Adam',
            lastName: 'Orbit',
            workEmail: 'adam@orbit.app',
            password: 'secret',
          ),
        );

        expect(result.isSuccess, isTrue);
        expect((result as Success).data.email, 'adam@orbit.app');
        verify(
          () => client.post(
            Endpoints.authSignup,
            queryParameters: null,
            headers: null,
            data: tSignupBody,
            extra: const {ApiKeys.requiresAuthExtraKey: false},
          ),
        ).called(1);
      },
    );

    test('should NOT reclassify a signup 401 (only login does)', () async {
      when(
        () => client.post(
          any(),
          queryParameters: any(named: 'queryParameters'),
          headers: any(named: 'headers'),
          data: any(named: 'data'),
          extra: any(named: 'extra'),
        ),
      ).thenThrow(const UnauthorizedException());

      final result = await dataSource.signup(
        const SignupParams(
          firstName: 'A',
          lastName: 'B',
          workEmail: 'a@b.c',
          password: 'secret',
        ),
      );

      expect((result as ResultFailure).failure, isA<UnauthorizedFailure>());
    });
  });

  group('logout', () {
    test('should post the refresh token on the logout endpoint', () async {
      stubPost(
        path: Endpoints.authLogout,
        body: {ApiKeys.refreshKey: 'refresh-1'},
        answer: null,
      );

      final result = await dataSource.logout('refresh-1');

      expect(result.isSuccess, isTrue);
      verify(
        () => client.post(
          Endpoints.authLogout,
          queryParameters: null,
          headers: null,
          data: const <String, Object>{ApiKeys.refreshKey: 'refresh-1'},
          extra: null,
        ),
      ).called(1);
    });
  });

  group('getEmployeeStatus', () {
    test('should GET with the email body and parse the nested user', () async {
      stubGet(
        path: Endpoints.authEmployeeStatus,
        body: const {ApiKeys.emailKey: 'adam@orbit.app'},
        answer: <String, dynamic>{
          ApiKeys.userKey: <String, dynamic>{
            ApiKeys.firstNameKey: 'Adam',
            ApiKeys.lastNameKey: 'Orbit',
            ApiKeys.statusKey: 'approved',
          },
        },
      );

      final result = await dataSource.getEmployeeStatus('adam@orbit.app');

      expect(result.isSuccess, isTrue);
      expect((result as Success).data.status, EmploymentStatus.approved);
      verify(
        () => client.get(
          Endpoints.authEmployeeStatus,
          queryParameters: null,
          headers: null,
          extra: null,
          data: const <String, Object>{ApiKeys.emailKey: 'adam@orbit.app'},
        ),
      ).called(1);
    });

    test('should return the stored failure on transport errors', () async {
      when(
        () => client.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
          data: any(named: 'data'),
        ),
      ).thenThrow(const NotFoundException(statusCode: 404));

      final result = await dataSource.getEmployeeStatus('adam@orbit.app');

      expect((result as ResultFailure).failure, isA<NotFoundFailure>());
    });
  });
}
