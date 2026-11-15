import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/helpers/wire_dates.dart';

import '../../domain/entities/customer_note_entity.dart';
import 'note_customer_details_model.dart';
import 'note_employee_details_model.dart';

/// One customer note on the wire; mutation responses are any-2xx = success
/// and are not parsed for their body (the list refetches after mutation).
final class NoteModel {
  const NoteModel({
    required this.noteId,
    required this.customerId,
    required this.employeeId,
    required this.noteText,
    required this.createdAt,
    required this.customerDetails,
    required this.employeeDetails,
  });

  final int noteId;
  final int customerId;
  final int employeeId;
  final String noteText;
  final DateTime createdAt;
  final NoteCustomerDetailsModel customerDetails;
  final NoteEmployeeDetailsModel employeeDetails;

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
    noteId: json[ApiKeys.noteIdKey] as int,
    customerId: json[ApiKeys.customerIdKey] as int,
    employeeId: json[ApiKeys.employeeIdKey] as int,
    noteText: json[ApiKeys.noteTextKey] as String? ?? '',
    createdAt: WireDates.parseDateOnly(
      json[ApiKeys.createdAtKey] as String? ?? '',
    ),
    customerDetails: NoteCustomerDetailsModel.fromJson(
      Map<String, dynamic>.from(
        json[ApiKeys.customerDetailsKey] as Map? ?? <String, dynamic>{},
      ),
    ),
    employeeDetails: NoteEmployeeDetailsModel.fromJson(
      Map<String, dynamic>.from(
        json[ApiKeys.employeeDetailsKey] as Map? ?? <String, dynamic>{},
      ),
    ),
  );

  CustomerNote toEntity() => CustomerNote(
    noteId: noteId,
    customerId: customerId,
    employeeId: employeeId,
    noteText: noteText,
    createdAt: createdAt,
    customerDetails: customerDetails.toEntity(),
    employeeDetails: employeeDetails.toEntity(),
  );
}
