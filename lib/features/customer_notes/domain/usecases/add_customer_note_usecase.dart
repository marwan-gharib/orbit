import 'package:orbit/core/utils/api_result.dart';

import '../params/add_customer_note_params.dart';
import '../repositories/customer_notes_repository.dart';

/// Creates one customer note; the employee is derived server-side, so the
/// caller supplies nothing beyond customer id and text.
class AddCustomerNoteUseCase {
  AddCustomerNoteUseCase(this._repository);

  final CustomerNotesRepository _repository;

  Future<ApiResult<void>> call(AddCustomerNoteParams params) =>
      _repository.addCustomerNote(params);
}
