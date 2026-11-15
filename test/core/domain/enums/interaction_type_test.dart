import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';

void main() {
  group('InteractionType.fromValue', () {
    test('should map every wire value', () {
      expect(InteractionType.fromValue('call'), InteractionType.call);
      expect(InteractionType.fromValue('email'), InteractionType.email);
      expect(InteractionType.fromValue('meeting'), InteractionType.meeting);
    });

    test('should be case- and whitespace-tolerant', () {
      expect(InteractionType.fromValue('Meeting '), InteractionType.meeting);
      expect(InteractionType.fromValue('CALL'), InteractionType.call);
    });

    test(
      'should fall back to unknown for null, blank or unrecognized values',
      () {
        expect(InteractionType.fromValue(null), InteractionType.unknown);
        expect(InteractionType.fromValue(''), InteractionType.unknown);
        expect(InteractionType.fromValue('   '), InteractionType.unknown);
        expect(InteractionType.fromValue('video'), InteractionType.unknown);
      },
    );
  });
}
