import 'package:flutter/material.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import '../../domain/enums/employment_status.dart';
import '../constants/auth_layout_constants.dart';
import '../mappers/employment_status_view.dart';

enum _StepState { completed, active, upcoming }

/// Three-step approval progress: submitted, in review, decision.
///
/// Purely presentational: completed, active and upcoming are derived from the
/// current status, so the stepper never disagrees with the badge. No motion is
/// needed here — the hero carries the only loop on the screen.
class PendingStepper extends StatelessWidget {
  const PendingStepper({required this.status, super.key});

  final EmploymentStatus status;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = context.colors;
    final review = status.isTerminal ? _StepState.completed : _StepState.active;
    final decision = status.isTerminal
        ? _StepState.completed
        : _StepState.upcoming;
    final decisionColor = switch (status) {
      EmploymentStatus.approved => colors.success,
      EmploymentStatus.rejected => colors.error,
      _ => colors.primary,
    };
    final decisionIcon = status == EmploymentStatus.rejected
        ? Icons.close_rounded
        : Icons.check_rounded;

    return Semantics(
      container: true,
      label: t.auth.pending.a11y.stepper,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _Step(
              label: t.auth.pending.stepper.submitted,
              state: _StepState.completed,
              color: colors.primary,
              iconColor: colors.onPrimary,
              icon: Icons.check_rounded,
            ),
          ),
          _Connector(completed: true),
          Expanded(
            child: _Step(
              label: t.auth.pending.stepper.review,
              state: review,
              color: colors.primary,
              iconColor: colors.onPrimary,
              icon: Icons.check_rounded,
            ),
          ),
          _Connector(completed: status.isTerminal),
          Expanded(
            child: _Step(
              label: t.auth.pending.stepper.decision,
              state: decision,
              color: decisionColor,
              iconColor: switch (status) {
                EmploymentStatus.rejected => colors.onError,
                _ => colors.onPrimary,
              },
              icon: decisionIcon,
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.state,
    required this.color,
    required this.iconColor,
    required this.icon,
  });

  final String label;
  final _StepState state;
  final Color color;
  final Color iconColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final isUpcoming = state == _StepState.upcoming;

    return Column(
      children: [
        Container(
          width: AuthLayout.stepperDotSize,
          height: AuthLayout.stepperDotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: switch (state) {
              _StepState.completed => color,
              _StepState.active => colors.surface,
              _StepState.upcoming => colors.surface,
            },
            border: Border.all(
              color: isUpcoming ? colors.border : color,
              width: AuthLayout.stepperLineThickness,
            ),
          ),
          child: switch (state) {
            _StepState.completed => Icon(
              icon,
              size: AuthLayout.stepperIconSize,
              color: iconColor,
            ),
            _StepState.active => Center(
              child: Container(
                width: AuthLayout.stepperActiveMarkerSize,
                height: AuthLayout.stepperActiveMarkerSize,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
            ),
            _StepState.upcoming => null,
          },
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: textStyles.bodySmall.copyWith(
            color: isUpcoming ? colors.textSecondary : colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: AppSpacing.lg,
      height: AuthLayout.stepperDotSize,
      child: Center(
        child: Container(
          height: AuthLayout.stepperLineThickness,
          color: completed ? colors.primary : colors.border,
        ),
      ),
    );
  }
}
