import 'package:orbit/core/utils/api_result.dart';

import '../entities/customer_notes_result_entity.dart';
import '../repositories/customer_notes_repository.dart';

/// Loads all notes of one customer.
class GetCustomerNotesUseCase {
  GetCustomerNotesUseCase(this._repository);

  final CustomerNotesRepository _repository;

  Future<ApiResult<CustomerNotesResult>> call(int customerId) =>
      _repository.getCustomerNotes(customerId);
}
