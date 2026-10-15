import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/widgets/app_text_field.dart';

import 'harness.dart';

void main() {
  group('AppTextField', () {
    testWidgets('should render TextFormField with label', (tester) async {
      await pumpWidget(tester, const AppTextField(label: 'Email'));
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('should show hint when provided', (tester) async {
      await pumpWidget(
        tester,
        const AppTextField(label: 'Email', hint: 'Enter your email'),
      );
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('should call validator when form is validated', (tester) async {
      final formKey = GlobalKey<FormState>();
      await pumpWidget(
        tester,
        Form(
          key: formKey,
          child: AppTextField(
            label: 'Email',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              return null;
            },
          ),
        ),
      );
      formKey.currentState?.validate();
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('should toggle obscure text when suffix is tapped', (
      tester,
    ) async {
      await pumpWidget(
        tester,
        const AppTextField(label: 'Password', obscureText: true),
      );
      // Initially text should be obscured - we can't directly access the property
      // but we can verify the visibility_off icon is shown
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // After tap, visibility icon should be shown
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should call onChanged when text changes', (tester) async {
      var changedValue = '';
      await pumpWidget(
        tester,
        AppTextField(
          label: 'Email',
          onChanged: (value) => changedValue = value,
        ),
      );
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      expect(changedValue, 'test@example.com');
    });

    testWidgets('should call onFieldSubmitted when submitted', (tester) async {
      var submittedValue = '';
      await pumpWidget(
        tester,
        AppTextField(
          label: 'Email',
          onFieldSubmitted: (value) => submittedValue = value,
        ),
      );
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submittedValue, 'test@example.com');
    });

    testWidgets('should show prefix icon when provided', (tester) async {
      await pumpWidget(
        tester,
        const AppTextField(label: 'Search', prefixIcon: Icon(Icons.search)),
      );
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should be disabled when enabled is false', (tester) async {
      await pumpWidget(
        tester,
        const AppTextField(label: 'Email', enabled: false),
      );
      final textField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(textField.enabled, isFalse);
    });
  });
}
