import 'package:orbit/core/constants/api_keys.dart';

import '../../domain/entities/customer_notes_result_entity.dart';
import 'note_model.dart';

/// The notes-by-customer response: `{"customer_id": ..., "total": ..., "notes": [...]}`.
final class CustomerNotesResponseModel {
  const CustomerNotesResponseModel({
    required this.customerId,
    required this.total,
    required this.notes,
  });

  final int customerId;
  final int total;
  final List<NoteModel> notes;

  factory CustomerNotesResponseModel.fromJson(Map<String, dynamic> json) {
    final rawNotes = json[ApiKeys.notesRootKey];
    if (rawNotes is! List) {
      throw const FormatException('Notes root is not a list.');
    }
    return CustomerNotesResponseModel(
      customerId: json[ApiKeys.customerIdKey] as int,
      total: json[ApiKeys.totalKey] as int? ?? 0,
      notes: [
        for (final item in rawNotes)
          item is Map
              ? NoteModel.fromJson(Map<String, dynamic>.from(item))
              : throw const FormatException(
                  'A notes list item is not a JSON object.',
                ),
      ],
    );
  }

  CustomerNotesResult toEntity() => CustomerNotesResult(
    notes: notes.map((m) => m.toEntity()).toList(),
    total: total,
  );
}
