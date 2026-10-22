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

  static bool get isLoaded => _baseUrl != null;

  /// Loads `.env` once in `main()`, before DI init. Fails fast (debug AND
  /// release) when [AppConsts.envBaseUrlKey] is missing or empty: an
  /// unconfigured build has no server to reach, and a loud launch failure
  /// beats every request failing with a generic network error later.
  static Future<void> load() async {
    // A seeded environment (tests use `DotEnv.testLoad`) is never overwritten
    // by the bundled asset, so `load()` stays testable without `.env`.
    if (!dotenv.isInitialized) await dotenv.load();
    final value = dotenv.env[AppConsts.envBaseUrlKey]?.trim();
    if (value == null || value.isEmpty) {
      _baseUrl = null;
      throw StateError(
        'AppEnv: ${AppConsts.envBaseUrlKey} is missing or empty in .env. '
        'Copy .env.example, set the value, and rebuild.',
      );
    }
    _baseUrl = value;
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

  /// Test seam: seeds the value directly so tests never touch `.env` assets.
  @visibleForTesting
  static void debugSeed({required String baseUrl}) => _baseUrl = baseUrl;

  @visibleForTesting
  static void reset() => _baseUrl = null;
}
