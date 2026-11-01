import 'package:equatable/equatable.dart';

/// Input of the edit-note flow: exactly the fields the PATCH body carries
/// (`note_text`). The note id is the path parameter, never a body field.
final class UpdateCustomerNoteParams extends Equatable {
  const UpdateCustomerNoteParams({
    required this.noteId,
    required this.noteText,
  });

  final int noteId;
  final String noteText;

  @override
  List<Object?> get props => [noteId, noteText];
}
