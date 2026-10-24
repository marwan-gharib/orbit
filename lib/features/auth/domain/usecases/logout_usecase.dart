import 'package:orbit/core/utils/api_result.dart';

import '../repositories/auth_repository.dart';

/// Signs out: the repository revokes the refresh token server-side (when one
/// exists) and always clears the local session. No params — the repository
/// owns token access.
class LogoutUseCase {
  LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<void>> call() => _repository.logout();
}
