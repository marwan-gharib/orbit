/// Lottie file paths (ARCH-10: asset paths live in `core/constants/`, never
/// as literals where they are used).
///
/// ```dart
/// AppLottie.success(size: 96);
/// AppLottie.asset(AppLottieAssets.onboarding(1), repeat: false);
/// ```
///
/// Every file lives under `assets/animations/` (registered in
/// `pubspec.yaml`): drop the `.json` exports there and no other file has to
/// change.
abstract final class AppLottieAssets {
  /// Folder that holds every Lottie file of the app.
  static const String _folder = 'assets/animations';

  /// Celebration loop-free state animation, played by `AppLottie.success()`.
  static const String success = '$_folder/success.json';

  /// Failure state animation, played by `AppLottie.error()`.
  static const String error = '$_folder/error.json';

  /// "Nothing here" state animation, played by `AppLottie.empty()`.
  static const String empty = '$_folder/empty.json';

  /// Indeterminate busy animation, played by `AppLottie.loading()`.
  static const String loading = '$_folder/loading.json';

  /// Placeholder onboarding animation for step [step] (1-based): until the
  /// design files arrive, export `onboarding_1.json`, `onboarding_2.json`,
  /// ... into the folder above and feed the result to `AppLottie.asset`.
  static String onboarding(int step) => '$_folder/onboarding_$step.json';
}
