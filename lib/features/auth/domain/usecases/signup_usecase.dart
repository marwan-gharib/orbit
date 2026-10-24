import 'package:orbit/core/utils/api_result.dart';

import '../entities/signup_result_entity.dart';
import '../params/signup_params.dart';
import '../repositories/auth_repository.dart';

/// Creates a pending account and persists its email through the repository.
class SignupUseCase {
  SignupUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<SignupResult>> call(SignupParams params) =>
      _repository.signup(params);
}
