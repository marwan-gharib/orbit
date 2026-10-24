import 'package:orbit/core/utils/api_result.dart';

import '../entities/google_sign_in_result.dart';
import '../params/google_payload.dart';
import '../repositories/auth_repository.dart';

/// Authenticates with Google identity claims; the repository persists either
/// the user session or the pending signup flag based on the result.
class SignInWithGoogleUseCase {
  SignInWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<GoogleSignInResult>> call(GooglePayload payload) =>
      _repository.signInWithGoogle(payload);
}
