import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/services/crm_data_change.dart';
import 'package:orbit/core/services/stream_crm_data_change_service.dart';

void main() {
  late StreamCrmDataChangeService service;

  setUp(() {
    service = StreamCrmDataChangeService();
  });

  const tInteractionChange = CrmDataChange(
    kind: CrmDataKind.interaction,
    customerId: 7,
    opportunityId: 2,
  );

  const tNoteChange = CrmDataChange(kind: CrmDataKind.note, customerId: 7);

  /// Lets the broadcast controller's delivery microtasks run so collected
  /// lists are complete before assertions.
  Future<void> flush() => Future<void>.delayed(Duration.zero);

  test('should deliver the exact change to a single listener', () async {
    final received = <CrmDataChange>[];
    final subscription = service.changes.listen(received.add);

    service.publish(tInteractionChange);
    await flush();
    await subscription.cancel();

    expect(received, [tInteractionChange]);
  });

  test('should broadcast to every current listener', () async {
    final first = <CrmDataChange>[];
    final second = <CrmDataChange>[];
    final subscriptions = [
      service.changes.listen(first.add),
      service.changes.listen(second.add),
    ];

    service.publish(tNoteChange);
    await flush();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }

    expect(first, [tNoteChange]);
    expect(second, [tNoteChange]);
  });

  test('should not replay published changes to late subscribers', () async {
    service.publish(tInteractionChange);
    await flush();

    final received = <CrmDataChange>[];
    final lateSubscription = service.changes.listen(received.add);
    await flush();
    await lateSubscription.cancel();

    expect(received, isEmpty);
  });

  test('should tolerate publishing while nobody listens', () {
    expect(() => service.publish(tInteractionChange), returnsNormally);
  });

  test('should deliver published changes in order', () async {
    final received = <CrmDataChange>[];
    final subscription = service.changes.listen(received.add);

    service.publish(tInteractionChange);
    service.publish(tNoteChange);
    await flush();
    await subscription.cancel();

    expect(received, [tInteractionChange, tNoteChange]);
  });
}
