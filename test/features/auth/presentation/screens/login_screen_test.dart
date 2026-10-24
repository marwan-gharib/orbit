import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/router/route_names.dart';
import 'package:orbit/core/router/route_paths.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/features/auth/domain/entities/auth_session_entity.dart';
import 'package:orbit/features/auth/domain/entities/permission_entity.dart';
import 'package:orbit/features/auth/domain/entities/user_entity.dart';
import 'package:orbit/features/auth/domain/enums/user_role.dart';
import 'package:orbit/features/auth/domain/params/login_params.dart';
import 'package:orbit/features/auth/domain/usecases/login_usecase.dart';
import 'package:orbit/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:orbit/features/auth/presentation/screens/login_screen.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

const tUser = User(
  firstName: 'Adam',
  lastName: 'Orbit',
  code: 'EMP-2026-9582',
  email: 'adam@orbit.app',
  role: UserRole.admin,
  roleName: 'Admin',
  permissions: [Permission(module: 'projects', permission: 'view')],
);

const tSession = AuthSession(
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  user: tUser,
);

void main() {
  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
  });

  /// Pumps [LoginScreen] under its real provider shape with a tiny router so
  /// `goNamed` targets resolve without pulling the whole app route table.
  Future<void> pumpLogin(WidgetTester tester, LoginCubit cubit) async {
    addTearDown(cubit.close);
    final router = GoRouter(
      initialLocation: RoutePaths.login,
      routes: [
        GoRoute(
          path: RoutePaths.login,
          name: RouteNames.login,
          builder: (_, _) =>
              BlocProvider.value(value: cubit, child: const LoginScreen()),
        ),
        GoRoute(
          path: RoutePaths.home,
          name: RouteNames.home,
          builder: (_, _) => const Scaffold(body: Text('Home destination')),
        ),
        GoRoute(
          path: RoutePaths.signup,
          name: RouteNames.signup,
          builder: (_, _) => const Scaffold(body: Text('Signup destination')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
  }

  Finder emailField() => find.byType(TextFormField).at(0);
  Finder passwordField() => find.byType(TextFormField).at(1);
  Finder submitButton() => find.widgetWithText(AppButton, 'Sign in');

  group('LoginScreen', () {
    testWidgets('should render the header, fields, submit and signup link', (
      tester,
    ) async {
      await pumpLogin(tester, LoginCubit(MockLoginUseCase()));

      expect(find.text(t.auth.login.title), findsOneWidget);
      expect(find.text(t.auth.login.subtitle), findsOneWidget);
      expect(find.text(t.auth.login.emailLabel), findsOneWidget);
      expect(find.text(t.auth.login.passwordLabel), findsOneWidget);
      expect(submitButton(), findsOneWidget);
      expect(find.text(t.auth.login.createAccount), findsOneWidget);
    });

    testWidgets('should block submission and show required errors when empty', (
      tester,
    ) async {
      final useCase = MockLoginUseCase();
      await pumpLogin(tester, LoginCubit(useCase));

      await tester.tap(submitButton());
      await tester.pump();

      expect(find.text(t.validators.required), findsNWidgets(2));
      verifyNever(() => useCase(any()));
    });

    testWidgets('should show the email format error for an invalid address', (
      tester,
    ) async {
      final useCase = MockLoginUseCase();
      await pumpLogin(tester, LoginCubit(useCase));

      await tester.enterText(emailField(), 'not-an-email');
      await tester.enterText(passwordField(), 'Orbit123!');
      await tester.tap(submitButton());
      await tester.pump();

      expect(find.text(t.validators.email), findsOneWidget);
      verifyNever(() => useCase(any()));
    });

    testWidgets('should submit the trimmed email and the password', (
      tester,
    ) async {
      final useCase = MockLoginUseCase();
      when(() => useCase(any()))
          .thenAnswer((_) async => const Success(tSession));
      await pumpLogin(tester, LoginCubit(useCase));

      await tester.enterText(emailField(), ' adam@orbit.app ');
      await tester.enterText(passwordField(), 'Orbit123!');
      await tester.tap(submitButton());
      await tester.pumpAndSettle();

      final params =
          verify(() => useCase(captureAny())).captured.single as LoginParams;
      expect(params.email, 'adam@orbit.app');
      expect(params.password, 'Orbit123!');
      expect(find.text('Home destination'), findsOneWidget);
    });

    testWidgets('should disable the submit button while a login is in flight', (
      tester,
    ) async {
      final useCase = MockLoginUseCase();
      final pending = Completer<ApiResult<AuthSession>>();
      when(() => useCase(any())).thenAnswer((_) => pending.future);
      await pumpLogin(tester, LoginCubit(useCase));

      await tester.enterText(emailField(), 'adam@orbit.app');
      await tester.enterText(passwordField(), 'Orbit123!');
      await tester.tap(submitButton());
      await tester.pump();

      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.isLoading, isTrue);
      expect(button.onPressed, isNull);

      await tester.tap(find.byType(AppButton));
      await tester.pump();
      verify(() => useCase(any())).called(1);

      pending.complete(const Success(tSession));
      await tester.pumpAndSettle();
    });

    testWidgets('should show the localized failure banner and stay on login', (
      tester,
    ) async {
      final useCase = MockLoginUseCase();
      when(() => useCase(any())).thenAnswer(
        (_) async =>
            const ResultFailure(InvalidCredentialsFailure(message: 'bad')),
      );
      await pumpLogin(tester, LoginCubit(useCase));

      await tester.enterText(emailField(), 'adam@orbit.app');
      await tester.enterText(passwordField(), 'wrong');
      await tester.tap(submitButton());
      await tester.pumpAndSettle();

      expect(find.text(t.auth.login.errorTitle), findsOneWidget);
      expect(find.text(t.errors.invalidCredentials), findsOneWidget);
      expect(find.text('Home destination'), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('should replace login with signup when the link is tapped', (
      tester,
    ) async {
      await pumpLogin(tester, LoginCubit(MockLoginUseCase()));

      await tester.tap(find.text(t.auth.login.createAccount));
      await tester.pumpAndSettle();

      expect(find.text('Signup destination'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });
  });
}
