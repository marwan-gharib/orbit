import 'package:orbit/core/utils/api_result.dart';

import '../entities/customer_notes_result_entity.dart';
import '../params/add_customer_note_params.dart';
import '../params/update_customer_note_params.dart';

/// Contract for customer-note data access. Implemented in the data layer;
/// used by the customer notes use cases.
///
/// On success each mutation announces itself on the core CRM change signal
/// so affected holders silently refetch. On failure nothing is announced.
abstract interface class CustomerNotesRepository {
  /// Notes for one customer, newest first (`created_at` desc, id desc), not
  /// paginated.
  Future<ApiResult<CustomerNotesResult>> getCustomerNotes(int customerId);

  /// Creates a note under `customerId`; the employee is derived server-side.
  Future<ApiResult<void>> addCustomerNote(AddCustomerNoteParams params);

  /// Rewrites `note_text` only. [customerId] identifies ownership for the
  /// change signal — it is never serialized.
  Future<ApiResult<void>> updateCustomerNote(
    UpdateCustomerNoteParams params, {
    required int customerId,
  });

  /// Deletes the note by id (id in the path). [customerId] identifies
  /// ownership for the change signal — it is never serialized.
  Future<ApiResult<void>> deleteCustomerNote(
    int noteId, {
    required int customerId,
  });
}
