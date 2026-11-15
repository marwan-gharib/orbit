import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orbit/core/services/crm_data_change.dart';

import 'package:orbit/features/customer_notes/domain/usecases/watch_note_changes_usecase.dart';

import '../../customer_notes_test_mocks.dart';

void main() {
  setUpAll(registerCustomerNotesFallbacks);

  late MockCrmDataChangeService changeService;
  late WatchNoteChangesUseCase useCase;

  setUp(() {
    changeService = MockCrmDataChangeService();
    useCase = WatchNoteChangesUseCase(changeService);
  });

  test(
    'should deliver only note-kind changes when mixed changes are published',
    () async {
      // Arrange
      final received = <CrmDataChange>[];
      final published = StreamController<CrmDataChange>();
      when(() => changeService.changes).thenAnswer((_) => published.stream);
      final subscription = useCase().listen(received.add);

      // Act — one note change among non-note changes.
      published.add(
        const CrmDataChange(kind: CrmDataKind.interaction, customerId: 7),
      );
      published.add(const CrmDataChange(kind: CrmDataKind.note, customerId: 7));
      published.add(
        const CrmDataChange(kind: CrmDataKind.interaction, customerId: 9),
      );
      await published.close();
      await subscription.cancel();

      // Assert
      expect(received, hasLength(1));
      expect(received.single.kind, CrmDataKind.note);
      expect(received.single.customerId, 7);
    },
  );

  test('should deliver every note change unchanged regardless of customer or opportunity', () async {
    // Arrange
    const opportunityNote = CrmDataChange(
      kind: CrmDataKind.note,
      customerId: 9,
      opportunityId: 4,
    );
    const plainNote = CrmDataChange(kind: CrmDataKind.note, customerId: 7);
    final received = <CrmDataChange>[];
    final published = StreamController<CrmDataChange>();
    when(() => changeService.changes).thenAnswer((_) => published.stream);
    final subscription = useCase().listen(received.add);

    // Act
    published.add(opportunityNote);
    published.add(plainNote);
    await published.close();
    await subscription.cancel();

    // Assert
    expect(received, [opportunityNote, plainNote]);
  });
}
