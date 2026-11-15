import 'package:orbit/core/services/crm_data_change.dart';

/// In-memory broadcast of successful CRM mutations between features:
/// repositories publish on success, screen holders subscribe to silently
/// refresh what they show.
///
/// Deliberately not persisted and never replayed — a "something changed" ping
/// inside one process, not a cache or a history.
abstract interface class CrmDataChangeService {
  /// Every published change, broadcast to all current subscribers.
  Stream<CrmDataChange> get changes;

  /// Announces one successful mutation; publishing while nobody listens is
  /// not an error and is not remembered.
  void publish(CrmDataChange change);
}
