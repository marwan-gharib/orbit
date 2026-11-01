import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/core/errors/error_mapper.dart';
import 'package:orbit/core/helpers/wire_dates.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/core/utils/api_result.dart';

import '../../../domain/params/add_interaction_params.dart';
import '../../../domain/params/update_interaction_params.dart';
import '../../models/interactions_response_model.dart';

/// The whole interactions HTTP surface in one class — endpoints, verbs,
/// bodies and the unusual DELETE-with-body live here and nowhere else.
/// Emits `Failure`s only: every throw (network or parsing) is mapped right
/// here, so a malformed payload becomes a `ParsingFailure`, never a crash
/// (DATA-3). Mutation success is "any 2xx" — response bodies are never
/// relied upon (no echo parsing).
class InteractionsRemoteDataSource {
  InteractionsRemoteDataSource(this._client);

  final BaseApiClient _client;

  /// One interactions fetch; [subject] and [description] are the two search
  /// dimensions (the repository merges the subject/description result pair).
  Future<ApiResult<InteractionsResponseModel>> fetchInteractions({
    String? subject,
    String? description,
    InteractionType? type,
    int? customerId,
    int? contactId,
    int? opportunityId,
  }) async {
    try {
      final body = await _client.get(
        Endpoints.crmInteractions,
        queryParameters: <String, Object?>{
          ApiKeys.subjectKey: ?subject,
          ApiKeys.descriptionKey: ?description,
          if (type != null) ApiKeys.typeKey: type.value,
          ApiKeys.customerIdKey: ?customerId,
          ApiKeys.contactIdKey: ?contactId,
          ApiKeys.opportunityIdKey: ?opportunityId,
        },
      );
      return Success(InteractionsResponseModel.fromJson(_asMap(body)));
    } on Object catch (error, stackTrace) {
      return ResultFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }

  Future<ApiResult<void>> addInteraction(
    AddInteractionParams params, {
    required int employeeId,
  }) async {
    try {
      await _client.post(
        Endpoints.crmInteractions,
        data: <String, Object?>{
          ApiKeys.typeKey: params.type.value,
          ApiKeys.subjectKey: params.subject,
          ApiKeys.descriptionKey: params.description,
          ApiKeys.interactionDateKey: WireDates.formatDateOnly(
            params.interactionDate,
          ),
          ApiKeys.customerIdKey: params.customerId,
          ApiKeys.employeeIdKey: employeeId,
          // Optional owner ids are omitted, never sent as null.
          if (params.contactId != null) ApiKeys.contactIdKey: params.contactId,
          if (params.opportunityId != null)
            ApiKeys.opportunityIdKey: params.opportunityId,
        },
      );
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }

  Future<ApiResult<void>> updateInteraction(
    UpdateInteractionParams params,
  ) async {
    try {
      await _client.patch(
        Endpoints.crmInteractions,
        data: <String, Object?>{
          ApiKeys.interactionIdKey: params.interactionId,
          ApiKeys.typeKey: params.type.value,
          ApiKeys.subjectKey: params.subject,
          ApiKeys.descriptionKey: params.description,
          ApiKeys.interactionDateKey: WireDates.formatDateOnly(
            params.interactionDate,
          ),
        },
      );
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }

  Future<ApiResult<void>> deleteInteraction(int interactionId) => _mutate(() {
    return _client.delete(
      Endpoints.crmInteractions,
      // Backend contract: the DELETE body carries the interaction id.
      data: <String, Object?>{ApiKeys.interactionIdKey: interactionId},
    );
  });

  Future<ApiResult<void>> _mutate(Future<Object?> Function() request) async {
    try {
      await request();
      return const Success<void>(null);
    } on Object catch (error, stackTrace) {
      return ResultFailure(ErrorMapper.toFailure(error, stackTrace));
    }
  }

  /// Any 2xx response body counts as success; a non-object body is still
  /// malformed data → `ParsingFailure`.
  Map<String, dynamic> _asMap(Object? body) {
    if (body is Map) return Map<String, dynamic>.from(body);
    throw const FormatException('Interactions body was not a JSON object.');
  }
}
