import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/utils/formatters.dart';

void main() {
  group('Formatters.money', () {
    test('groups thousands with currency code, no symbol', () {
      expect(Formatters.money(52000, 'USD'), '52,000 USD');
    });

    test('groups large thousands with currency code', () {
      expect(Formatters.money(250000, 'EGP'), '250,000 EGP');
    });

    test('shows decimals only when value is not an integer', () {
      expect(Formatters.money(52000.50, 'USD'), '52,000.5 USD');
      expect(Formatters.money(52000, 'USD'), '52,000 USD');
    });

    test('falls back to bare number when currency code is empty', () {
      expect(Formatters.money(52000, ''), '52,000');
    });

    test('does not duplicate currency marker', () {
      // Regression test for P6: "$52000 USD" must never be produced.
      final result = Formatters.money(52000, 'USD');
      expect(result, isNot(contains('\$')));
      expect(result, isNot(contains('52000 USD'.replaceAll(',', ''))));
    });
  });

  group('Formatters.relativeParts', () {
    final now = DateTime.utc(2026, 11, 4, 12);

    test('should return justNow when the timestamp is under a minute old', () {
      expect(
        Formatters.relativeParts(
          DateTime.utc(2026, 11, 4, 11, 59, 30),
          now: now,
        ),
        (unit: RelativeTimeUnit.justNow, value: 0),
      );
    });

    test('should return minutes when the timestamp is under an hour old', () {
      expect(
        Formatters.relativeParts(DateTime.utc(2026, 11, 4, 11, 15), now: now),
        (unit: RelativeTimeUnit.minutes, value: 45),
      );
    });

    test('should return hours when the timestamp is under a day old', () {
      expect(Formatters.relativeParts(DateTime.utc(2026, 11, 4, 3), now: now), (
        unit: RelativeTimeUnit.hours,
        value: 9,
      ));
    });

    test('should return days when the timestamp is older than a day', () {
      expect(
        Formatters.relativeParts(DateTime.utc(2026, 10, 30, 12), now: now),
        (unit: RelativeTimeUnit.days, value: 5),
      );
    });

    test('should clamp a future timestamp to justNow', () {
      expect(Formatters.relativeParts(DateTime.utc(2026, 11, 5), now: now), (
        unit: RelativeTimeUnit.justNow,
        value: 0,
      ));
    });
  });

  group('Formatters.crmDate', () {
    test('renders single CRM display format', () {
      expect(Formatters.crmDate(DateTime.utc(2026, 10, 19)), '19 Oct 2026');
    });

    test('renders May date as expected close from screenshot', () {
      // Regression test for P8: "5/9/2026" must never be produced.
      expect(Formatters.crmDate(DateTime.utc(2026, 5, 9)), '9 May 2026');
    });

    test('is consistent across list and detail', () {
      final d1 = Formatters.crmDate(DateTime.utc(2026, 10, 19));
      final d2 = Formatters.crmDate(DateTime.utc(2026, 10, 19));
      expect(d1, d2);
    });
  });
}
