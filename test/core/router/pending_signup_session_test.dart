import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/router/pending_signup_session.dart';

void main() {
  group('PendingSignupSession', () {
    test('should be empty before any signup', () {
      final session = PendingSignupSession();

      expect(session.email, isNull);
      expect(session.hasPendingSignup, isFalse);
    });

    test('should expose the email and notify when a signup starts', () {
      final session = PendingSignupSession();
      var notifications = 0;
      session.addListener(() => notifications++);

      session.start('adam@orbit.app');

      expect(session.email, 'adam@orbit.app');
      expect(session.hasPendingSignup, isTrue);
      expect(notifications, 1);
    });

    test('should not notify when the same email starts again', () {
      final session = PendingSignupSession()..start('adam@orbit.app');
      var notifications = 0;
      session.addListener(() => notifications++);

      session.start('adam@orbit.app');

      expect(notifications, 0);
    });

    test('should clear the email and notify', () {
      final session = PendingSignupSession()..start('adam@orbit.app');
      var notifications = 0;
      session.addListener(() => notifications++);

      session.clear();

      expect(session.email, isNull);
      expect(session.hasPendingSignup, isFalse);
      expect(notifications, 1);
    });

    test('should not notify when clearing an empty session', () {
      final session = PendingSignupSession();
      var notifications = 0;
      session.addListener(() => notifications++);

      session.clear();

      expect(notifications, 0);
    });
  });
}
