import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/services/crm_data_change.dart';
import 'package:orbit/features/opportunities/domain/usecases/watch_crm_changes_usecase.dart';

import '../../opportunities_test_mocks.dart';

void main() {
  group('WatchCrmChangesUseCase', () {
    late MockCrmDataChangeService service;
    late StreamController<CrmDataChange> controller;
    late WatchCrmChangesUseCase useCase;

    setUp(() {
      service = MockCrmDataChangeService();
      controller = StreamController<CrmDataChange>.broadcast();
      addTearDown(controller.close);
      useCase = WatchCrmChangesUseCase(service);
    });

    test('should stream every change signal the service publishes', () async {
      when(() => service.changes).thenAnswer((_) => controller.stream);

      final emitted = <CrmDataChange>[];
      final subscription = useCase().listen(emitted.add);
      addTearDown(subscription.cancel);

      const noteChange = CrmDataChange(kind: CrmDataKind.note, customerId: 3);
      const interactionChange = CrmDataChange(
        kind: CrmDataKind.interaction,
        customerId: 3,
        opportunityId: 9,
      );
      controller
        ..add(noteChange)
        ..add(interactionChange);
      await Future<void>.delayed(Duration.zero);

      expect(emitted, [noteChange, interactionChange]);
    });
  });
}
