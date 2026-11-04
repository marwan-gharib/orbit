import 'package:equatable/equatable.dart';

/// What one note row renders. Domain entities never reach the widget tree
/// (ARCH-3); the thread maps loaded notes into this shape once.
final class CustomerNoteViewModel extends Equatable {
  const CustomerNoteViewModel({
    required this.noteId,
    required this.customerId,
    required this.authorName,
    required this.initials,
    required this.text,
    required this.createdAt,
  });

  final int noteId;
  final int customerId;
  final String authorName;

  /// 1–2 uppercase letters shown in the avatar.
  final String initials;

  final String text;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    noteId,
    customerId,
    authorName,
    initials,
    text,
    createdAt,
  ];
}
