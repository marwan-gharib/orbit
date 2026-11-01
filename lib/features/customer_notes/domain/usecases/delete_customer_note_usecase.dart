import 'package:orbit/core/utils/api_result.dart';

import '../repositories/customer_notes_repository.dart';

/// Deletes one customer note by id. The customer id travels separately
/// (never serialized) so the repository can announce the change correctly.
class DeleteCustomerNoteUseCase {
  DeleteCustomerNoteUseCase(this._repository);

  final CustomerNotesRepository _repository;

  Future<ApiResult<void>> call(int noteId, {required int customerId}) =>
      _repository.deleteCustomerNote(noteId, customerId: customerId);
}
