import 'package:orbit/core/services/crm_data_change.dart';
import 'package:orbit/core/services/crm_data_change_service.dart';
import 'package:orbit/core/utils/api_result.dart';

import '../../domain/entities/interaction_context.dart';
import '../../domain/entities/interaction_entity.dart';
import '../../domain/params/add_interaction_params.dart';
import '../../domain/params/interactions_criteria.dart';
import '../../domain/params/update_interaction_params.dart';
import '../../domain/repositories/interactions_repository.dart';
import '../datasources/remote/interactions_remote_data_source.dart';
import '../models/interactions_response_model.dart';

/// Orchestrates interactions data: one GET when unsearched, two parallel
/// GETs (subject + description) merged, de-duplicated and sorted when
/// searching, and a CRM change publish after every successful mutation.
/// Merging and sorting live here — the datasource never sorts; publishing
/// never happens on failure.
class InteractionsRepositoryImpl implements InteractionsRepository {
  InteractionsRepositoryImpl(this._remoteDataSource, this._changeService);

  final InteractionsRemoteDataSource _remoteDataSource;
  final CrmDataChangeService _changeService;

  @override
  Future<ApiResult<List<Interaction>>> getInteractions(
    InteractionsCriteria criteria,
  ) async {
    final searchText = criteria.searchText;
    if (searchText == null || searchText.isEmpty) {
      final result = await _remoteDataSource.fetchInteractions(
        subject: null,
        description: null,
        type: criteria.type,
        customerId: criteria.customerId,
        contactId: criteria.contactId,
        opportunityId: criteria.opportunityId,
      );
      return result.fold(
        ResultFailure<List<Interaction>>.new,
        (response) => Success(_sortByDateThenId(_toEntities(response))),
      );
    }

    // Search fan-out: the backend matches subject OR description of one
    // search text, so two GETs run in parallel with the same filters. The
    // merged order must be produced here because no backend order is
    // guaranteed.
    final results = await Future.wait([
      _remoteDataSource.fetchInteractions(
        subject: searchText,
        description: null,
        type: criteria.type,
        customerId: criteria.customerId,
        contactId: criteria.contactId,
        opportunityId: criteria.opportunityId,
      ),
      _remoteDataSource.fetchInteractions(
        subject: null,
        description: searchText,
        type: criteria.type,
        customerId: criteria.customerId,
        contactId: criteria.contactId,
        opportunityId: criteria.opportunityId,
      ),
    ]);

    final subjectHalf = _half(results[0]);
    final descriptionHalf = _half(results[1]);
    // Either failing fails the whole search — the subject half's failure
    // wins when both fail (it is the first "text" match dimension).
    final searchFailure = subjectHalf.failure ?? descriptionHalf.failure;
    if (searchFailure != null) return searchFailure;

    // Subject-result copies win the de-duplication by id.
    final byId = <int, Interaction>{
      for (final interaction in subjectHalf.entities)
        interaction.interactionId: interaction,
    };
    for (final interaction in descriptionHalf.entities) {
      byId.putIfAbsent(interaction.interactionId, () => interaction);
    }
    return Success(_sortByDateThenId(byId.values.toList()));
  }

  @override
  Future<ApiResult<void>> addInteraction(
    AddInteractionParams params, {
    required int employeeId,
  }) {
    return _mutation(
      () => _remoteDataSource.addInteraction(params, employeeId: employeeId),
      customer: params.customerId,
      opportunity: params.opportunityId,
    );
  }

  @override
  Future<ApiResult<void>> updateInteraction(
    UpdateInteractionParams params, {
    required InteractionContext context,
  }) {
    return _mutation(
      () => _remoteDataSource.updateInteraction(params),
      customer: context.customerId,
      opportunity: context.opportunityId,
    );
  }

  @override
  Future<ApiResult<void>> deleteInteraction(
    int interactionId, {
    required InteractionContext context,
  }) {
    return _mutation(
      () => _remoteDataSource.deleteInteraction(interactionId),
      customer: context.customerId,
      opportunity: context.opportunityId,
    );
  }

  /// Runs one remote mutation; on success the change is announced for the
  /// owning customer (and opportunity), then the original result is
  /// returned — on failure nothing is announced and the failure passes
  /// through untouched.
  Future<ApiResult<void>> _mutation(
    Future<ApiResult<void>> Function() remote, {
    required int customer,
    required int? opportunity,
  }) async {
    final result = await remote();
    if (result is Success<void>) {
      _changeService.publish(
        CrmDataChange(
          kind: CrmDataKind.interaction,
          customerId: customer,
          opportunityId: opportunity,
        ),
      );
    }
    return result;
  }

  /// One search half's outcome: the whole-search failure when its GET
  /// failed, otherwise its entities.
  ({ApiResult<List<Interaction>>? failure, List<Interaction> entities}) _half(
    ApiResult<InteractionsResponseModel> result,
  ) => switch (result) {
    Success<InteractionsResponseModel>(:final data) => (
      failure: null,
      entities: _toEntities(data),
    ),
    ResultFailure<InteractionsResponseModel>(:final failure) => (
      failure: ResultFailure<List<Interaction>>(failure),
      entities: const <Interaction>[],
    ),
  };

  List<Interaction> _toEntities(InteractionsResponseModel response) => [
    for (final model in response.interactions) model.toEntity(),
  ];

  /// `interaction_date` desc, then id desc — the contract the standalone
  /// list must always show.
  List<Interaction> _sortByDateThenId(List<Interaction> interactions) {
    final sorted = [...interactions];
    sorted.sort((a, b) {
      final byDate = b.interactionDate.compareTo(a.interactionDate);
      if (byDate != 0) return byDate;
      return b.interactionId.compareTo(a.interactionId);
    });
    return sorted;
  }
}
