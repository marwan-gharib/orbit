import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/core/widgets/app_text_field.dart';
import 'package:orbit/core/widgets/confirm_dialog.dart';

import '../constants/note_layout_constants.dart';
import '../cubits/customer_note_form/customer_note_form_cubit.dart';
import '../cubits/customer_note_form/customer_note_form_state.dart';
import '../../domain/params/update_customer_note_params.dart';

/// Bottom-sheet editor for one note. Receives plain values only; the form
/// cubit owns the entity that supplies the customer id on submit.
class NoteEditSheet extends StatefulWidget {
  const NoteEditSheet({
    super.key,
    required this.noteId,
    required this.initialText,
  });

  final int noteId;
  final String initialText;

  @override
  State<NoteEditSheet> createState() => _NoteEditSheetState();
}

class _NoteEditSheetState extends State<NoteEditSheet> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Failure? _failure;
  int _failureTrigger = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isDirty => _controller.text.trim() != widget.initialText.trim();

  bool get _canSave => _isDirty && _controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final labels = context.t.crm.crmNotes;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<CustomerNoteFormCubit, CustomerNoteFormState>(
      listener: _onStateChanged,
      builder: (context, state) {
        final isSubmitting = state is CustomerNoteFormSubmitting;

        return PopScope(
          canPop: !_isDirty && !isSubmitting,
          onPopInvokedWithResult: (didPop, _) =>
              _handlePop(didPop, isSubmitting),
          child: Padding(
            padding: EdgeInsetsDirectional.only(bottom: keyboardInset),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: AppSpacing.page,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(labels.edit, style: context.textStyles.headlineSmall),
                    SizedBox(height: AppSpacing.md),
                    ShakeWidget(
                      trigger: _failureTrigger,
                      haptic: true,
                      child: AppTextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        label: labels.composerLabel,
                        hint: labels.composerHint,
                        minLines: NoteLayoutConstants.composerMinLines,
                        maxLines: NoteLayoutConstants.composerMaxLines,
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) => setState(() => _failure = null),
                      ),
                    ),
                    if (_failure case final failure?) ...[
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        context.failureText(failure),
                        style: context.textStyles.bodySmall.copyWith(
                          color: context.colors.error,
                        ),
                      ),
                    ],
                    SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppButton.text(
                          label: context.t.crm.common.cancel,
                          onPressed: isSubmitting ? null : _cancel,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        AppButton(
                          label: context.t.crm.common.save,
                          isLoading: isSubmitting,
                          onPressed: _canSave && !isSubmitting ? _submit : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onStateChanged(BuildContext context, CustomerNoteFormState state) {
    if (state is CustomerNoteFormSuccess) {
      if (context.mounted) Navigator.of(context).pop();
      return;
    }
    if (state is CustomerNoteFormSubmitError) {
      setState(() {
        _failure = state.failure;
        _failureTrigger++;
      });
    }
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<CustomerNoteFormCubit>().submitUpdate(
      UpdateCustomerNoteParams(noteId: widget.noteId, noteText: text),
    );
  }

  void _cancel() {
    if (_isDirty) {
      _confirmDiscard();
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _handlePop(bool didPop, bool isSubmitting) async {
    if (didPop || isSubmitting) return;
    await _confirmDiscard();
  }

  Future<void> _confirmDiscard() async {
    final strings = context.t.crm;
    final discard = await ConfirmDialog.show(
      context: context,
      title: strings.editor.discardTitle,
      message: strings.editor.discardBody,
      confirmLabel: strings.crmNotes.discard,
      cancelLabel: strings.common.cancel,
      destructive: true,
    );
    if (!discard || !mounted) return;
    Navigator.of(context).pop();
  }
}
