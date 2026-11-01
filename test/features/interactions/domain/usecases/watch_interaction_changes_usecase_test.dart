import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orbit/core/services/crm_data_change.dart';

import 'package:orbit/features/interactions/domain/usecases/watch_interaction_changes_usecase.dart';

import '../../interactions_test_mocks.dart';

void main() {
  setUpAll(registerInteractionsFallbacks);

  late MockCrmDataChangeService changeService;
  late WatchInteractionChangesUseCase useCase;

  setUp(() {
    changeService = MockCrmDataChangeService();
    useCase = WatchInteractionChangesUseCase(changeService);
  });

  test('streams only interaction-kind changes from the signal', () async {
    final received = <CrmDataChange>[];
    final published = StreamController<CrmDataChange>();
    when(() => changeService.changes).thenAnswer((_) => published.stream);
    final subscription = useCase().listen(received.add);

    published.add(
      const CrmDataChange(kind: CrmDataKind.interaction, customerId: 7),
    );
    published.add(const CrmDataChange(kind: CrmDataKind.note, customerId: 7));
    published.add(
      const CrmDataChange(kind: CrmDataKind.interaction, customerId: 9),
    );
    await published.close();
    await subscription.cancel();

    expect(received, hasLength(2));
    expect(
      received.map((change) => change.kind),
      everyElement(CrmDataKind.interaction),
    );
  });
}
