import 'package:orbit/core/services/crm_data_change.dart';
import 'package:orbit/core/services/crm_data_change_service.dart';

/// Streams the CRM change signal filtered to interactions, so the list Bloc
/// can silently refresh when an interaction mutation happens somewhere else
/// in the app (another screen's add/edit/delete).
class WatchInteractionChangesUseCase {
  WatchInteractionChangesUseCase(this._changeService);

  final CrmDataChangeService _changeService;

  Stream<CrmDataChange> call() => _changeService.changes.where(
    (change) => change.kind == CrmDataKind.interaction,
  );
}
