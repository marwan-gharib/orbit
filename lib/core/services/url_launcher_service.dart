import 'package:url_launcher/url_launcher.dart' as url_launcher;

/// Abstraction over `url_launcher` so features never import the package
/// directly and tests can substitute a fake launcher.
abstract class UrlLauncherService {
  /// Whether [url] can be launched on this device.
  Future<bool> canLaunchUrl(Uri url);

  /// Launch [url]. Returns true on success; callers should handle
  /// false/exception with a localized snackbar.
  Future<bool> launchUrl(Uri url);
}

/// Real implementation backed by the `url_launcher` package.
final class UrlLauncherServiceImpl implements UrlLauncherService {
  const UrlLauncherServiceImpl();

  @override
  Future<bool> canLaunchUrl(Uri url) => url_launcher.canLaunchUrl(url);

  @override
  Future<bool> launchUrl(Uri url) => url_launcher.launchUrl(url);
}
