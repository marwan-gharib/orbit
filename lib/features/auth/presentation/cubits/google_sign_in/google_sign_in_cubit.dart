import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/jwt_payload_decoder.dart';
import 'package:orbit/features/auth/data/datasources/google/google_auth_client.dart';
import 'package:orbit/features/auth/domain/entities/google_sign_in_result.dart';
import 'package:orbit/features/auth/domain/usecases/sign_in_with_google_usecase.dart';

import 'google_sign_in_state.dart';

/// Drives the Google SSO authentication workflow.
class GoogleSignInCubit extends Cubit<GoogleSignInState> {
  GoogleSignInCubit(
    this._googleAuthClient,
    this._signInWithGoogleUseCase,
  ) : super(const GoogleSignInIdle());

  final GoogleAuthClient _googleAuthClient;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;

  Future<void> signInWithGoogle() async {
    if (state is GoogleSignInLoading) return;
    emit(const GoogleSignInLoading());

    final authResult = await _googleAuthClient.authenticate();
    if (isClosed) return;

    switch (authResult) {
      case GoogleAuthCancelled():
        emit(const GoogleSignInIdle());
        return;
      case GoogleAuthFailure(:final failure):
        emit(GoogleSignInError(failure));
        return;
      case GoogleAuthSuccess(:final idToken, :final displayName):
        try {
          final payload = decodeGoogleIdToken(idToken, displayName: displayName);
          final result = await _signInWithGoogleUseCase(payload);
          if (isClosed) return;

          result.fold(
            (failure) => emit(GoogleSignInError(failure)),
            (signInResult) {
              switch (signInResult) {
                case GoogleLoggedIn(:final session):
                  emit(GoogleSignInAuthenticated(session));
                case GoogleRegistered(:final signupResult):
                  emit(GoogleSignInPending(signupResult));
              }
            },
          );
        } on FormatException catch (e) {
          emit(GoogleSignInError(ParsingFailure(message: e.message)));
        }
    }
  }
}
