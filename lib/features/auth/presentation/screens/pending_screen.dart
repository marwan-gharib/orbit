import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/router/pending_signup_session.dart';
import 'package:orbit/core/router/route_names.dart';
import 'package:orbit/core/theme/app_spacing.dart';

import '../../domain/entities/employee_status_info_entity.dart';
import '../../domain/enums/employment_status.dart';
import '../cubits/employee_status/employee_status_cubit.dart';
import '../cubits/employee_status/employee_status_state.dart';
import '../mappers/employment_status_view.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_page_scaffold.dart';
import '../widgets/check_status_button.dart';
import '../widgets/pending_hero.dart';
import '../widgets/pending_info_notice.dart';
import '../widgets/pending_moment.dart';
import '../widgets/pending_status_card.dart';

/// Waiting-for-approval screen for the account created by signup.
///
/// There is no automatic check on entry (D6): the screen shows the persisted
/// work email with "Last checked: never" until the person taps Check status.
/// A check that returns approved or rejected shows a terminal moment for
/// `AppConsts.pendingMomentHold`, then clears the in-memory pending session and
/// replaces the route (approved -> login, rejected -> signup). With no pending
/// session the router guard cannot enter this screen, and `PopScope` keeps a
/// system back gesture from leaving an approval flow that is still pending.
class PendingScreen extends StatefulWidget {
  const PendingScreen({required this.session, super.key});

  /// In-memory mirror of the persisted pending signup; source of the email.
  final PendingSignupSession session;

  @override
  State<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
  final _lastCheckedAt = ValueNotifier<DateTime?>(null);
  final _terminalStatus = ValueNotifier<EmploymentStatus?>(null);
  Timer? _exitTimer;

  @override
  void dispose() {
    _exitTimer?.cancel();
    _lastCheckedAt.dispose();
    _terminalStatus.dispose();
    super.dispose();
  }

  void _handleState(EmployeeStatusState state) {
    _lastCheckedAt.value = DateTime.now();
    if (state is EmployeeStatusError) {
      AppHaptics.error();
      return;
    }
    if (state case EmployeeStatusSuccess(:final info)) {
      if (!info.status.isTerminal) return;
      _terminalStatus.value = info.status;
      if (info.status == EmploymentStatus.approved) {
        AppHaptics.medium();
      } else {
        AppHaptics.error();
      }
      _exitTimer?.cancel();
      _exitTimer = Timer(
        AppConsts.pendingMomentHold,
        () => _leave(info.status),
      );
    }
  }

  void _leave(EmploymentStatus status) {
    if (!mounted) return;
    // Cache was already cleared by the repository on a terminal decision; this
    // only ends the in-memory flow so the guard allows the next route.
    widget.session.clear();
    context.goNamed(
      status == EmploymentStatus.approved
          ? RouteNames.login
          : RouteNames.signup,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final email = widget.session.email ?? '';

    return BlocListener<EmployeeStatusCubit, EmployeeStatusState>(
      listenWhen: (previous, current) =>
          current is EmployeeStatusSuccess || current is EmployeeStatusError,
      listener: (context, state) => _handleState(state),
      child: PopScope(
        canPop: false,
        child: AuthPageScaffold(
          children: [
            AuthBrandHeader(
              title: t.auth.pending.title,
              subtitle: t.auth.pending.subtitle,
            ),
            SizedBox(height: AppSpacing.lg),
            BlocSelector<
              EmployeeStatusCubit,
              EmployeeStatusState,
              EmployeeStatusInfo?
            >(
              selector: (state) => switch (state) {
                EmployeeStatusSuccess(:final info) => info,
                _ => null,
              },
              builder: (context, info) {
                final status = info?.status ?? EmploymentStatus.pending;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: PendingHero(status: status)),
                    SizedBox(height: AppSpacing.lg),
                    ValueListenableBuilder<EmploymentStatus?>(
                      valueListenable: _terminalStatus,
                      builder: (context, terminal, _) {
                        if (terminal != null) {
                          return PendingMoment(status: terminal);
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ValueListenableBuilder<DateTime?>(
                              valueListenable: _lastCheckedAt,
                              builder: (context, lastChecked, _) =>
                                  PendingStatusCard(
                                    email: email,
                                    status: status,
                                    firstName: info?.firstName,
                                    lastCheckedAt: lastChecked,
                                    registeredWithGoogle:
                                        widget.session.registeredWithGoogle,
                                  ),
                            ),
                            SizedBox(height: AppSpacing.lg),
                            const CheckStatusButton(),
                            BlocSelector<
                              EmployeeStatusCubit,
                              EmployeeStatusState,
                              Failure?
                            >(
                              selector: (state) => switch (state) {
                                EmployeeStatusError(:final failure) => failure,
                                _ => null,
                              },
                              builder: (context, failure) {
                                if (failure == null) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    top: AppSpacing.md,
                                  ),
                                  child: FadeIn(
                                    child: AuthErrorBanner(
                                      title: t.auth.pending.errorTitle,
                                      message: context.failureText(failure),
                                    ),
                                  ),
                                );
                              },
                            ),
                            BlocSelector<
                              EmployeeStatusCubit,
                              EmployeeStatusState,
                              bool
                            >(
                              selector: (state) =>
                                  state is EmployeeStatusSuccess &&
                                  state.info.status == EmploymentStatus.pending,
                              builder: (context, unchanged) {
                                if (!unchanged) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    top: AppSpacing.md,
                                  ),
                                  child: FadeIn(
                                    child: PendingInfoNotice(
                                      message: t.auth.pending.unchanged,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
