import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/auth/domain/enums/user_role.dart';

void main() {
  group('UserRole.fromId', () {
    test('should map every known role id', () {
      expect(UserRole.fromId(1), UserRole.admin);
      expect(UserRole.fromId(2), UserRole.hrManager);
      expect(UserRole.fromId(3), UserRole.accountant);
      expect(UserRole.fromId(4), UserRole.salesRepresentative);
      expect(UserRole.fromId(5), UserRole.regularStaff);
      expect(UserRole.fromId(6), UserRole.projectManager);
      expect(UserRole.fromId(7), UserRole.inventorySpecialist);
    });

    test('should fall back to unknown for null or unrecognized ids', () {
      expect(UserRole.fromId(null), UserRole.unknown);
      expect(UserRole.fromId(0), UserRole.unknown);
      expect(UserRole.fromId(99), UserRole.unknown);
      expect(UserRole.fromId(-1), UserRole.unknown);
    });
  });
}
