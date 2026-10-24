import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/router/route_names.dart';
import 'package:orbit/core/router/route_paths.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/features/auth/domain/entities/signup_result_entity.dart';
import 'package:orbit/features/auth/domain/params/signup_params.dart';
import 'package:orbit/features/auth/domain/usecases/signup_usecase.dart';
import 'package:orbit/features/auth/presentation/cubits/signup/signup_cubit.dart';
import 'package:orbit/features/auth/presentation/screens/signup_screen.dart';

import '../../../../core/widgets/harness.dart';

class MockSignupUseCase extends Mock implements SignupUseCase {}

const tResult = SignupResult(
  firstName: 'Adam',
  lastName: 'Orbit',
  email: 'adam@orbit.app',
);

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

  Future<void> pumpSignup(WidgetTester tester, SignupCubit cubit) async {
    addTearDown(cubit.close);
    final router = GoRouter(
      initialLocation: RoutePaths.signup,
      routes: [
        GoRoute(
          path: RoutePaths.signup,
          name: RouteNames.signup,
          builder: (_, _) =>
              BlocProvider.value(value: cubit, child: const SignupScreen()),
        ),
        GoRoute(
          path: RoutePaths.pending,
          name: RouteNames.pending,
          builder: (_, _) => const Scaffold(body: Text('Pending destination')),
        ),
        GoRoute(
          path: RoutePaths.login,
          name: RouteNames.login,
          builder: (_, _) => const Scaffold(body: Text('Login destination')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await pumpApp(
      tester,
      routerConfig: router,
      surfaceSize: const Size(800, 1400),
    );
  }

  Finder firstNameField() => find.byType(TextFormField).at(0);
  Finder lastNameField() => find.byType(TextFormField).at(1);
  Finder emailField() => find.byType(TextFormField).at(2);
  Finder passwordField() => find.byType(TextFormField).at(3);
  Finder confirmPasswordField() => find.byType(TextFormField).at(4);
  Finder submitButton() => find.widgetWithText(AppButton, 'Create account');

  Future<void> fillValidForm(WidgetTester tester) async {
    await tester.enterText(firstNameField(), 'Adam');
    await tester.enterText(lastNameField(), 'Orbit');
    await tester.enterText(emailField(), 'adam@orbit.app');
    await tester.enterText(passwordField(), 'Orbit123!');
    await tester.enterText(confirmPasswordField(), 'Orbit123!');
  }

  /// The form is taller than the 600 px default surface; [pumpSignup] uses a
  /// phone-height surface, so submission only needs a tap.
  Future<void> tapSubmit(WidgetTester tester) async {
    await tester.tap(submitButton());
  }

  group('SignupScreen', () {
    testWidgets('should render the five fields, submit and sign-in link', (
      tester,
    ) async {
      await pumpSignup(tester, SignupCubit(MockSignupUseCase()));

      expect(find.text(t.auth.signup.title), findsOneWidget);
      expect(find.text(t.auth.signup.firstNameLabel), findsOneWidget);
      expect(find.text(t.auth.signup.lastNameLabel), findsOneWidget);
      expect(find.text(t.auth.signup.workEmailLabel), findsOneWidget);
      expect(find.text(t.auth.signup.passwordLabel), findsOneWidget);
      expect(find.text(t.auth.signup.confirmPasswordLabel), findsOneWidget);
      expect(submitButton(), findsOneWidget);
      expect(find.text(t.auth.signup.signIn), findsOneWidget);
      expect(find.text(t.auth.signup.checklistTitle), findsNothing);
    });

    testWidgets('should show required errors for every empty field', (
      tester,
    ) async {
      final useCase = MockSignupUseCase();
      await pumpSignup(tester, SignupCubit(useCase));

      await tapSubmit(tester);
      await tester.pump();

      expect(find.text(t.validators.required), findsNWidgets(5));
      verifyNever(() => useCase(any()));
    });

    testWidgets('should show the name and password policy errors', (
      tester,
    ) async {
      final useCase = MockSignupUseCase();
      await pumpSignup(tester, SignupCubit(useCase));

      await tester.enterText(firstNameField(), 'Adam1');
      await tester.enterText(lastNameField(), 'Orbit');
      await tester.enterText(emailField(), 'adam@orbit.app');
      await tester.enterText(passwordField(), 'orbit');
      await tester.enterText(confirmPasswordField(), 'orbit');
      await tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(find.text(t.validators.name), findsOneWidget);
      expect(find.text(t.validators.passwordLength), findsOneWidget);
      expect(find.text(t.auth.signup.checklistTitle), findsOneWidget);
      verifyNever(() => useCase(any()));
    });

    testWidgets('should block submission when the passwords differ', (
      tester,
    ) async {
      final useCase = MockSignupUseCase();
      await pumpSignup(tester, SignupCubit(useCase));

      await tester.enterText(firstNameField(), 'Adam');
      await tester.enterText(lastNameField(), 'Orbit');
      await tester.enterText(emailField(), 'adam@orbit.app');
      await tester.enterText(passwordField(), 'Orbit123!');
      await tester.enterText(confirmPasswordField(), 'Orbit123?');
      await tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(find.text(t.validators.passwordMismatch), findsOneWidget);
      verifyNever(() => useCase(any()));
    });

    testWidgets(
      'should submit trimmed values and replace signup with pending',
      (tester) async {
        final useCase = MockSignupUseCase();
        when(() => useCase(any()))
            .thenAnswer((_) async => const Success(tResult));
        await pumpSignup(tester, SignupCubit(useCase));

        await tester.enterText(firstNameField(), ' Adam ');
        await tester.enterText(lastNameField(), ' Orbit ');
        await tester.enterText(emailField(), ' adam@orbit.app ');
        await tester.enterText(passwordField(), 'Orbit123!');
        await tester.enterText(confirmPasswordField(), 'Orbit123!');
        await tapSubmit(tester);
        await tester.pumpAndSettle();

        final params =
            verify(() => useCase(captureAny())).captured.single as SignupParams;
        expect(params.firstName, 'Adam');
        expect(params.lastName, 'Orbit');
        expect(params.workEmail, 'adam@orbit.app');
        expect(params.password, 'Orbit123!');
        expect(find.text('Pending destination'), findsOneWidget);
        expect(find.byType(SignupScreen), findsNothing);
      },
    );

    testWidgets(
      'should show mapped field errors inline and clear each on edit',
      (tester) async {
        final useCase = MockSignupUseCase();
        when(() => useCase(any())).thenAnswer(
          (_) async => const ResultFailure(
            ValidationFailure(
              message: 'validation',
              fieldErrors: {
                ApiKeys.firstNameKey: ['That name is taken'],
                ApiKeys.passwordKey: ['That password is weak'],
              },
            ),
          ),
        );
        await pumpSignup(tester, SignupCubit(useCase));

        await fillValidForm(tester);
        await tapSubmit(tester);
        await tester.pumpAndSettle();

        expect(find.text('That name is taken'), findsOneWidget);
        expect(find.text('That password is weak'), findsOneWidget);
        expect(find.text(t.auth.signup.errorTitle), findsNothing);
        expect(find.byType(SignupScreen), findsOneWidget);

        await tester.enterText(firstNameField(), 'Eve');
        await tester.pump();

        expect(find.text('That name is taken'), findsNothing);
        expect(find.text('That password is weak'), findsOneWidget);
      },
    );

    testWidgets('should fall back to the banner for unmapped server fields', (
      tester,
    ) async {
      final useCase = MockSignupUseCase();
      when(() => useCase(any())).thenAnswer(
        (_) async => const ResultFailure(
          ValidationFailure(
            message: 'validation',
            fieldErrors: {
              ApiKeys.roleKey: ['Role is not available'],
            },
          ),
        ),
      );
      await pumpSignup(tester, SignupCubit(useCase));

      await fillValidForm(tester);
      await tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(find.text(t.auth.signup.errorTitle), findsOneWidget);
      expect(find.text(t.errors.validation), findsOneWidget);
      expect(find.byType(SignupScreen), findsOneWidget);
    });

    testWidgets('should disable the submit button while signup is in flight', (
      tester,
    ) async {
      final useCase = MockSignupUseCase();
      final pending = Completer<ApiResult<SignupResult>>();
      when(() => useCase(any())).thenAnswer((_) => pending.future);
      await pumpSignup(tester, SignupCubit(useCase));

      await fillValidForm(tester);
      await tapSubmit(tester);
      await tester.pump();

      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.isLoading, isTrue);
      expect(button.onPressed, isNull);

      await tester.tap(find.byType(AppButton));
      await tester.pump();
      verify(() => useCase(any())).called(1);

      pending.complete(const Success(tResult));
      await tester.pumpAndSettle();
    });

    testWidgets('should replace signup with login from the footer link', (
      tester,
    ) async {
      await pumpSignup(tester, SignupCubit(MockSignupUseCase()));

      await tester.tap(find.text(t.auth.signup.signIn));
      await tester.pumpAndSettle();

      expect(find.text('Login destination'), findsOneWidget);
      expect(find.byType(SignupScreen), findsNothing);
    });
  });
}
