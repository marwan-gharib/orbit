import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/widgets/widgets.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:orbit/features/auth/presentation/cubits/google_sign_in/google_sign_in_cubit.dart';
import 'package:orbit/features/auth/presentation/cubits/google_sign_in/google_sign_in_state.dart';
import 'package:orbit/features/auth/domain/params/login_params.dart';
import 'package:orbit/features/auth/domain/usecases/login_usecase.dart';
import 'package:orbit/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:orbit/features/auth/presentation/screens/login_screen.dart';

import '../../../../core/widgets/harness.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockGoogleSignInCubit extends MockCubit<GoogleSignInState>
    implements GoogleSignInCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
  });

  Future<void> pumpLogin(
    WidgetTester tester,
    LoginCubit cubit, {
    Size surfaceSize = const Size(800, 1000),
    double textScaleFactor = 1,
  }) async {
    addTearDown(cubit.close);
    final googleCubit = MockGoogleSignInCubit();
    when(() => googleCubit.state).thenReturn(const GoogleSignInIdle());
    when(() => googleCubit.stream).thenAnswer((_) => const Stream.empty());
    addTearDown(googleCubit.close);

    await pumpApp(
      tester,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<LoginCubit>.value(value: cubit),
          BlocProvider<GoogleSignInCubit>.value(value: googleCubit),
        ],
        child: const LoginScreen(),
      ),
      surfaceSize: surfaceSize,
      textScaleFactor: textScaleFactor,
    );
  }

  Finder emailField() => find.byType(TextFormField).at(0);
  Finder submitButton() => find.widgetWithText(AppButton, t.auth.login.submit);
  AppTextField fieldAt(WidgetTester tester, int index) =>
      tester.widget<AppTextField>(find.byType(AppTextField).at(index));

  group('LoginScreen validation', () {
    testWidgets('should not show errors while typing before submit', (
      tester,
    ) async {
      final useCase = MockLoginUseCase();
      await pumpLogin(tester, LoginCubit(useCase));

      await tester.enterText(emailField(), 'not-an-email');
      await tester.pump();

      expect(find.text(t.validators.required), findsNothing);
      expect(find.text(t.validators.email), findsNothing);
      verifyNever(() => useCase(any()));
    });

    testWidgets(
      'should unfocus the fields and show both errors on a failed submit',
      (tester) async {
        final useCase = MockLoginUseCase();
        await pumpLogin(tester, LoginCubit(useCase));

        await tester.tap(submitButton());
        await tester.pump();

        expect(find.text(t.validators.required), findsNWidgets(2));
        final emailFieldNode = tester
            .widget<TextField>(find.byType(TextField).at(0))
            .focusNode;
        expect(emailFieldNode?.hasFocus, isFalse);
        expect(fieldAt(tester, 1).focusNode?.hasFocus, isFalse);
        verifyNever(() => useCase(any()));
      },
    );

    testWidgets(
      'should keep the submitted errors until the form is validated again',
      (tester) async {
        final useCase = MockLoginUseCase();
        await pumpLogin(tester, LoginCubit(useCase));

        await tester.tap(submitButton());
        await tester.pump();
        expect(find.text(t.validators.required), findsNWidgets(2));

        // Editing does not revalidate: the errors keep their last submitted text.
        await tester.enterText(emailField(), 'not-an-email');
        await tester.pump();
        expect(find.text(t.validators.required), findsNWidgets(2));
        expect(find.text(t.validators.email), findsNothing);

        await tester.tap(submitButton());
        await tester.pump();

        expect(find.text(t.validators.email), findsOneWidget);
        expect(find.text(t.validators.required), findsOneWidget);
        verifyNever(() => useCase(any()));
      },
    );

    testWidgets('should move focus without validating when next is pressed', (
      tester,
    ) async {
      await pumpLogin(tester, LoginCubit(MockLoginUseCase()));

      await tester.enterText(emailField(), 'not-an-email');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      expect(find.text(t.validators.email), findsNothing);
      expect(find.text(t.validators.required), findsNothing);
      expect(fieldAt(tester, 1).focusNode?.hasFocus, isTrue);
    });
  });

  group('LoginScreen layout', () {
    testWidgets(
      'should render without overflow when the surface is a small phone',
      (tester) async {
        await pumpLogin(
          tester,
          LoginCubit(MockLoginUseCase()),
          surfaceSize: const Size(320, 640),
        );

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('should render without overflow when the surface is a tablet', (
      tester,
    ) async {
      await pumpLogin(
        tester,
        LoginCubit(MockLoginUseCase()),
        surfaceSize: const Size(1024, 1366),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should render without overflow when the text scale is large', (
      tester,
    ) async {
      await pumpLogin(
        tester,
        LoginCubit(MockLoginUseCase()),
        textScaleFactor: 2,
      );

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
