import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/date_formats.dart';
import 'package:orbit/core/helpers/wire_dates.dart';

void main() {
  group('WireDates.tryParseDateOnly', () {
    test('should parse the date-only wire shape into a UTC-normalized date',
        () {
      final result = WireDates.tryParseDateOnly('2025-06-01');

      expect(result, DateTime.utc(2025, 6, 1));
      expect(result!.isUtc, isTrue);
    });

    test('should pad nothing and keep the parsed day for a Z-midnight instant',
        () {
      expect(
        WireDates.tryParseDateOnly('2025-06-01T00:00:00Z'),
        DateTime.utc(2025, 6, 1),
      );
    });

    test(
      'should keep the instant-forbidden own components for a negative offset',
      () {
        // The instant itself is 2025-06-02T00:00Z; the wire value's calendar
        // day is June 1st and must not drift.
        expect(
          WireDates.tryParseDateOnly('2025-06-01T22:00:00-02:00'),
          DateTime.utc(2025, 6, 1),
        );
      },
    );

    test('should accept an instant with a space instead of T and sub-second',
        () {
      expect(
        WireDates.tryParseDateOnly('2025-06-01 08:30:15.500'),
        DateTime.utc(2025, 6, 1),
      );
    });

    test('should be whitespace-tolerant', () {
      expect(WireDates.tryParseDateOnly(' 2025-06-01 '), DateTime.utc(2025, 6, 1));
    });

    test(
      'should yield null for null, blank, non-shaped or unparsable input',
      () {
        expect(WireDates.tryParseDateOnly(null), isNull);
        expect(WireDates.tryParseDateOnly(''), isNull);
        expect(WireDates.tryParseDateOnly('   '), isNull);
        expect(WireDates.tryParseDateOnly('2025'), isNull);
        expect(WireDates.tryParseDateOnly('2025-6-1'), isNull);
        expect(WireDates.tryParseDateOnly('06/01/2025'), isNull);
        expect(WireDates.tryParseDateOnly('2025-06-31'), isNull);
      },
    );
  });

  group('WireDates.parseDateOnly', () {
    test('should parse and normalize like tryParseDateOnly', () {
      expect(
        WireDates.parseDateOnly('2025-06-01T00:00:00Z'),
        DateTime.utc(2025, 6, 1),
      );
    });

    test(
      'should throw FormatException for unparsable or non-shaped values',
      () {
        expect(
          () => WireDates.parseDateOnly('2025-06-31'),
          throwsFormatException,
        );
        expect(() => WireDates.parseDateOnly('2025'), throwsFormatException);
        expect(() => WireDates.parseDateOnly(''), throwsFormatException);
      },
    );
  });

  group('WireDates.formatDateOnly', () {
    test('should format user-picked local dates without zone drift', () {
      expect(WireDates.formatDateOnly(DateTime(2025, 6, 1)), '2025-06-01');
    });

    test('should format UTC-normalized dates from their own components', () {
      expect(
        WireDates.formatDateOnly(DateTime.utc(2025, 6, 1)),
        '2025-06-01',
      );
      expect(
        WireDates.formatDateOnly(DateTime.utc(2025, 12, 31)),
        '2025-12-31',
      );
    });

    test('should pad month, day and year', () {
      expect(
        WireDates.formatDateOnly(DateTime.utc(953, 3, 7)),
        '0953-03-07',
      );
      expect(WireDates.formatDateOnly(DateTime(2025, 1, 2)), '2025-01-02');
    });
  });

  test('apiDate keeps the wire pattern the helpers implement', () {
    expect(
      WireDates.formatDateOnly(DateTime.utc(2025, 6, 1)),
      '2025-06-01',
    );
    expect(DateFormats.apiDate, 'yyyy-MM-dd');
  });
}
