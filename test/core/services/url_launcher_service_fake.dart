import 'package:orbit/core/services/url_launcher_service.dart';

/// Fake implementation of [UrlLauncherService] for testing.
/// Records launch attempts and allows controlling the result.
class UrlLauncherServiceFake implements UrlLauncherService {
  UrlLauncherServiceFake();

  final List<Uri> launchedUrls = [];
  bool canLaunchResult = true;
  bool launchResult = true;
  Object? launchError;

  @override
  Future<bool> canLaunchUrl(Uri url) async {
    launchedUrls.add(url);
    return canLaunchResult;
  }

  @override
  Future<bool> launchUrl(Uri url) async {
    launchedUrls.add(url);
    if (launchError != null) {
      throw launchError!;
    }
    return launchResult;
  }

  void reset() {
    launchedUrls.clear();
    canLaunchResult = true;
    launchResult = true;
    launchError = null;
  }
}