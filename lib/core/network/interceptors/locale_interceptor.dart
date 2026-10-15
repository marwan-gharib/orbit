import 'package:dio/dio.dart';

/// Sends the current UI locale via `Accept-Language` so the backend can
/// localize its payloads. The locale comes from a plain callback — core
/// depends on no localization package.
final class LocaleInterceptor extends Interceptor {
  /// [localeProvider] returns the current locale tag (e.g. `en-US`, `ar`).
  const LocaleInterceptor(this._localeProvider);

  static const String _acceptLanguageHeader = 'Accept-Language';

  final String Function() _localeProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final locale = _localeProvider().trim();
    if (locale.isNotEmpty) {
      options.headers[_acceptLanguageHeader] = locale;
    }
    handler.next(options);
  }
}
