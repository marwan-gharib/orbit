import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/auth/data/models/employee_status_response_model.dart';
import 'package:orbit/features/auth/domain/entities/employee_status_info_entity.dart';
import 'package:orbit/features/auth/domain/enums/employment_status.dart';

Map<String, dynamic> tStatusJson(String status) => <String, dynamic>{
  ApiKeys.userKey: <String, dynamic>{
    ApiKeys.firstNameKey: 'Adam',
    ApiKeys.lastNameKey: 'Orbit',
    ApiKeys.statusKey: status,
  },
};

void main() {
  group('EmployeeStatusResponseModel.fromJson', () {
    test('should map the nested user fields and the wire status value', () {
      final model = EmployeeStatusResponseModel.fromJson(
        tStatusJson('pending'),
      );

      expect(model.firstName, 'Adam');
      expect(model.lastName, 'Orbit');
      expect(model.status, EmploymentStatus.pending);
    });

    test('should map every known status value', () {
      expect(
        EmployeeStatusResponseModel.fromJson(tStatusJson('approved')).status,
        EmploymentStatus.approved,
      );
      expect(
        EmployeeStatusResponseModel.fromJson(tStatusJson('rejected')).status,
        EmploymentStatus.rejected,
      );
    });

    test('should fall back to unknown for an unrecognized status', () {
      final model = EmployeeStatusResponseModel.fromJson(
        tStatusJson('retired'),
      );

      expect(model.status, EmploymentStatus.unknown);
    });

    test('should be case- and whitespace-tolerant', () {
      final model = EmployeeStatusResponseModel.fromJson(
        tStatusJson(' PENDING '),
      );

      expect(model.status, EmploymentStatus.pending);
    });

    test('should throw when the user object is missing', () {
      expect(
        () => EmployeeStatusResponseModel.fromJson(const {}),
        throwsFormatException,
      );
    });
  });

  group('EmployeeStatusResponseModel.toEntity', () {
    test('should map field by field', () {
      final entity = EmployeeStatusResponseModel.fromJson(
        tStatusJson('approved'),
      ).toEntity();

      expect(entity, isA<EmployeeStatusInfo>());
      expect(entity.firstName, 'Adam');
      expect(entity.lastName, 'Orbit');
      expect(entity.status, EmploymentStatus.approved);
    });
  });
}
