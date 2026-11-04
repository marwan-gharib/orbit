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

  CustomerNotesResult result(List<CustomerNote> notes) =>
      CustomerNotesResult(notes: notes, total: notes.length);

  setUp(() {
    getCustomerNotes = _MockGetCustomerNotesUseCase();
    watchNoteChanges = _MockWatchNoteChangesUseCase();
    changeService = MockCrmDataChangeService();
    when(() => changeService.changes).thenAnswer(
      (_) => Stream.value(
        const CrmDataChange(kind: CrmDataKind.note, customerId: 7),
      ),
    );
    when(() => watchNoteChanges()).thenAnswer((_) => changeService.changes);
  });

  CustomerNotesListCubit newCubit({
    GetCustomerNotesUseCase? g,
    WatchNoteChangesUseCase? w,
  }) => CustomerNotesListCubit(
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
      isA<CustomerNotesListSuccess>()
          .having((s) => s.isRefreshing, 'isRefreshing', isFalse)
          .having((s) => s.refreshFailure, 'refreshFailure', isNull),
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

  group('silent refresh', () {
    WatchNoteChangesUseCase silentWatch() {
      final watch = _MockWatchNoteChangesUseCase();
      when(() => watch())
          .thenAnswer((_) => const Stream<CrmDataChange>.empty());
      return watch;
    }

    test('should keep previous notes and flag isRefreshing when a silent refresh starts', () async {
      final refreshCompleter = Completer<ApiResult<CustomerNotesResult>>();
      var calls = 0;
      when(() => getCustomerNotes(7)).thenAnswer((_) async {
        calls++;
        return calls == 1
            ? Success(result([tCustomerNote()]))
            : refreshCompleter.future;
      });

      final cubit = newCubit(w: silentWatch());
      await cubit.load(7);

      final refreshFuture = cubit.refresh();

      expect(
        cubit.state,
        isA<CustomerNotesListSuccess>()
            .having((s) => s.notes, 'notes', hasLength(1))
            .having((s) => s.isRefreshing, 'isRefreshing', isTrue)
            .having((s) => s.refreshFailure, 'refreshFailure', isNull),
      );

      refreshCompleter.complete(
        Success(result([tCustomerNote(), tCustomerNote(id: 2)])),
      );
      await refreshFuture;

      expect(
        cubit.state,
        isA<CustomerNotesListSuccess>()
            .having((s) => s.notes, 'notes', hasLength(2))
            .having((s) => s.isRefreshing, 'isRefreshing', isFalse),
      );
      await cubit.close();
    });

    test('should keep previous notes and set refreshFailure when a silent refresh fails', () async {
      var calls = 0;
      when(() => getCustomerNotes(7)).thenAnswer((_) async {
        calls++;
        return calls == 1
            ? Success(result([tCustomerNote()]))
            : ResultFailure<CustomerNotesResult>(
                const ServerFailure(message: 'boom'),
              );
      });

      final cubit = newCubit(w: silentWatch());
      await cubit.load(7);

      await cubit.refresh();

      expect(
        cubit.state,
        isA<CustomerNotesListSuccess>()
            .having((s) => s.notes, 'notes', hasLength(1))
            .having((s) => s.isRefreshing, 'isRefreshing', isFalse)
            .having(
              (s) => s.refreshFailure,
              'refreshFailure',
              isA<ServerFailure>(),
            ),
      );
      await cubit.close();
    });

    test('should reload through Loading when refresh is called after a failed load', () async {
      var calls = 0;
      when(() => getCustomerNotes(7)).thenAnswer((_) async {
        calls++;
        return calls == 1
            ? ResultFailure<CustomerNotesResult>(
                const ServerFailure(message: 'boom'),
              )
            : Success(result([tCustomerNote()]));
      });

      final cubit = newCubit(w: silentWatch());
      await cubit.load(7);

      final states = <CustomerNotesListState>[];
      final subscription = cubit.stream.listen(states.add);
      await cubit.refresh();
      await subscription.cancel();

      expect(states.first, isA<CustomerNotesListLoading>());
      expect(cubit.state, isA<CustomerNotesListSuccess>());
      await cubit.close();
    });
  });
}
