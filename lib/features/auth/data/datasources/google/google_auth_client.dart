import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:orbit/core/errors/error_mapper.dart';
import 'package:orbit/core/errors/failures.dart';

/// Result hierarchy representing the outcome of a Google Sign-In attempt.
///
/// Decouples caller from `package:google_sign_in` types.
sealed class GoogleAuthResult {
  const GoogleAuthResult();
}

final class GoogleAuthSuccess extends GoogleAuthResult {
  const GoogleAuthSuccess({
    required this.idToken,
    this.displayName,
    this.email,
  });

  final String idToken;
  final String? displayName;
  final String? email;
}

final class GoogleAuthCancelled extends GoogleAuthResult {
  const GoogleAuthCancelled();
}

final class GoogleAuthFailure extends GoogleAuthResult {
  const GoogleAuthFailure(this.failure);

  final Failure failure;
}

/// Boundary for Google authentication interactions.

/// Concrete implementation delegating to [GoogleSignIn.instance].
class GoogleAuthClient {
  GoogleAuthClient({GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final GoogleSignIn _googleSignIn;

  Future<GoogleAuthResult> authenticate() async {
    try {
      // Clear local cached credential so account chooser is presented every time.
      try {
        await _googleSignIn.signOut();
      } on Object {
        // Best-effort sign-out; failure to clear local state shouldn't block sign-in.
      }

      final account = await _googleSignIn.authenticate();
      final auth = account.authentication;
      final idToken = auth.idToken;

      if (idToken == null || idToken.trim().isEmpty) {
        debugPrint(
          '[GoogleAuthClient] idToken is null. Check SHA-1 fingerprint and client registration.',
        );
        return const GoogleAuthFailure(
          UnknownFailure(
            message: 'Google Sign-In failed: idToken was not returned by the provider.',
          ),
        );
      }

      return GoogleAuthSuccess(
        idToken: idToken,
        displayName: account.displayName,
        email: account.email,
      );
    } on GoogleSignInException catch (exception) {
      if (exception.code == GoogleSignInExceptionCode.canceled) {
        return const GoogleAuthCancelled();
      }
      return GoogleAuthFailure(
        ErrorMapper.toFailure(exception, StackTrace.current),
      );
    } on Object catch (error, stackTrace) {
      final errorString = error.toString().toLowerCase();
      if (errorString.contains('cancel')) {
        return const GoogleAuthCancelled();
      }
      return GoogleAuthFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }
}
