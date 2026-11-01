import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/constants/endpoints.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/network/base_api_client.dart';
import 'package:orbit/features/interactions/data/datasources/remote/interactions_remote_data_source.dart';
import 'package:orbit/features/interactions/domain/params/add_interaction_params.dart';
import 'package:orbit/features/interactions/domain/params/update_interaction_params.dart';

class MockBaseApiClient extends Mock implements BaseApiClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(
      AddInteractionParams(
        type: InteractionType.call,
        subject: 'x',
        description: '',
        interactionDate: DateTime(2025),
        customerId: 1,
      ),
    );
    registerFallbackValue(
      UpdateInteractionParams(
        interactionId: 1,
        type: InteractionType.call,
        subject: 'x',
        description: '',
        interactionDate: DateTime(2025),
      ),
    );
  });

  late MockBaseApiClient client;
  late InteractionsRemoteDataSource dataSource;

  setUp(() {
    client = MockBaseApiClient();
    dataSource = InteractionsRemoteDataSource(client);
  });

  void stubGet(Object body) {
    when(
      () => client.get(any(), queryParameters: any(named: 'queryParameters')),
    ).thenAnswer((_) async => body);
  }

  test('fetch sends only the given filters and parses the list', () async {
    final tBody = <String, dynamic>{
      ApiKeys.interactionsRootKey: [tWireInteraction(id: 10)],
    };
    stubGet(tBody);

    final result = await dataSource.fetchInteractions(
      subject: 'Sync',
      customerId: 7,
    );

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull!.interactions.single.interactionId, 10);
    final query =
        verify(
              () => client.get(
                Endpoints.crmInteractions,
                queryParameters: captureAny(named: 'queryParameters'),
              ),
            ).captured.single
            as Map<String, Object?>;
    expect(query, {ApiKeys.subjectKey: 'Sync', ApiKeys.customerIdKey: 7});
  });

  test('fetch maps a filter type to its wire value', () async {
    stubGet(<String, dynamic>{ApiKeys.interactionsRootKey: <Object?>[]});

    await dataSource.fetchInteractions(type: InteractionType.meeting);

    final query =
        verify(
              () => client.get(
                Endpoints.crmInteractions,
                queryParameters: captureAny(named: 'queryParameters'),
              ),
            ).captured.single
            as Map<String, Object?>;
    expect(query, {ApiKeys.typeKey: 'meeting'});
  });

  test(
    'fetch maps network exceptions through ErrorMapper to failures',
    () async {
      when(
        () => client.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(const NotFoundException());

      final result = await dataSource.fetchInteractions();

      expect(result.failureOrNull, isA<NotFoundFailure>());
    },
  );

  test('fetch maps a malformed body to ParsingFailure', () async {
    stubGet('not-an-object');

    final result = await dataSource.fetchInteractions();

    expect(result.failureOrNull, isA<ParsingFailure>());
  });

  test('add posts the required wire keys plus employee id, omitting the '
      'optional owner ids when null (OQ-9: no null keys)', () async {
    when(() => client.post(any(), data: any(named: 'data')))
        .thenAnswer((_) async => {'message': 'ok'});

    final result = await dataSource.addInteraction(
      AddInteractionParams(
        type: InteractionType.call,
        subject: 'Kickoff call',
        description: 'Intro',
        interactionDate: DateTime.utc(2025, 6, 1),
        customerId: 7,
      ),
      employeeId: 46,
    );

    expect(result.isSuccess, isTrue);
    final body =
        verify(
              () => client.post(
                Endpoints.crmInteractions,
                data: captureAny(named: 'data'),
              ),
            ).captured.single
            as Map<String, Object?>;
    expect(body, {
      ApiKeys.typeKey: 'call',
      ApiKeys.subjectKey: 'Kickoff call',
      ApiKeys.descriptionKey: 'Intro',
      ApiKeys.interactionDateKey: '2025-06-01',
      ApiKeys.customerIdKey: 7,
      ApiKeys.employeeIdKey: 46,
    });
  });

  test(
    'add includes owner ids only when provided (date-only wire shape)',
    () async {
      when(() => client.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => {'message': 'ok'});

      await dataSource.addInteraction(
        AddInteractionParams(
          type: InteractionType.meeting,
          subject: 'Sync',
          description: 'Notes',
          interactionDate: DateTime.utc(2025, 6, 1),
          customerId: 7,
          contactId: 3,
          opportunityId: 2,
        ),
        employeeId: 46,
      );

      final body =
          verify(
                () => client.post(
                  Endpoints.crmInteractions,
                  data: captureAny(named: 'data'),
                ),
              ).captured.single
              as Map<String, Object?>;
      expect(body[ApiKeys.contactIdKey], 3);
      expect(body[ApiKeys.opportunityIdKey], 2);
      expect(body[ApiKeys.interactionDateKey], '2025-06-01');
    },
  );

  test('update patches EXACTLY the five editable wire fields — owner/context '
      'fields must never appear', () async {
    when(() => client.patch(any(), data: any(named: 'data')))
        .thenAnswer((_) async => {'message': 'ok'});

    final result = await dataSource.updateInteraction(
      UpdateInteractionParams(
        interactionId: 8,
        type: InteractionType.meeting,
        subject: 'Sync meeting',
        description: 'Notes',
        interactionDate: DateTime.utc(2025, 6, 1),
      ),
    );

    expect(result.isSuccess, isTrue);
    final body =
        verify(
              () => client.patch(
                Endpoints.crmInteractions,
                data: captureAny(named: 'data'),
              ),
            ).captured.single
            as Map<String, Object?>;
    expect(body, {
      ApiKeys.interactionIdKey: 8,
      ApiKeys.typeKey: 'meeting',
      ApiKeys.subjectKey: 'Sync meeting',
      ApiKeys.descriptionKey: 'Notes',
      ApiKeys.interactionDateKey: '2025-06-01',
    });
  });

  test('delete carries interaction_id in the request BODY (A-7: the core '
      'delete(data:) seam is exercised end to end)', () async {
    when(() => client.delete(any(), data: any(named: 'data')))
        .thenAnswer((_) async => {'message': 'ok'});

    final result = await dataSource.deleteInteraction(8);

    expect(result.isSuccess, isTrue);
    final body =
        verify(
              () => client.delete(
                Endpoints.crmInteractions,
                data: captureAny(named: 'data'),
              ),
            ).captured.single
            as Map<String, Object?>;
    expect(body, {ApiKeys.interactionIdKey: 8});
  });
}

/// The wire shape of one interaction, for GET response stubbing.
Map<String, dynamic> tWireInteraction({int id = 1}) => <String, dynamic>{
  ApiKeys.interactionIdKey: id,
  ApiKeys.typeKey: 'call',
  ApiKeys.subjectKey: 'Sync meeting',
  ApiKeys.descriptionKey: 'Notes',
  ApiKeys.interactionDateKey: '2025-06-01T00:00:00Z',
  ApiKeys.customerIdKey: 7,
  ApiKeys.employeeIdKey: 46,
};
