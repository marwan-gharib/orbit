import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/network/base_api_client.dart';

import 'package:orbit/features/customer_notes/data/datasources/remote/customer_notes_remote_data_source.dart';
import 'package:orbit/features/customer_notes/domain/params/add_customer_note_params.dart';
import 'package:orbit/features/customer_notes/domain/params/update_customer_note_params.dart';

import '../../../customer_notes_test_mocks.dart';

class _MockClient extends Mock implements BaseApiClient {}

void main() {
  late _MockClient client;
  late CustomerNotesRemoteDataSource dataSource;

  setUp(() {
    client = _MockClient();
    dataSource = CustomerNotesRemoteDataSource(client);
  });

  group('fetchCustomerNotes', () {
    test('should GET with customer_id query', () async {
      when(
        () => client.get(
          any(that: equals(Endpoints.crmCustomerNotes)),
          queryParameters: any(named: 'queryParameters'),
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
        ),
      ).thenAnswer((_) async => tCustomerNotesResponseJson());

      final result = await dataSource.fetchCustomerNotes(7);

      expect(result.isSuccess, isTrue);
      verify(
        () => client.get(
          any(that: equals(Endpoints.crmCustomerNotes)),
          queryParameters: <String, dynamic>{
            ApiKeys.customerIdKey: 7,
          },
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
        ),
      );
    });

    test('should return ParsingFailure on malformed body', () async {
      when(
        () => client.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
        ),
      ).thenAnswer((_) async => 'not a map');

      final result = await dataSource.fetchCustomerNotes(7);

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ParsingFailure>());
    });
  });

  group('addCustomerNote', () {
    test('should POST customer_id and note_text only', () async {
      when(
        () => client.post(
          any(that: equals(Endpoints.crmCustomerNotes)),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
        ),
      ).thenAnswer((_) async => null);

      final result = await dataSource.addCustomerNote(
        const AddCustomerNoteParams(customerId: 7, noteText: 'Follow up.'),
      );

      expect(result.isSuccess, isTrue);
      verify(
        () => client.post(
          any(that: equals(Endpoints.crmCustomerNotes)),
          data: <String, Object?>{
            ApiKeys.customerIdKey: 7,
            ApiKeys.noteTextKey: 'Follow up.',
          },
          queryParameters: any(named: 'queryParameters'),
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
        ),
      );
    });
  });

  group('updateCustomerNote', () {
    test('should PATCH note_text only at note-by-id path', () async {
      when(
        () => client.patch(
          any(that: equals('${Endpoints.crmCustomerNotes}1/')),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
        ),
      ).thenAnswer((_) async => null);

      final result = await dataSource.updateCustomerNote(
        const UpdateCustomerNoteParams(noteId: 1, noteText: 'Updated.'),
      );

      expect(result.isSuccess, isTrue);
      verify(
        () => client.patch(
          any(that: equals('${Endpoints.crmCustomerNotes}1/')),
          data: <String, Object?>{ApiKeys.noteTextKey: 'Updated.'},
          queryParameters: any(named: 'queryParameters'),
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
        ),
      );
    });
  });

  group('deleteCustomerNote', () {
    test('should DELETE at note-by-id path with no body', () async {
      when(
        () => client.delete(
          any(that: equals('${Endpoints.crmCustomerNotes}5/')),
          queryParameters: any(named: 'queryParameters'),
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
        ),
      ).thenAnswer((_) async => null);

      final result = await dataSource.deleteCustomerNote(5);

      expect(result.isSuccess, isTrue);
      verify(
        () => client.delete(
          any(that: equals('${Endpoints.crmCustomerNotes}5/')),
          queryParameters: any(named: 'queryParameters'),
          headers: any(named: 'headers'),
          extra: any(named: 'extra'),
        ),
      );
    });
  });
}

Map<String, dynamic> tCustomerNotesResponseJson() => <String, dynamic>{
  'customer_id': 7,
  'total': 1,
  'notes': [tCustomerNoteJson()],
};
