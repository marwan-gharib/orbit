import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/network/session/session_expired_notifier.dart';

void main() {
  group('SessionExpiredNotifier', () {
    late SessionExpiredNotifier notifier;

    setUp(() {
      notifier = SessionExpiredNotifier();
    });

    test('N-01: initial state has isExpired == false and currentGeneration == 0', () {
      expect(notifier.isExpired, isFalse);
      expect(notifier.currentGeneration, 0);
    });

    test('N-02: signalExpired() sets isExpired == true, increments generation, and calls listeners', () {
      var listenerCalls = 0;
      notifier.addListener(() => listenerCalls++);

      notifier.signalExpired();

      expect(notifier.isExpired, isTrue);
      expect(notifier.currentGeneration, 1);
      expect(listenerCalls, 1);
    });

    test('N-03: subsequent calls to signalExpired() when already expired are no-ops', () {
      var listenerCalls = 0;
      notifier.addListener(() => listenerCalls++);

      notifier.signalExpired();
      expect(listenerCalls, 1);
      expect(notifier.currentGeneration, 1);

      // Second call
      notifier.signalExpired();
      expect(listenerCalls, 1);
      expect(notifier.currentGeneration, 1);
      expect(notifier.isExpired, isTrue);
    });

    test('N-04: reset() sets isExpired == false, increments generation, and notifies listeners', () {
      notifier.signalExpired();
      expect(notifier.isExpired, isTrue);
      expect(notifier.currentGeneration, 1);

      var listenerCalls = 0;
      notifier.addListener(() => listenerCalls++);

      notifier.reset();

      expect(notifier.isExpired, isFalse);
      expect(notifier.currentGeneration, 2);
      expect(listenerCalls, 1);

      // Calling reset when not expired is a no-op
      notifier.reset();
      expect(listenerCalls, 1);
      expect(notifier.currentGeneration, 2);
    });

    test('N-05: incrementGeneration() increments counter without modifying isExpired', () {
      var listenerCalls = 0;
      notifier.addListener(() => listenerCalls++);

      expect(notifier.currentGeneration, 0);
      notifier.incrementGeneration();
      expect(notifier.currentGeneration, 1);
      expect(notifier.isExpired, isFalse);
      expect(listenerCalls, 0); // incrementGeneration does not notify listeners
    });
  });
}
