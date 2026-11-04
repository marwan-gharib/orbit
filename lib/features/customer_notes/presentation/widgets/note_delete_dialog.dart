import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/core/widgets/app_dialog.dart';

import '../cubits/customer_note_delete/customer_note_delete_cubit.dart';
import '../cubits/customer_note_delete/customer_note_delete_state.dart';

/// Confirmation for deleting one note; the confirm action runs in the button
/// itself and the dialog closes only after the delete succeeds.
class NoteDeleteDialog extends StatelessWidget {
  const NoteDeleteDialog({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final strings = context.t.crm;

    return BlocConsumer<CustomerNoteDeleteCubit, CustomerNoteDeleteState>(
      listener: (context, state) {
        if (state is CustomerNoteDeleteSuccess && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final isDeleting = state is CustomerNoteDeleteInProgress;
        final failure = state is CustomerNoteDeleteFailure
            ? state.failure
            : null;

        return PopScope(
          canPop: !isDeleting,
          child: AppDialog(
            title: Text(strings.crmNotes.deleteConfirm.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.crmNotes.deleteConfirm.body),
                if (failure != null) ...[
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    context.failureText(failure),
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              AppButton.text(
                label: strings.common.cancel,
                onPressed: isDeleting
                    ? null
                    : () => Navigator.of(context).pop(),
              ),
              AppButton(
                label: strings.common.delete,
                destructive: true,
                isLoading: isDeleting,
                onPressed: isDeleting ? null : onConfirm,
              ),
            ],
          ),
        );
      },
    );
  }
}
