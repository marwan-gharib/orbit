import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/features/auth/presentation/widgets/auth_page_scaffold.dart';

import '../../../../core/widgets/harness.dart';

void main() {
  group('AuthPageScaffold', () {
    testWidgets('should render its content and footer', (tester) async {
      await pumpWidget(
        tester,
        const AuthPageScaffold(
          footer: Text('Footer'),
          children: [Text('Main content')],
        ),
      );

      expect(find.text('Main content'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);
    });

    testWidgets('should render without a footer', (tester) async {
      await pumpWidget(
        tester,
        const AuthPageScaffold(children: [Text('Main content')]),
      );

      expect(find.text('Main content'), findsOneWidget);
      expect(find.text('Footer'), findsNothing);
    });
  });
}
