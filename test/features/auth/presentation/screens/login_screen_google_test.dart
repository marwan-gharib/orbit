import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/exceptions.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/router/route_names.dart';
import 'package:orbit/core/router/route_paths.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/features/auth/domain/entities/auth_session_entity.dart';
import 'package:orbit/features/auth/domain/entities/signup_result_entity.dart';
import 'package:orbit/features/auth/domain/entities/user_entity.dart';
import 'package:orbit/features/auth/domain/enums/user_role.dart';
import 'package:orbit/features/auth/domain/usecases/login_usecase.dart';
import 'package:orbit/features/auth/presentation/cubits/google_sign_in/google_sign_in_cubit.dart';
import 'package:orbit/features/auth/presentation/cubits/google_sign_in/google_sign_in_state.dart';
import 'package:orbit/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:orbit/features/auth/presentation/screens/login_screen.dart';
import 'package:orbit/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:orbit/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:orbit/features/auth/presentation/widgets/login_or_divider.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockGoogleSignInCubit extends MockCubit<GoogleSignInState>
    implements GoogleSignInCubit {}

const tUser = User(
  firstName: 'Adam',
  lastName: 'Orbit',
  code: 'EMP-2026-9582',
  email: 'adam@orbit.app',
  role: UserRole.admin,
  roleName: 'Admin',
  permissions: [],
);

const tSession = AuthSession(
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  user: tUser,
);

void main() {
  late MockGoogleSignInCubit mockGoogleCubit;
  late LoginCubit loginCubit;

  setUp(() {
    mockGoogleCubit = MockGoogleSignInCubit();
    loginCubit = LoginCubit(MockLoginUseCase());
  });

  tearDown(() {
    loginCubit.close();
    mockGoogleCubit.close();
  });

  Future<void> pumpLogin(
    WidgetTester tester, {
    GoogleSignInState initialState = const GoogleSignInIdle(),
    Stream<GoogleSignInState>? stateStream,
  }) async {
    when(() => mockGoogleCubit.state).thenReturn(initialState);
    when(() => mockGoogleCubit.stream).thenAnswer(
      (_) => stateStream ?? const Stream<GoogleSignInState>.empty(),
    );

    final router = GoRouter(
      initialLocation: RoutePaths.login,
      routes: [
        GoRoute(
          path: RoutePaths.login,
          name: RouteNames.login,
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider<LoginCubit>.value(value: loginCubit),
              BlocProvider<GoogleSignInCubit>.value(value: mockGoogleCubit),
            ],
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: RoutePaths.home,
          name: RouteNames.home,
          builder: (_, _) => const Scaffold(body: Text('Home destination')),
        ),
        GoRoute(
          path: RoutePaths.pending,
          name: RouteNames.pending,
          builder: (_, _) => const Scaffold(body: Text('Pending destination')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));
  }

  group('LoginScreen Google SSO', () {
    testWidgets('should render LoginOrDivider and GoogleSignInButton', (
      tester,
    ) async {
      await pumpLogin(tester);

      expect(find.byType(LoginOrDivider), findsOneWidget);
      expect(find.text(t.auth.login.orDivider), findsOneWidget);
      expect(find.byType(GoogleSignInButton), findsOneWidget);
      expect(find.text(t.auth.login.googleSignIn), findsOneWidget);
    });

    testWidgets('should call signInWithGoogle when Google button is tapped', (
      tester,
    ) async {
      when(() => mockGoogleCubit.signInWithGoogle()).thenAnswer((_) async {});
      await pumpLogin(tester);

      await tester.tap(find.byType(GoogleSignInButton));
      await tester.pump();

      verify(() => mockGoogleCubit.signInWithGoogle()).called(1);
    });

    testWidgets(
      'should disable submit and Google buttons when Google is loading',
      (tester) async {
        await pumpLogin(
          tester,
          initialState: const GoogleSignInLoading(),
        );

        final submitBtn =
            tester.widget<AppButton>(find.byType(AppButton).first);
        expect(submitBtn.onPressed, isNull);

        final googleBtn =
            tester.widget<GoogleSignInButton>(find.byType(GoogleSignInButton));
        expect(googleBtn.isLoading, isTrue);
        expect(googleBtn.onPressed, isNull);
      },
    );

    testWidgets('should navigate to home on GoogleSignInAuthenticated', (
      tester,
    ) async {
      final controller = StreamController<GoogleSignInState>.broadcast();
      addTearDown(controller.close);

      await pumpLogin(tester, stateStream: controller.stream);

      controller.add(const GoogleSignInAuthenticated(tSession));
      await tester.pumpAndSettle();

      expect(find.text('Home destination'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('should navigate to pending on GoogleSignInPending', (
      tester,
    ) async {
      final controller = StreamController<GoogleSignInState>.broadcast();
      addTearDown(controller.close);

      await pumpLogin(tester, stateStream: controller.stream);

      controller.add(
        const GoogleSignInPending(
          SignupResult(
            firstName: 'New',
            lastName: 'User',
            email: 'newbie@orbit.app',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pending destination'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('should display error banner on GoogleSignInError', (
      tester,
    ) async {
      final controller = StreamController<GoogleSignInState>.broadcast();
      addTearDown(controller.close);

      await pumpLogin(tester, stateStream: controller.stream);

      controller.add(
        const GoogleSignInError(
          NetworkFailure(
            message: 'No connection',
            reason: NetworkErrorReason.noInternet,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AuthErrorBanner), findsOneWidget);
      expect(find.text(t.auth.login.errorTitle), findsOneWidget);
      expect(find.text(t.errors.offline), findsOneWidget);
    });
  });
}
