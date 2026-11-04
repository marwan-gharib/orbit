import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/customer_notes/presentation/widgets/note_thread_skeleton.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  group('NoteThreadSkeleton', () {
    testWidgets('should announce one localized loading label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpWidget(tester, const NoteThreadSkeleton());

      expect(find.bySemanticsLabel('Loading notes…'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('should render placeholder rows instead of text', (
      tester,
    ) async {
      await pumpWidget(tester, const NoteThreadSkeleton());

      expect(find.text('Loading notes…'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
