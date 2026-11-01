import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/services/crm_data_change.dart';
import 'package:orbit/core/utils/api_result.dart';

import 'package:orbit/features/customer_notes/domain/entities/customer_note_entity.dart';
import 'package:orbit/features/customer_notes/domain/entities/customer_notes_result_entity.dart';
import 'package:orbit/features/customer_notes/domain/usecases/get_customer_notes_usecase.dart';
import 'package:orbit/features/customer_notes/domain/usecases/watch_note_changes_usecase.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_notes_list/customer_notes_list_cubit.dart';
import 'package:orbit/features/customer_notes/presentation/cubits/customer_notes_list/customer_notes_list_state.dart';

import '../../../customer_notes_test_mocks.dart';

class _MockGetCustomerNotesUseCase extends Mock
    implements GetCustomerNotesUseCase {}

class _MockWatchNoteChangesUseCase extends Mock
    implements WatchNoteChangesUseCase {}

void main() {
  setUpAll(registerCustomerNotesFallbacks);

  late _MockGetCustomerNotesUseCase getCustomerNotes;
  late _MockWatchNoteChangesUseCase watchNoteChanges;
  late MockCrmDataChangeService changeService;

  CustomerNotesResult result(List<CustomerNote> notes) => CustomerNotesResult(
    notes: notes,
    total: notes.length,
  );

  setUp(() {
    getCustomerNotes = _MockGetCustomerNotesUseCase();
    watchNoteChanges = _MockWatchNoteChangesUseCase();
    changeService = MockCrmDataChangeService();
    when(() => changeService.changes).thenAnswer((_) => Stream.value(
      const CrmDataChange(kind: CrmDataKind.note, customerId: 7),
    ));
    when(() => watchNoteChanges()).thenAnswer((_) => changeService.changes);
  });

  CustomerNotesListCubit newCubit({
    GetCustomerNotesUseCase? g,
    WatchNoteChangesUseCase? w,
  }) =>
      CustomerNotesListCubit(
        getCustomerNotes: g ?? getCustomerNotes,
        watchNoteChanges: w ?? watchNoteChanges,
      );

  test('should have CustomerNotesListInitial as the initial state', () {
    expect(newCubit().state, isA<CustomerNotesListInitial>());
  });

  test('should emit Loading then Success on load', () async {
    when(() => getCustomerNotes(any()))
        .thenAnswer((_) async => Success(result([tCustomerNote()])));

    final cubit = newCubit();
    await cubit.load(7);
    await Future<void>.delayed(Duration.zero);

    expect(
      cubit.state,
      isA<CustomerNotesListSuccess>().having(
        (s) => s.notes,
        'notes',
        hasLength(1),
      ),
    );
  });

  test('should emit Loading then Empty when no notes', () async {
    when(() => getCustomerNotes(any()))
        .thenAnswer((_) async => Success(result([])));

    final cubit = newCubit();
    await cubit.load(7);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<CustomerNotesListEmpty>());
  });

  test('should emit Loading then Error on failure', () async {
    const failure = UnauthorizedFailure(message: 'no session');
    when(() => getCustomerNotes(any()))
        .thenAnswer((_) async => ResultFailure<CustomerNotesResult>(failure));

    final cubit = newCubit();
    await cubit.load(7);
    await Future<void>.delayed(Duration.zero);

    expect(
      cubit.state,
      isA<CustomerNotesListError>().having(
        (s) => s.failure,
        'failure',
        isA<UnauthorizedFailure>(),
      ),
    );
  });

  test('should silently refresh on matching CRM change', () async {
    when(() => getCustomerNotes(7))
        .thenAnswer((_) async => Success(result([tCustomerNote()])));

    final cubit = newCubit();
    await cubit.load(7);

    // Publish a matching note change for customer 7
    changeService.publish(
      const CrmDataChange(kind: CrmDataKind.note, customerId: 7),
    );

    await Future<void>.delayed(Duration.zero);

    expect(
      cubit.state,
      isA<CustomerNotesListSuccess>().having(
        (s) => s.isRefreshing,
        'isRefreshing',
        isFalse,
      ).having(
        (s) => s.refreshFailure,
        'refreshFailure',
        isNull,
      ),
    );
  });

  test('should not refresh on non-matching CRM change', () async {
    when(() => getCustomerNotes(any()))
        .thenAnswer((_) async => Success(result([tCustomerNote()])));

    final cubit = newCubit();
    await cubit.load(7);
    await Future<void>.delayed(Duration.zero);

    changeService.publish(
      const CrmDataChange(kind: CrmDataKind.note, customerId: 99),
    );

    await Future<void>.delayed(Duration.zero);

    // State should remain the initial success (not refreshing)
    expect(
      cubit.state,
      isA<CustomerNotesListSuccess>().having(
        (s) => s.isRefreshing,
        'isRefreshing',
        isFalse,
      ),
    );
  });
}
