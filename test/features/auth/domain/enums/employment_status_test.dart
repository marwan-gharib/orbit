import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/auth/domain/enums/employment_status.dart';

void main() {
  group('EmploymentStatus.fromValue', () {
    test('should map every wire value', () {
      expect(EmploymentStatus.fromValue('pending'), EmploymentStatus.pending);
      expect(EmploymentStatus.fromValue('approved'), EmploymentStatus.approved);
      expect(EmploymentStatus.fromValue('rejected'), EmploymentStatus.rejected);
    });

    test('should be case- and whitespace-tolerant', () {
      expect(
        EmploymentStatus.fromValue('Approved '),
        EmploymentStatus.approved,
      );
      expect(EmploymentStatus.fromValue('PENDING'), EmploymentStatus.pending);
    });

    test(
      'should fall back to unknown for null, blank or unrecognized values',
      () {
        expect(EmploymentStatus.fromValue(null), EmploymentStatus.unknown);
        expect(EmploymentStatus.fromValue(''), EmploymentStatus.unknown);
        expect(EmploymentStatus.fromValue('   '), EmploymentStatus.unknown);
        expect(EmploymentStatus.fromValue('retired'), EmploymentStatus.unknown);
      },
    );
  });
}
