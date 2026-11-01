import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/features/interactions/data/models/interactions_response_model.dart';

import '../../interactions_test_mocks.dart';

void main() {
  test('parses the capital-I Interactions root list', () {
    final model = InteractionsResponseModel.fromJson(<String, dynamic>{
      ApiKeys.interactionsRootKey: [
        tInteractionJson(id: 1),
        tInteractionJson(id: 2),
      ],
    });

    expect(model.interactions, hasLength(2));
    expect(model.interactions.map((item) => item.interactionId), [1, 2]);
  });

  test('fails the parse when the root is missing or not a list', () {
    expect(
      () => InteractionsResponseModel.fromJson(<String, dynamic>{}),
      throwsFormatException,
    );
    expect(
      () => InteractionsResponseModel.fromJson(<String, dynamic>{
        ApiKeys.interactionsRootKey: 'nope',
      }),
      throwsFormatException,
    );
  });

  test('fails the parse when an item is not an object', () {
    expect(
      () => InteractionsResponseModel.fromJson(<String, dynamic>{
        ApiKeys.interactionsRootKey: ['not-an-object'],
      }),
      throwsFormatException,
    );
  });
}
