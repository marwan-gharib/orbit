import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/core/errors/error_mapper.dart';

import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/core/utils/api_result.dart';

import '../../../domain/params/add_customer_note_params.dart';
import '../../../domain/params/update_customer_note_params.dart';
import '../../models/customer_notes_response_model.dart';

/// The whole customer-notes HTTP surface in one class. Emits `Failure`s
/// only: every throw (network or parsing) is mapped right here (DATA-3).
/// Mutation success is "any 2xx" — response bodies are never relied upon.
class CustomerNotesRemoteDataSource {
  CustomerNotesRemoteDataSource(this._client);

  final BaseApiClient _client;

  Future<ApiResult<CustomerNotesResponseModel>> fetchCustomerNotes(
    int customerId,
  ) async {
    try {
      final body = await _client.get(
        Endpoints.crmCustomerNotes,
        queryParameters: <String, Object?>{ApiKeys.customerIdKey: customerId},
      );
      return Success(CustomerNotesResponseModel.fromJson(_asMap(body)));
    } on Object catch (error, stackTrace) {
      return ResultFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }

  Future<ApiResult<void>> addCustomerNote(AddCustomerNoteParams params) async {
    try {
      await _client.post(
        Endpoints.crmCustomerNotes,
        data: <String, Object?>{
          ApiKeys.customerIdKey: params.customerId,
          ApiKeys.noteTextKey: params.noteText,
        },
      );
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }

  Future<ApiResult<void>> updateCustomerNote(
    UpdateCustomerNoteParams params,
  ) async {
    try {
      await _client.patch(
        Endpoints.crmCustomerNoteById(params.noteId),
        data: <String, Object?>{ApiKeys.noteTextKey: params.noteText},
      );
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }

  Future<ApiResult<void>> deleteCustomerNote(int noteId) => _mutate(() {
    return _client.delete(Endpoints.crmCustomerNoteById(noteId));
  });

  Future<ApiResult<void>> _mutate(Future<Object?> Function() request) async {
    try {
      await request();
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }

  Map<String, dynamic> _asMap(Object? body) {
    if (body is Map) return Map<String, dynamic>.from(body);
    throw const FormatException('Notes body was not a JSON object.');
  }
}
