import 'package:equatable/equatable.dart';

import 'customer_note_entity.dart';

/// The non-paginated notes-by-customer response: the note list plus the
/// server-reported total (display-only).
final class CustomerNotesResult extends Equatable {
  const CustomerNotesResult({required this.notes, required this.total});

  final List<CustomerNote> notes;
  final int total;

  @override
  List<Object?> get props => [notes, total];
}
