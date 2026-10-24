import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:orbit/core/constants/app_consts.dart';

/// Typed accessor to the bundled non-secret configuration (`.env`). The only
/// `flutter_dotenv` importer (ARCH-5); everything else reads typed values
/// from here.
///
/// Bundled assets are extractable from an installed binary, so `.env` may
/// only hold non-secret values like the base URL — never real secrets.
abstract final class AppEnv {
  static String? _baseUrl;
  static String? _googleServerClientId;

  static bool get isLoaded =>
      _baseUrl != null && _googleServerClientId != null;

  /// Loads `.env` once in `main()`, before DI init. Fails fast (debug AND
  /// release) when [AppConsts.envBaseUrlKey] or [AppConsts.envGoogleServerClientIdKey]
  /// is missing or empty: an unconfigured build has no server or auth client to reach.
  static Future<void> load() async {
    // A seeded environment (tests use `DotEnv.testLoad`) is never overwritten
    // by the bundled asset, so `load()` stays testable without `.env`.
    if (!dotenv.isInitialized) await dotenv.load();
    final value = dotenv.env[AppConsts.envBaseUrlKey]?.trim();
    if (value == null || value.isEmpty) {
      _baseUrl = null;
      _googleServerClientId = null;
      throw StateError(
        'AppEnv: ${AppConsts.envBaseUrlKey} is missing or empty in .env. '
        'Copy .env.example, set the value, and rebuild.',
      );
    }
    _baseUrl = value;

    final googleClientId =
        dotenv.env[AppConsts.envGoogleServerClientIdKey]?.trim();
    if (googleClientId == null || googleClientId.isEmpty) {
      _baseUrl = null;
      _googleServerClientId = null;
      throw StateError(
        'AppEnv: ${AppConsts.envGoogleServerClientIdKey} is missing or empty in .env. '
        'Copy .env.example, set the value, and rebuild.',
      );
    }
    _googleServerClientId = googleClientId;
  }

  /// The backend base URL for `DioApiClient`. Throws when the environment has
  /// not been loaded yet — DI init happens strictly after [load] in `main()`.
  static String get baseUrl {
    final value = _baseUrl;
    if (value == null || value.isEmpty) {
      throw StateError(
        'AppEnv: base URL read before load(). Call AppEnv.load() in main() '
        '(or AppEnv.debugSeed in tests) first.',
      );
    }
    return value;
  }

  /// The Google OAuth Web client ID for Google SSO. Throws when the environment
  /// has not been loaded yet.
  static String get googleServerClientId {
    final value = _googleServerClientId;
    if (value == null || value.isEmpty) {
      throw StateError(
        'AppEnv: Google Server Client ID read before load(). Call AppEnv.load() in main() '
        '(or AppEnv.debugSeed in tests) first.',
      );
    }
    return value;
  }

  /// Test seam: seeds values directly so tests never touch `.env` assets.
  @visibleForTesting
  static void debugSeed({
    String? baseUrl,
    String? googleServerClientId,
  }) {
    if (baseUrl != null) _baseUrl = baseUrl;
    if (googleServerClientId != null) {
      _googleServerClientId = googleServerClientId;
    }
  }

  @visibleForTesting
  static void reset() {
    _baseUrl = null;
    _googleServerClientId = null;
  }
}
