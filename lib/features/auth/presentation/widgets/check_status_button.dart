import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_button.dart';

import '../cubits/employee_status/employee_status_cubit.dart';
import '../cubits/employee_status/employee_status_state.dart';

/// "Check status" action with its own in-memory cooldown.
///
/// The cooldown starts when a check *completes* (success or failure, D8) and
/// lasts `AppConsts.pendingCheckCooldown`; it lives in this widget's State, so
/// it resets with the screen instance and never persists. The cubit's loading
/// guard is the final defence against a double submission.
///
/// Motion: [AnimatedVisibility] for the cooldown hint (core default: 300 ms,
/// `AppCurves.standard`), restored instantly under reduced motion.
class CheckStatusButton extends StatefulWidget {
  const CheckStatusButton({super.key});

  @override
  State<CheckStatusButton> createState() => _CheckStatusButtonState();
}

class _CheckStatusButtonState extends State<CheckStatusButton> {
  Timer? _cooldown;
  bool _coolingDown = false;

  @override
  void dispose() {
    _cooldown?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldown?.cancel();
    setState(() => _coolingDown = true);
    _cooldown = Timer(AppConsts.pendingCheckCooldown, () {
      if (!mounted) return;
      setState(() => _coolingDown = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = context.colors;
    final textStyles = context.textStyles;

    return BlocListener<EmployeeStatusCubit, EmployeeStatusState>(
      listenWhen: (previous, current) =>
          current is EmployeeStatusSuccess || current is EmployeeStatusError,
      listener: (context, state) {
        _startCooldown();
      },
      child: BlocSelector<EmployeeStatusCubit, EmployeeStatusState, bool>(
        selector: (state) => state is EmployeeStatusLoading,
        builder: (context, isLoading) {
          final enabled = !isLoading && !_coolingDown;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton.filled(
                label: t.auth.pending.checkStatus,
                semanticLabel: t.auth.pending.a11y.checkStatus,
                isLoading: isLoading,
                onPressed: enabled
                    ? () => context.read<EmployeeStatusCubit>().check()
                    : null,
              ),
              AnimatedVisibility(
                visible: _coolingDown && !isLoading,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(top: AppSpacing.sm),
                  child: Text(
                    t.auth.pending.cooldown,
                    textAlign: TextAlign.center,
                    style: textStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
