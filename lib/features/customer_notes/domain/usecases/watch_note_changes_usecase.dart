import 'package:orbit/core/services/crm_data_change.dart';
import 'package:orbit/core/services/crm_data_change_service.dart';

/// Streams the CRM change signal filtered to notes, so the notes list Cubit
/// can silently refresh when a note mutation happens somewhere else in the
/// app.
class WatchNoteChangesUseCase {
  WatchNoteChangesUseCase(this._changeService);

  final CrmDataChangeService _changeService;

  Stream<CrmDataChange> call() =>
      _changeService.changes.where((change) => change.kind == CrmDataKind.note);
}
