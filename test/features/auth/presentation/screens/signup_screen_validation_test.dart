import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/widgets/widgets.dart';
import 'package:orbit/features/auth/domain/params/signup_params.dart';
import 'package:orbit/features/auth/domain/usecases/signup_usecase.dart';
import 'package:orbit/features/auth/presentation/cubits/signup/signup_cubit.dart';
import 'package:orbit/features/auth/presentation/screens/signup_screen.dart';

import '../../../../core/widgets/harness.dart';

class MockSignupUseCase extends Mock implements SignupUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const SignupParams(
        firstName: '',
        lastName: '',
        workEmail: '',
        password: '',
      ),
    );
  });

  Future<void> pumpSignup(
    WidgetTester tester,
    SignupCubit cubit, {
    Size surfaceSize = const Size(800, 1400),
    double textScaleFactor = 1,
  }) async {
    addTearDown(cubit.close);
    await pumpApp(
      tester,
      home: BlocProvider.value(value: cubit, child: const SignupScreen()),
      surfaceSize: surfaceSize,
      textScaleFactor: textScaleFactor,
    );
  }

  Finder firstNameField() => find.byType(TextFormField).at(0);
  Finder lastNameField() => find.byType(TextFormField).at(1);
  Finder emailField() => find.byType(TextFormField).at(2);
  Finder passwordField() => find.byType(TextFormField).at(3);
  Finder confirmPasswordField() => find.byType(TextFormField).at(4);
  Finder submitButton() => find.widgetWithText(AppButton, t.auth.signup.submit);
  AppTextField fieldAt(WidgetTester tester, int index) =>
      tester.widget<AppTextField>(find.byType(AppTextField).at(index));

  group('SignupScreen validation', () {
    testWidgets('should not show errors while typing before submit', (
      tester,
    ) async {
      await pumpSignup(tester, SignupCubit(MockSignupUseCase()));

      await tester.enterText(firstNameField(), 'Adam1');
      await tester.enterText(passwordField(), 'orbit');
      await tester.enterText(confirmPasswordField(), 'different');
      await tester.pump();

      expect(find.text(t.validators.required), findsNothing);
      expect(find.text(t.validators.name), findsNothing);
      expect(find.text(t.validators.passwordLength), findsNothing);
      expect(find.text(t.validators.passwordMismatch), findsNothing);
    });

    testWidgets(
      'should unfocus the fields and show every error on a failed submit',
      (tester) async {
        final useCase = MockSignupUseCase();
        await pumpSignup(tester, SignupCubit(useCase));

        await tester.tap(submitButton());
        await tester.pump();

        expect(find.text(t.validators.required), findsNWidgets(5));
        expect(fieldAt(tester, 0).focusNode?.hasFocus, isFalse);
        expect(fieldAt(tester, 1).focusNode?.hasFocus, isFalse);
        verifyNever(() => useCase(any()));
      },
    );

    testWidgets(
      'should keep the submitted errors until the form is validated again',
      (tester) async {
        final useCase = MockSignupUseCase();
        await pumpSignup(tester, SignupCubit(useCase));

        await tester.tap(submitButton());
        await tester.pump();
        expect(find.text(t.validators.required), findsNWidgets(5));

        // Editing does not revalidate: the errors keep their last submitted text.
        await tester.enterText(firstNameField(), 'Adam1');
        await tester.pump();

        expect(find.text(t.validators.required), findsNWidgets(5));
        expect(find.text(t.validators.name), findsNothing);

        await tester.tap(submitButton());
        await tester.pump();

        expect(find.text(t.validators.name), findsOneWidget);
        expect(find.text(t.validators.required), findsNWidgets(4));
        verifyNever(() => useCase(any()));
      },
    );

    testWidgets(
      'should keep the password checklist live without field errors',
      (tester) async {
        await pumpSignup(tester, SignupCubit(MockSignupUseCase()));

        await tester.enterText(passwordField(), 'abc');
        await tester.pump();

        expect(find.text(t.auth.signup.checklistTitle), findsOneWidget);
        expect(find.text(t.auth.signup.strengthLabel), findsOneWidget);
        expect(find.text(t.auth.signup.strength.weak), findsOneWidget);
        expect(find.text(t.validators.passwordLength), findsNothing);
        expect(fieldAt(tester, 3).errorText, isNull);
      },
    );

    testWidgets('should keep the submitted mismatch until the next submit', (
      tester,
    ) async {
      final useCase = MockSignupUseCase();
      await pumpSignup(tester, SignupCubit(useCase));

      await tester.enterText(firstNameField(), 'Adam');
      await tester.enterText(lastNameField(), 'Orbit');
      await tester.enterText(emailField(), 'adam@orbit.app');
      await tester.enterText(passwordField(), 'Orbit123!');
      await tester.enterText(confirmPasswordField(), 'Orbit123?');
      await tester.pump();

      expect(find.text(t.validators.passwordMismatch), findsNothing);

      await tester.tap(submitButton());
      await tester.pump();

      expect(find.text(t.validators.passwordMismatch), findsOneWidget);
      verifyNever(() => useCase(any()));

      // Editing does not revalidate: the mismatch stays until the next submit.
      await tester.enterText(passwordField(), 'Orbit123?');
      await tester.pump();

      expect(find.text(t.validators.passwordMismatch), findsOneWidget);

      await tester.enterText(confirmPasswordField(), 'Orbit123!x');
      await tester.pump();

      expect(find.text(t.validators.passwordMismatch), findsOneWidget);

      await tester.tap(submitButton());
      await tester.pump();

      expect(find.text(t.validators.passwordMismatch), findsOneWidget);
      verifyNever(() => useCase(any()));
    });

    testWidgets('should move focus without validating when next is pressed', (
      tester,
    ) async {
      await pumpSignup(tester, SignupCubit(MockSignupUseCase()));

      await tester.enterText(firstNameField(), 'Adam1');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      expect(find.text(t.validators.name), findsNothing);
      expect(find.text(t.validators.required), findsNothing);
      expect(fieldAt(tester, 1).focusNode?.hasFocus, isTrue);
    });

    testWidgets('should run the same submit path from the last field', (
      tester,
    ) async {
      final useCase = MockSignupUseCase();
      await pumpSignup(tester, SignupCubit(useCase));

      await tester.showKeyboard(confirmPasswordField());
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text(t.validators.required), findsNWidgets(5));
      verifyNever(() => useCase(any()));
    });
  });

  group('SignupScreen layout', () {
    testWidgets(
      'should render without overflow when the surface is a small phone',
      (tester) async {
        await pumpSignup(
          tester,
          SignupCubit(MockSignupUseCase()),
          surfaceSize: const Size(320, 640),
        );

        expect(find.byType(SignupScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('should render without overflow when the surface is a tablet', (
      tester,
    ) async {
      await pumpSignup(
        tester,
        SignupCubit(MockSignupUseCase()),
        surfaceSize: const Size(1024, 1366),
      );

      expect(find.byType(SignupScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should render without overflow when the text scale is large', (
      tester,
    ) async {
      await pumpSignup(
        tester,
        SignupCubit(MockSignupUseCase()),
        textScaleFactor: 2,
      );

      expect(find.byType(SignupScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
