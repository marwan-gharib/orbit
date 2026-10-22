import 'package:orbit/core/utils/api_result.dart';

import '../entities/session_info_entity.dart';
import '../repositories/auth_repository.dart';

/// Reads the local session snapshot for routing decisions (core/router
/// guards later). No params, local data only.
class GetSessionInfoUseCase {
  GetSessionInfoUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<SessionInfo>> call() => _repository.getSessionInfo();
}
