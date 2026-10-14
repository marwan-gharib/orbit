import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/animations/animations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String?> calls;

  setUp(() {
    calls = <String?>[];
    AppHaptics.enabled = true;
    // Every haptic travels as 'HapticFeedback.vibrate' in this Flutter
    // version; the impact type rides in the call arguments.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call.arguments as String?);
          return null;
        });
  });

  tearDown(() {
    AppHaptics.enabled = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> settle() => pumpEventQueue();

  test('should play the light impact when light is called', () async {
    AppHaptics.light();
    await settle();

    expect(calls, contains('HapticFeedbackType.lightImpact'));
  });

  test('should play the medium impact when medium is called', () async {
    AppHaptics.medium();
    await settle();

    expect(calls, contains('HapticFeedbackType.mediumImpact'));
  });

  test('should play the heavy impact when heavy is called', () async {
    AppHaptics.heavy();
    await settle();

    expect(calls, contains('HapticFeedbackType.heavyImpact'));
  });

  test('should play the selection click when selection is called', () async {
    AppHaptics.selection();
    await settle();

    expect(calls, contains('HapticFeedbackType.selectionClick'));
  });

  test(
    'should send the bare vibrate without a type payload when error is called',
    () async {
      AppHaptics.error();
      await settle();

      expect(calls, <String?>[null]);
    },
  );

  test(
    'should play the mapped impact when play is called with a type',
    () async {
      AppHaptics.play(HapticType.medium);
      await settle();

      expect(calls, contains('HapticFeedbackType.mediumImpact'));
    },
  );

  test('should stay silent when play is called with none', () async {
    AppHaptics.play(HapticType.none);
    await settle();

    expect(calls, isEmpty);
  });

  test('should stay silent when the global switch is off', () async {
    AppHaptics.enabled = false;

    AppHaptics.light();
    AppHaptics.error();
    await settle();

    expect(calls, isEmpty);
  });
}
