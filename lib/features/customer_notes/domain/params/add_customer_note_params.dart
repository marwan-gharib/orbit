import 'package:equatable/equatable.dart';

/// Input of the add-note flow. The employee is derived server-side from the
/// token, so nothing about the signed-in user appears here.
final class AddCustomerNoteParams extends Equatable {
  const AddCustomerNoteParams({
    required this.customerId,
    required this.noteText,
  });

  final int customerId;
  final String noteText;

  @override
  List<Object?> get props => [customerId, noteText];
}
