import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';

/// `context.failureText` is the single Failure → screen-copy mapping (ERR-4):
/// every branch must render localized text and never the raw `message`.
void main() {
  final t = AppLocale.en.buildSync();

  /// The distinct copy strings the mapping table is expected to render.
  final cases = <(String, Failure, String)>[
    (
      'offline',
      const NetworkFailure(message: 'x', reason: NetworkErrorReason.noInternet),
      t.errors.offline,
    ),
    (
      'unreachable',
      const NetworkFailure(
        message: 'x',
        reason: NetworkErrorReason.serverUnreachable,
      ),
      t.errors.unreachable,
    ),
    (
      'connection timeout',
      const NetworkFailure(
        message: 'x',
        reason: NetworkErrorReason.connectionTimeout,
      ),
      t.errors.timeout,
    ),
    (
      'request timeout',
      const NetworkFailure(
        message: 'x',
        reason: NetworkErrorReason.requestTimeout,
      ),
      t.errors.timeout,
    ),
    (
      'bad certificate',
      const NetworkFailure(
        message: 'x',
        reason: NetworkErrorReason.badCertificate,
      ),
      t.errors.certificate,
    ),
    ('cancelled', const CancelledFailure(message: 'x'), t.errors.cancelled),
    (
      'unauthorized',
      const UnauthorizedFailure(message: 'x'),
      t.errors.unauthorized,
    ),
    ('forbidden', const ForbiddenFailure(message: 'x'), t.errors.forbidden),
    (
      'gone',
      const NotFoundFailure(message: 'x', statusCode: 410),
      t.errors.gone,
    ),
    (
      'not found',
      const NotFoundFailure(message: 'x', statusCode: 404),
      t.errors.notFound,
    ),
    ('validation', const ValidationFailure(message: 'x'), t.errors.validation),
    (
      'request 400',
      const RequestFailure(message: 'x', statusCode: 400),
      t.errors.request400,
    ),
    (
      'request 405',
      const RequestFailure(message: 'x', statusCode: 405),
      t.errors.request405,
    ),
    (
      'request 409',
      const RequestFailure(message: 'x', statusCode: 409),
      t.errors.request409,
    ),
    (
      'request 413',
      const RequestFailure(message: 'x', statusCode: 413),
      t.errors.request413,
    ),
    (
      'request 423',
      const RequestFailure(message: 'x', statusCode: 423),
      t.errors.request423,
    ),
    (
      'request 451',
      const RequestFailure(message: 'x', statusCode: 451),
      t.errors.request451,
    ),
    (
      'request other',
      const RequestFailure(message: 'x', statusCode: 418),
      t.errors.request,
    ),
    (
      'server',
      const ServerFailure(message: 'x', statusCode: 500),
      t.errors.server,
    ),
    (
      'server 503',
      const ServerFailure(message: 'x', statusCode: 503),
      t.errors.server503,
    ),
    (
      'server 503 with wait',
      const ServerFailure(
        message: 'x',
        statusCode: 503,
        retryAfter: Duration(seconds: 30),
      ),
      t.errors.server503Wait(wait: t.errors.waitSeconds(n: 30)),
    ),
    (
      'server 503 with zero wait',
      const ServerFailure(
        message: 'x',
        statusCode: 503,
        retryAfter: Duration.zero,
      ),
      t.errors.server503,
    ),
    (
      'server 502',
      const ServerFailure(message: 'x', statusCode: 502),
      t.errors.server502,
    ),
    ('rate limit', const RateLimitFailure(message: 'x'), t.errors.rateLimit),
    (
      'rate limit with wait (rounded up to minutes)',
      const RateLimitFailure(message: 'x', retryAfter: Duration(seconds: 90)),
      t.errors.rateLimitWait(wait: t.errors.waitMinutes(n: 2)),
    ),
    ('parsing', const ParsingFailure(message: 'x'), t.errors.parsing),
    ('cache', const CacheFailure(message: 'x'), t.errors.cache),
    ('storage', const StorageFailure(message: 'x'), t.errors.storage),
    ('unknown', const UnknownFailure(message: 'x'), t.errors.unknown),
  ];

  for (final (name, failure, expected) in cases) {
    testWidgets('$name: renders the mapped localized text', (tester) async {
      late String text;

      await tester.pumpWidget(
        TranslationProvider(
          child: Builder(
            builder: (context) {
              text = context.failureText(failure);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(text, expected);
    });
  }

  testWidgets('should never render the raw failure message (ERR-4)', (
    tester,
  ) async {
    const failure = CacheFailure(
      message: 'SocketException at 10.0.0.7:5432 (internal)',
    );
    late String text;

    await tester.pumpWidget(
      TranslationProvider(
        child: Builder(
          builder: (context) {
            text = context.failureText(failure);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(text, t.errors.cache);
    expect(text, isNot(contains('10.0.0.7')));
  });
}
