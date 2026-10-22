import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';

import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/employee_status_info_entity.dart';
import '../../domain/entities/session_info_entity.dart';
import '../../domain/entities/signup_result_entity.dart';
import '../../domain/enums/employment_status.dart';
import '../../domain/params/login_params.dart';
import '../../domain/params/signup_params.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_data_source.dart';
import '../datasources/remote/auth_remote_data_source.dart';

/// Implements [AuthRepository]: orchestration, persistence policy and error
/// flow only — no business rules, no UI types (DATA-6).
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<ApiResult<AuthSession>> login(LoginParams params) async {
    final result = await _remote.login(params);
    return result.fold((failure) async => ResultFailure(failure), (
      model,
    ) async {
      // Fail loudly when persistence fails (B6): the local data source has
      // already rolled any partial writes back, so the user simply retries.
      final saved = await _local.saveSession(model);
      return saved.fold(
        (failure) => ResultFailure(failure),
        (_) => Success(model.toEntity()),
      );
    });
  }

  @override
  Future<ApiResult<SignupResult>> signup(SignupParams params) async {
    final result = await _remote.signup(params);
    return result.fold((failure) => ResultFailure(failure), (model) async {
      final entity = model.toEntity();
      // Fail loudly when the pending email cannot be persisted: without it
      // the approval flow cannot resume after a restart.
      final saved = await _local.savePendingSignupEmail(entity.email);
      return saved.fold(
        (failure) => ResultFailure(failure),
        (_) => Success(entity),
      );
    });
  }

  @override
  Future<ApiResult<void>> logout() async {
    // §9 / B10: the remote phase never blocks sign-out. Its outcome is
    // irrelevant once the local session is cleared below; failures were
    // already classified and logged by the local/remote data sources.
    final read = await _local.readRefreshToken();
    // A failed read (ERR-3: folded, never unwrapped) means "no token to
    // revoke"; the local clear below still runs.
    final String? token = read.fold<String?>((_) => null, (value) => value);
    if (token != null && token.isNotEmpty) {
      // Outcome ignored (§9/B10): the local clear below always proceeds.
      await _remote.logout(token);
    }
    return _local.clearSession();
  }

  @override
  Future<ApiResult<EmployeeStatusInfo>> getEmployeeStatus() async {
    final cached = await _local.readPendingSignupEmail();
    if (cached case ResultFailure(:final failure)) {
      return ResultFailure(failure);
    }
    final email = cached.dataOrNull;
    if (email == null || email.isEmpty) {
      return const ResultFailure(
        NotFoundFailure(message: 'No pending signup email to check.'),
      );
    }

    final result = await _remote.getEmployeeStatus(email);
    return result.fold((failure) => ResultFailure(failure), (model) async {
      final entity = model.toEntity();
      // A terminal decision ends the persisted flow, but the in-memory
      // session survives so the pending screen can play its moment.
      if (entity.status == EmploymentStatus.approved ||
          entity.status == EmploymentStatus.rejected) {
        await _local.clearCachedPendingSignupEmail();
      }
      return Success(entity);
    });
  }

  @override
  Future<ApiResult<SessionInfo>> getSessionInfo() async {
    final result = await _local.readSessionInfo();
    return result.fold(
      (failure) => ResultFailure(failure),
      (model) => Success(model.toEntity()),
    );
  }
}
