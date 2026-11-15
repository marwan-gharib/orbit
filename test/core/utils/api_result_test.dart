import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/utils/api_result.dart';

void main() {
  group('Success', () {
    test('should report success and expose the data', () {
      const result = Success<int>(3);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 3);
      expect(result.failureOrNull, isNull);
    });

    test('should fold to the success branch', () {
      const result = Success<int>(3);

      final folded = result.fold((_) => 'failure', (data) => 'data:$data');

      expect(folded, 'data:3');
    });

    test('should compare equal by data and differ from failures', () {
      expect(const Success<int>(3), const Success<int>(3));
      expect(const Success<int>(3), isNot(const Success<int>(4)));
      expect(
        const Success<int>(3),
        isNot(const ResultFailure<int>(NotFoundFailure(message: 'no'))),
      );
    });
  });

  group('ResultFailure', () {
    test('should report failure and expose the failure', () {
      const failure = ServerFailure(message: 'down');
      const result = ResultFailure<int>(failure);

      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, same(failure));
    });

    test('should fold to the failure branch', () {
      const result = ResultFailure<int>(ServerFailure(message: 'down'));

      final folded = result.fold((f) => 'failed:${f.message}', (_) => 'data');

      expect(folded, 'failed:down');
    });

    test('should compare equal by failure', () {
      expect(
        const ResultFailure<int>(ServerFailure(message: 'down')),
        const ResultFailure<int>(ServerFailure(message: 'down')),
      );
      expect(
        const ResultFailure<int>(ServerFailure(message: 'down')),
        isNot(const ResultFailure<int>(ServerFailure(message: 'up'))),
      );
    });
  });
}
