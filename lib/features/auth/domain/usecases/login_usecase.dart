import 'package:orbit/core/utils/api_result.dart';

import '../entities/auth_session_entity.dart';
import '../params/login_params.dart';
import '../repositories/auth_repository.dart';

/// Signs the user in; the repository persists the session on success.
class LoginUseCase {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<AuthSession>> call(LoginParams params) =>
      _repository.login(params);
}
