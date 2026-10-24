import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/router/route_names.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/utils/validators.dart';
import 'package:orbit/core/widgets/widgets.dart';

import '../cubits/google_sign_in/google_sign_in_cubit.dart';
import '../cubits/google_sign_in/google_sign_in_state.dart';
import '../cubits/login/login_cubit.dart';
import '../cubits/login/login_state.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_navigation_link.dart';
import '../widgets/auth_page_scaffold.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/login_or_divider.dart';

/// Sign-in screen. Field values live in controllers, submission lives in
/// [LoginCubit] and [GoogleSignInCubit]; this widget owns no business state
/// and never calls the repository (STATE-1, STATE-6).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _shake = ShakeController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) return;
    context.read<LoginCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  String? _validateEmail(String? value) {
    final t = context.t;
    final missing = Validators.required(message: t.validators.required)(value);
    if (missing != null) return missing;
    return Validators.email(message: t.validators.email)(value);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) =>
          current is LoginSuccess || current is LoginError,
      listener: (context, state) {
        switch (state) {
          case LoginSuccess():
            context.goNamed(RouteNames.home);
          case LoginError():
            _shake.shake();
            AppHaptics.error();
          default:
            break;
        }
      },
      child: BlocListener<GoogleSignInCubit, GoogleSignInState>(
        listenWhen: (previous, current) =>
            current is GoogleSignInAuthenticated ||
            current is GoogleSignInPending ||
            current is GoogleSignInError,
        listener: (context, state) {
          switch (state) {
            case GoogleSignInAuthenticated():
              context.goNamed(RouteNames.home);
            case GoogleSignInPending():
              context.goNamed(RouteNames.pending);
            case GoogleSignInError():
              _shake.shake();
              AppHaptics.error();
            default:
              break;
          }
        },
        child: AuthPageScaffold(
          footer: AuthNavigationLink(
            prompt: t.auth.login.noAccount,
            action: t.auth.login.createAccount,
            onTap: () => context.goNamed(RouteNames.signup),
          ),
          children: [
            AuthBrandHeader(
              title: t.auth.login.title,
              subtitle: t.auth.login.subtitle,
            ),
            SizedBox(height: AppSpacing.xl),
            BlocBuilder<LoginCubit, LoginState>(
              buildWhen: (p, c) => (p is LoginError) != (c is LoginError),
              builder: (context, loginState) =>
                  BlocBuilder<GoogleSignInCubit, GoogleSignInState>(
                buildWhen: (p, c) =>
                    (p is GoogleSignInError) != (c is GoogleSignInError),
                builder: (context, googleState) {
                  final failure = switch (googleState) {
                    GoogleSignInError(:final failure) => failure,
                    _ => null,
                  } ?? switch (loginState) {
                    LoginError(:final failure) => failure,
                    _ => null,
                  };
                  if (failure == null) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsetsDirectional.only(bottom: AppSpacing.lg),
                    child: FadeIn(
                      child: AuthErrorBanner(
                        title: t.auth.login.errorTitle,
                        message: context.failureText(failure),
                      ),
                    ),
                  );
                },
              ),
            ),
            ShakeWidget(
              controller: _shake,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      controller: _emailController,
                      label: t.auth.login.emailLabel,
                      hint: t.auth.login.emailHint,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: _validateEmail,
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      label: t.auth.login.passwordLabel,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      validator: (value) => Validators.required(
                        message: t.validators.required,
                      )(value),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            BlocBuilder<LoginCubit, LoginState>(
              buildWhen: (p, c) => (p is LoginLoading) != (c is LoginLoading),
              builder: (context, loginState) =>
                  BlocBuilder<GoogleSignInCubit, GoogleSignInState>(
                buildWhen: (p, c) =>
                    (p is GoogleSignInLoading) != (c is GoogleSignInLoading),
                builder: (context, googleState) {
                  final isLoginLoading = loginState is LoginLoading;
                  final isGoogleLoading = googleState is GoogleSignInLoading;
                  final isBusy = isLoginLoading || isGoogleLoading;
                  return AppButton.filled(
                    label: t.auth.login.submit,
                    semanticLabel: t.auth.login.a11y.submit,
                    isLoading: isLoginLoading,
                    onPressed: isBusy ? null : _submit,
                  );
                },
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            const LoginOrDivider(),
            SizedBox(height: AppSpacing.lg),
            BlocBuilder<LoginCubit, LoginState>(
              buildWhen: (p, c) => (p is LoginLoading) != (c is LoginLoading),
              builder: (context, loginState) =>
                  BlocSelector<GoogleSignInCubit, GoogleSignInState, bool>(
                selector: (state) => state is GoogleSignInLoading,
                builder: (context, isGoogleLoading) {
                  final isBusy =
                      (loginState is LoginLoading) || isGoogleLoading;
                  return GoogleSignInButton(
                    isLoading: isGoogleLoading,
                    onPressed: isBusy
                        ? null
                        : () => context
                            .read<GoogleSignInCubit>()
                            .signInWithGoogle(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
