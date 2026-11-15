import 'package:orbit/core/services/crm_data_change.dart';
import 'package:orbit/core/services/crm_data_change_service.dart';
import 'package:orbit/core/utils/api_result.dart';

import '../../domain/entities/customer_note_entity.dart';
import '../../domain/entities/customer_notes_result_entity.dart';
import '../../domain/params/add_customer_note_params.dart';
import '../../domain/params/update_customer_note_params.dart';
import '../../domain/repositories/customer_notes_repository.dart';
import '../datasources/remote/customer_notes_remote_data_source.dart';
import '../models/note_model.dart';

/// Orchestrates customer-notes data: sorts newest-first, publishes the CRM
/// change on every successful mutation, never publishes on failure.
class CustomerNotesRepositoryImpl implements CustomerNotesRepository {
  CustomerNotesRepositoryImpl(this._remoteDataSource, this._changeService);

  final CustomerNotesRemoteDataSource _remoteDataSource;
  final CrmDataChangeService _changeService;

  @override
  Future<ApiResult<CustomerNotesResult>> getCustomerNotes(
    int customerId,
  ) async {
    final result = await _remoteDataSource.fetchCustomerNotes(customerId);
    return result.fold(ResultFailure<CustomerNotesResult>.new, (response) {
      final entities = response.notes.toEntityList();
      // Newest first; deterministic tiebreak by id.
      entities.sort((a, b) {
        final byDate = b.createdAt.compareTo(a.createdAt);
        if (byDate != 0) return byDate;
        return b.noteId.compareTo(a.noteId);
      });
      return Success(
        CustomerNotesResult(notes: entities, total: response.total),
      );
    });
  }

  @override
  Future<ApiResult<void>> addCustomerNote(AddCustomerNoteParams params) {
    return _mutation(
      () => _remoteDataSource.addCustomerNote(params),
      customer: params.customerId,
    );
  }

  @override
  Future<ApiResult<void>> updateCustomerNote(
    UpdateCustomerNoteParams params, {
    required int customerId,
  }) {
    return _mutation(
      () => _remoteDataSource.updateCustomerNote(params),
      customer: customerId,
    );
  }

  @override
  Future<ApiResult<void>> deleteCustomerNote(
    int noteId, {
    required int customerId,
  }) {
    return _mutation(
      () => _remoteDataSource.deleteCustomerNote(noteId),
      customer: customerId,
    );
  }

  /// Runs one remote mutation; on success the change is announced for the
  /// owning customer, then the original result is returned — on failure
  /// nothing is announced and the failure passes through untouched.
  Future<ApiResult<void>> _mutation(
    Future<ApiResult<void>> Function() remote, {
    required int customer,
  }) async {
    final result = await remote();
    if (result is Success<void>) {
      _changeService.publish(
        CrmDataChange(kind: CrmDataKind.note, customerId: customer),
      );
    }
    return result;
  }
}

/// Extension to convert model list to entity list.
extension _NoteModelList on List<NoteModel> {
  List<CustomerNote> toEntityList() => map((m) => m.toEntity()).toList();
}
