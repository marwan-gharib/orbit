import 'package:flutter/material.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/widgets/app_button.dart';

/// Where the sheet's submit button is in its life.
enum InteractionSubmitStatus { idle, loading, success }

/// Save button that morphs idle → loading → success (drawn check). A failure
/// is signalled by shaking it (the sheet bumps [failureTrigger]) while it
/// returns to idle, so the user can retry without losing any input.
class InteractionSubmitButton extends StatelessWidget {
  const InteractionSubmitButton({
    super.key,
    required this.status,
    required this.failureTrigger,
    required this.onPressed,
  });

  final InteractionSubmitStatus status;
  final int failureTrigger;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final common = context.t.crm.common;
    final isSuccess = status == InteractionSubmitStatus.success;

    return ShakeWidget(
      trigger: failureTrigger,
      haptic: true,
      child: AppButton(
        label: isSuccess ? common.saved : common.save,
        isLoading: status == InteractionSubmitStatus.loading,
        icon: isSuccess
            ? DrawnCheck(color: context.colors.onPrimary, burst: false)
            : null,
        onPressed: status == InteractionSubmitStatus.idle ? onPressed : null,
      ),
    );
  }
}

/// Cancel + morphing save, right-aligned at the bottom of the sheet.
class InteractionSheetActions extends StatelessWidget {
  const InteractionSheetActions({
    super.key,
    required this.isSubmitting,
    required this.succeeded,
    required this.failureTrigger,
    required this.onCancel,
    required this.onSubmit,
  });

  final bool isSubmitting;
  final bool succeeded;
  final int failureTrigger;
  final VoidCallback onCancel;

  /// Null disables save (nothing to save yet).
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppButton.text(
          label: context.t.crm.common.cancel,
          onPressed: (isSubmitting || succeeded) ? null : onCancel,
        ),
        SizedBox(width: AppSpacing.sm),
        InteractionSubmitButton(
          status: succeeded
              ? InteractionSubmitStatus.success
              : isSubmitting
              ? InteractionSubmitStatus.loading
              : InteractionSubmitStatus.idle,
          failureTrigger: failureTrigger,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}
