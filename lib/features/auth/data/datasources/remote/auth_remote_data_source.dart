import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/core/errors/error_mapper.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/core/utils/api_result.dart';

import '../../../domain/params/login_params.dart';
import '../../../domain/params/signup_params.dart';
import '../../models/employee_status_response_model.dart';
import '../../models/login_response_model.dart';
import '../../models/signup_response_model.dart';

/// The contract seam for the whole auth API (B1): endpoints, verbs, request
/// bodies and the unusual GET-with-body live here and nowhere else, so
/// switching the status check to a query param or POST is a one-place change.
///
/// Emits `AppException`s (never raw Dio errors) which are mapped to
/// `Failure`s right here — this data source also catches `Error`s, so a
/// malformed payload becomes a `ParsingFailure`, never a crash (DATA-3).
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final BaseApiClient _client;

  /// Sign-in/public requests must never carry a (stale) Bearer token.
  static const Map<String, Object> _publicRequest = {
    ApiKeys.requiresAuthExtraKey: false,
  };

  Future<ApiResult<LoginResponseModel>> login(LoginParams params) async {
    try {
      final body = await _client.post(
        Endpoints.authLogin,
        data: <String, Object>{
          ApiKeys.emailKey: params.email,
          ApiKeys.passwordKey: params.password,
        },
        extra: _publicRequest,
      );
      return Success(LoginResponseModel.fromJson(_asMap(body)));
    } on Object catch (error, stackTrace) {
      return ResultFailure(_failure(error, stackTrace, isLogin: true));
    }
  }

  Future<ApiResult<SignupResponseModel>> signup(SignupParams params) async {
    try {
      final body = await _client.post(
        Endpoints.authSignup,
        data: <String, Object>{
          ApiKeys.firstNameKey: params.firstName,
          ApiKeys.lastNameKey: params.lastName,
          ApiKeys.workEmailKey: params.workEmail,
          ApiKeys.passwordKey: params.password,
        },
        extra: _publicRequest,
      );
      return Success(SignupResponseModel.fromJson(_asMap(body)));
    } on Object catch (error, stackTrace) {
      return ResultFailure(_failure(error, stackTrace, isLogin: false));
    }
  }

  Future<ApiResult<void>> logout(String refreshToken) async {
    try {
      await _client.post(
        Endpoints.authLogout,
        data: <String, Object>{ApiKeys.refreshKey: refreshToken},
      );
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }

  Future<ApiResult<EmployeeStatusResponseModel>> getEmployeeStatus(
    String email,
  ) async {
    try {
      // GET with a JSON body, kept per backend contract (backend-confirmation
      // item B1). The core `get(data)` seam exists for exactly this.
      final body = await _client.get(
        Endpoints.authEmployeeStatus,
        data: <String, Object>{ApiKeys.emailKey: email},
      );
      return Success(EmployeeStatusResponseModel.fromJson(_asMap(body)));
    } on Object catch (error, stackTrace) {
      return ResultFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }

  Map<String, dynamic> _asMap(Object? body) {
    if (body is Map) return Map<String, dynamic>.from(body);
    throw const FormatException('Auth response body was not a JSON object.');
  }

  /// Generic mapping through `ErrorMapper`; on the login call a 401 is
  /// reclassified (B4) because it means wrong credentials, not an expired
  /// session — the backend text stays available via `serverMessage`.
  Failure _failure(
    Object error,
    StackTrace stackTrace, {
    required bool isLogin,
  }) {
    final failure = ErrorMapper.toFailure(error, stackTrace);
    if (isLogin && failure is UnauthorizedFailure) {
      return InvalidCredentialsFailure(
        message: failure.message,
        statusCode: failure.statusCode,
        serverMessage: failure.serverMessage,
        errorCode: failure.errorCode,
      );
    }
    return failure;
  }
}
