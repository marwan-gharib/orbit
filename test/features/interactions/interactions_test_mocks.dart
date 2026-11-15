import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/core/services/crm_data_change.dart';
import 'package:orbit/core/services/crm_data_change_service.dart';
import 'package:orbit/core/services/current_employee_id_provider.dart';
import 'package:orbit/features/interactions/domain/entities/interaction_context.dart';
import 'package:orbit/features/interactions/domain/entities/interaction_entity.dart';
import 'package:orbit/features/interactions/domain/params/add_interaction_params.dart';
import 'package:orbit/features/interactions/domain/params/interactions_criteria.dart';
import 'package:orbit/features/interactions/domain/params/update_interaction_params.dart';
import 'package:orbit/features/interactions/domain/repositories/interactions_repository.dart';
import 'package:orbit/features/interactions/domain/usecases/get_interactions_usecase.dart';
import 'package:orbit/features/interactions/domain/usecases/watch_interaction_changes_usecase.dart';
import 'package:orbit/features/interactions/domain/usecases/add_interaction_usecase.dart';
import 'package:orbit/features/interactions/domain/usecases/update_interaction_usecase.dart';
import 'package:orbit/features/interactions/domain/usecases/delete_interaction_usecase.dart';

class MockInteractionsRepository extends Mock
    implements InteractionsRepository {}

class MockGetInteractionsUseCase extends Mock
    implements GetInteractionsUseCase {}

class MockWatchInteractionChangesUseCase extends Mock
    implements WatchInteractionChangesUseCase {}

class MockCurrentEmployeeIdProvider extends Mock
    implements CurrentEmployeeIdProvider {}

class MockCrmDataChangeService extends Mock implements CrmDataChangeService {}

class MockAddInteractionUseCase extends Mock implements AddInteractionUseCase {}

class MockUpdateInteractionUseCase extends Mock
    implements UpdateInteractionUseCase {}

class MockDeleteInteractionUseCase extends Mock
    implements DeleteInteractionUseCase {}

/// Registers mocktail fallbacks once for all interactions tests.
void registerInteractionsFallbacks() {
  registerFallbackValue(InteractionsCriteria());
  registerFallbackValue(
    AddInteractionParams(
      type: InteractionType.call,
      subject: 'x',
      description: '',
      interactionDate: DateTime.utc(2025),
      customerId: 1,
    ),
  );
  registerFallbackValue(
    UpdateInteractionParams(
      interactionId: 1,
      type: InteractionType.call,
      subject: 'x',
      description: '',
      interactionDate: DateTime.utc(2025),
    ),
  );
  registerFallbackValue(const InteractionContext(customerId: 0));
  registerFallbackValue(tInteraction());
  registerFallbackValue(
    const CrmDataChange(kind: CrmDataKind.interaction, customerId: 0),
  );
}

/// One interaction under test (collection-shaped values).
Interaction tInteraction({
  int id = 1,
  DateTime? date,
  int? opportunityId,
  int customerId = 7,
}) => Interaction(
  interactionId: id,
  type: InteractionType.call,
  subject: 'Sync meeting',
  description: 'Notes',
  interactionDate: date ?? DateTime.utc(2025, 6, 1),
  customerId: customerId,
  employeeId: 46,
  contactId: opportunityId == null ? null : 3,
  opportunityId: opportunityId,
);

/// The wire shape of one interaction; nulls are omitted like the client
/// omits them on requests.
Map<String, dynamic> tInteractionJson({
  int id = 1,
  String type = 'call',
  String date = '2025-06-01T00:00:00Z',
  String? description = 'Notes',
  int? contactId,
  int? opportunityId,
  int customerId = 7,
}) => <String, dynamic>{
  ApiKeys.interactionIdKey: id,
  ApiKeys.typeKey: type,
  ApiKeys.subjectKey: 'Sync meeting',
  ApiKeys.descriptionKey: description,
  ApiKeys.interactionDateKey: date,
  ApiKeys.customerIdKey: customerId,
  ApiKeys.employeeIdKey: 46,
  ApiKeys.contactIdKey: ?contactId,
  ApiKeys.opportunityIdKey: ?opportunityId,
};
