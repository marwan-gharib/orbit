import '../../domain/entities/customer_note_entity.dart';
import '../view_models/customer_note_view_model.dart';

/// Maps a loaded note to the row's view model.
extension CustomerNoteMapper on CustomerNote {
  CustomerNoteViewModel toViewModel() => CustomerNoteViewModel(
    noteId: noteId,
    customerId: customerId,
    authorName: employeeDetails.name,
    initials: _initials(employeeDetails.name),
    text: noteText,
    createdAt: createdAt,
  );
}

/// First letters of the first two words; `?` when the name is blank.
String _initials(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty);
  final initials = words
      .take(2)
      .map((word) => word.substring(0, 1).toUpperCase())
      .join();
  return initials.isEmpty ? '?' : initials;
}
