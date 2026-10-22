import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/router/route_names.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/utils/validators.dart';
import 'package:orbit/core/widgets/widgets.dart';

import '../cubits/signup/signup_cubit.dart';
import '../cubits/signup/signup_state.dart';
import '../mappers/signup_field_errors_mapper.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_navigation_link.dart';
import '../widgets/auth_page_scaffold.dart';
import '../widgets/password_checklist.dart';
import '../widgets/password_rules.dart';
import '../widgets/password_strength_bar.dart';

/// Account creation screen. It owns only controllers, focus and the server
/// field-error notifier; every request goes through [SignupCubit] and every
/// side effect runs in the single [BlocListener] (STATE-1, STATE-6).
///
/// The live checklist and strength meter listen to the password controller
/// directly, so typing never rebuilds the screen: only that subtree updates.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(text: "sacs");
  final _lastNameController = TextEditingController(text: "asedcaedcesc");
  final _emailController = TextEditingController(text: "cursorone39@gmail.com");
  final _passwordController = TextEditingController(text: "Marwan@12");
  final _confirmPasswordController = TextEditingController(text: "Marwan@12");

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  final _shake = ShakeController();
  final _serverErrors = ValueNotifier<Map<String, String>>(const {});

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _serverErrors.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    _serverErrors.value = const {};
    if (_formKey.currentState?.validate() != true) return;
    context.read<SignupCubit>().signup(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      workEmail: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _clearServerError(String key) {
    if (!_serverErrors.value.containsKey(key)) return;
    final next = Map<String, String>.of(_serverErrors.value)..remove(key);
    _serverErrors.value = next;
  }

  void _applyServerErrors(Failure failure) {
    _serverErrors.value = mappedSignupFieldErrors(failure);
  }

  String? _validateName(String? value) {
    final t = context.t;
    final missing = Validators.required(message: t.validators.required)(value);
    if (missing != null) return missing;
    return Validators.lettersOnly(message: t.validators.name)(value);
  }

  String? _validateEmail(String? value) {
    final t = context.t;
    final missing = Validators.required(message: t.validators.required)(value);
    if (missing != null) return missing;
    return Validators.email(message: t.validators.email)(value);
  }

  String? _validatePassword(String? value) {
    final t = context.t;
    final missing = Validators.required(message: t.validators.required)(value);
    if (missing != null) return missing;
    return firstViolatedPasswordRule(value!)?.errorText(context);
  }

  String? _validateConfirmPassword(String? value) {
    final t = context.t;
    final missing = Validators.required(message: t.validators.required)(value);
    if (missing != null) return missing;
    return Validators.matches(
      original: () => _passwordController.text,
      message: t.validators.passwordMismatch,
    )(value);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return BlocListener<SignupCubit, SignupState>(
      listenWhen: (previous, current) =>
          current is SignupSuccess || current is SignupError,
      listener: (context, state) {
        switch (state) {
          case SignupSuccess():
            context.goNamed(RouteNames.pending);
          case SignupError(:final failure):
            _applyServerErrors(failure);
            _shake.shake();
            AppHaptics.error();
          default:
            break;
        }
      },
      child: AuthPageScaffold(
        footer: AuthNavigationLink(
          prompt: t.auth.signup.haveAccount,
          action: t.auth.signup.signIn,
          onTap: () => context.goNamed(RouteNames.login),
        ),
        children: [
          AuthBrandHeader(
            title: t.auth.signup.title,
            subtitle: t.auth.signup.subtitle,
          ),
          SizedBox(height: AppSpacing.xl),
          BlocSelector<SignupCubit, SignupState, Failure?>(
            selector: (state) => switch (state) {
              SignupError(:final failure) => failure,
              _ => null,
            },
            builder: (context, failure) {
              if (failure == null || !signupFailureHasUnmappedErrors(failure)) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsetsDirectional.only(bottom: AppSpacing.lg),
                child: FadeIn(
                  child: AuthErrorBanner(
                    title: t.auth.signup.errorTitle,
                    message: context.failureText(failure),
                  ),
                ),
              );
            },
          ),
          ShakeWidget(
            controller: _shake,
            child: ValueListenableBuilder<Map<String, String>>(
              valueListenable: _serverErrors,
              builder: (context, serverErrors, _) => Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _firstNameController,
                            focusNode: _firstNameFocus,
                            label: t.auth.signup.firstNameLabel,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.givenName],
                            errorText: serverErrors[ApiKeys.firstNameKey],
                            validator: _validateName,
                            onChanged: (_) =>
                                _clearServerError(ApiKeys.firstNameKey),
                            onFieldSubmitted: (_) =>
                                _lastNameFocus.requestFocus(),
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppTextField(
                            controller: _lastNameController,
                            focusNode: _lastNameFocus,
                            label: t.auth.signup.lastNameLabel,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.familyName],
                            errorText: serverErrors[ApiKeys.lastNameKey],
                            validator: _validateName,
                            onChanged: (_) =>
                                _clearServerError(ApiKeys.lastNameKey),
                            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      label: t.auth.signup.workEmailLabel,
                      hint: t.auth.signup.workEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      errorText: serverErrors[ApiKeys.workEmailKey],
                      validator: _validateEmail,
                      onChanged: (_) => _clearServerError(ApiKeys.workEmailKey),
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      label: t.auth.signup.passwordLabel,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      errorText: serverErrors[ApiKeys.passwordKey],
                      validator: _validatePassword,
                      onChanged: (_) => _clearServerError(ApiKeys.passwordKey),
                      onFieldSubmitted: (_) =>
                          _confirmPasswordFocus.requestFocus(),
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _passwordController,
                      builder: (context, value, _) => AnimatedVisibility(
                        visible: value.text.isNotEmpty,
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                            top: AppSpacing.sm,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PasswordChecklist(password: value.text),
                              SizedBox(height: AppSpacing.xs),
                              PasswordStrengthBar(password: value.text),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocus,
                      label: t.auth.signup.confirmPasswordLabel,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: _validateConfirmPassword,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          BlocSelector<SignupCubit, SignupState, bool>(
            selector: (state) => state is SignupLoading,
            builder: (context, isLoading) => AppButton.filled(
              label: t.auth.signup.submit,
              semanticLabel: t.auth.signup.a11y.submit,
              isLoading: isLoading,
              onPressed: isLoading ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}
