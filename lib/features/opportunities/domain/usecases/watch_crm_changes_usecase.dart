import 'package:orbit/core/services/crm_data_change.dart';
import 'package:orbit/core/services/crm_data_change_service.dart';

/// Streams all CRM change signals (interactions and notes) so the
/// opportunity detail Cubit can silently reload when its embedded notes or
/// interactions go stale.
class WatchCrmChangesUseCase {
  WatchCrmChangesUseCase(this._changeService);

  final CrmDataChangeService _changeService;

  Stream<CrmDataChange> call() => _changeService.changes;
}
