import 'package:orbit/core/utils/api_result.dart';

import '../params/update_customer_note_params.dart';
import '../repositories/customer_notes_repository.dart';

/// Rewrites one note's text. The customer id travels separately (never
/// serialized) so the repository can announce the change correctly.
class UpdateCustomerNoteUseCase {
  UpdateCustomerNoteUseCase(this._repository);

  final CustomerNotesRepository _repository;

  Future<ApiResult<void>> call(
    UpdateCustomerNoteParams params, {
    required int customerId,
  }) => _repository.updateCustomerNote(params, customerId: customerId);
}
