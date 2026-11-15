import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/helpers/wire_dates.dart';

import '../../domain/entities/embedded_customer_note_entity.dart';

final class EmbeddedNoteModel {
  const EmbeddedNoteModel({
    required this.noteId,
    required this.employeeId,
    required this.employeeName,
    required this.noteText,
    required this.createdAt,
  });

  final int noteId;
  final int employeeId;
  final String employeeName;
  final String noteText;
  final DateTime createdAt;

  factory EmbeddedNoteModel.fromJson(Map<String, dynamic> json) =>
      EmbeddedNoteModel(
        noteId: json[ApiKeys.noteIdKey] as int,
        employeeId: json[ApiKeys.employeeIdKey] as int,
        employeeName: json[ApiKeys.employeeNameKey] as String? ?? '',
        noteText: json[ApiKeys.noteTextKey] as String? ?? '',
        createdAt: WireDates.parseDateOnly(
          json[ApiKeys.createdAtKey] as String? ?? '',
        ),
      );

  EmbeddedCustomerNote toEntity() => EmbeddedCustomerNote(
    noteId: noteId,
    employeeId: employeeId,
    employeeName: employeeName,
    noteText: noteText,
    createdAt: createdAt,
  );
}
