import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/opportunities/data/models/opportunities_page_response_model.dart';

import '../../opportunities_test_mocks.dart';

void main() {
  group('OpportunitiesPageResponseModel', () {
    test('should map from JSON', () {
      final model = OpportunitiesPageResponseModel.fromJson(
        tPageResponseJson(count: 6, next: '2'),
      );

      expect(model.count, 6);
      expect(model.next, '2');
      expect(model.previous, isNull);
      expect(model.results, hasLength(1));
      expect(model.results.first.opportunityId, 1);
    });

    test('should throw when results root is not a list', () {
      expect(
        () => OpportunitiesPageResponseModel.fromJson(<String, dynamic>{
          'count': 0,
          'next': null,
          'previous': null,
          'results': 'not a list',
        }),
        throwsFormatException,
      );
    });

    test('should tolerate missing next/previous', () {
      final model = OpportunitiesPageResponseModel.fromJson(<String, dynamic>{
        'count': 0,
        'results': [],
      });

      expect(model.next, isNull);
      expect(model.previous, isNull);
    });
  });
}
