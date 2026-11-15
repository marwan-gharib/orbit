import 'dart:async';

import 'package:orbit/core/services/crm_data_change.dart';
import 'package:orbit/core/services/crm_data_change_service.dart';

/// Broadcast [CrmDataChangeService]: every listener sees every change
/// published while it listens; changes published with no listener are
/// dropped (late subscribers get nothing from before they subscribed).
final class StreamCrmDataChangeService implements CrmDataChangeService {
  final StreamController<CrmDataChange> _controller =
      StreamController<CrmDataChange>.broadcast();

  @override
  Stream<CrmDataChange> get changes => _controller.stream;

  @override
  void publish(CrmDataChange change) => _controller.add(change);
}
