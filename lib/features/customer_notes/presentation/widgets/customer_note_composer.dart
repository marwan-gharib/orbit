import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orbit/core/di/injection_container.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_text_field.dart';

import '../../domain/params/add_customer_note_params.dart';
import '../constants/note_layout_constants.dart';
import '../cubits/customer_note_form/customer_note_form_cubit.dart';
import '../cubits/customer_note_form/customer_note_form_state.dart';
import 'note_send_button.dart';

/// Bottom bar for adding a note to [customerId].
///
/// Owns a persistent form cubit, keeps the typed text across failures and
/// clears it only after a successful send; the bar sits above the keyboard and
/// the bottom safe area and never wraps itself in a Scaffold.
class CustomerNoteComposer extends StatelessWidget {
  const CustomerNoteComposer({super.key, required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<CustomerNoteFormCubit>()..startAdd(),
    child: _ComposerBar(customerId: customerId),
  );
}

class _ComposerBar extends StatefulWidget {
  const _ComposerBar({required this.customerId});

  final int customerId;

  @override
  State<_ComposerBar> createState() => _ComposerBarState();
}

class _ComposerBarState extends State<_ComposerBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Failure? _failure;
  bool _justSent = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = context.t.crm.crmNotes;
    final colors = context.colors;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return BlocConsumer<CustomerNoteFormCubit, CustomerNoteFormState>(
      listener: _onStateChanged,
      builder: (context, state) {
        final isSending = state is CustomerNoteFormSubmitting;
        final hasText = _controller.text.trim().isNotEmpty;
        final status = _status(isSending: isSending);

        return Padding(
          padding: EdgeInsetsDirectional.only(
            bottom: keyboardInset + safeBottom,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_failure case final failure?) ...[
                    _ComposerError(text: context.failureText(failure)),
                    SizedBox(height: AppSpacing.xs),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          label: labels.composerLabel,
                          hint: labels.composerHint,
                          minLines: NoteLayoutConstants.composerMinLines,
                          maxLines: NoteLayoutConstants.composerMaxLines,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (_) => _onTextChanged(),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      NoteSendButton(
                        status: status,
                        onPressed: hasText && !isSending ? _send : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  NoteSendStatus _status({required bool isSending}) {
    if (isSending) return NoteSendStatus.sending;
    if (_failure != null) return NoteSendStatus.failed;
    if (_justSent) return NoteSendStatus.sent;
    return NoteSendStatus.idle;
  }

  void _onTextChanged() {
    if (!_justSent && _failure == null) {
      setState(() {});
      return;
    }
    setState(() {
      _justSent = false;
      _failure = null;
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _failure = null);
    _focusNode.requestFocus();
    context.read<CustomerNoteFormCubit>().submitNew(
      AddCustomerNoteParams(customerId: widget.customerId, noteText: text),
    );
  }

  void _onStateChanged(BuildContext context, CustomerNoteFormState state) {
    if (state is CustomerNoteFormSuccess) {
      _controller.clear();
      setState(() {
        _justSent = true;
        _failure = null;
      });
      context.read<CustomerNoteFormCubit>().startAdd();
      _focusNode.requestFocus();
      return;
    }
    if (state is CustomerNoteFormSubmitError) {
      setState(() {
        _failure = state.failure;
        _justSent = false;
      });
    }
  }
}

class _ComposerError extends StatelessWidget {
  const _ComposerError({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Text(
      text,
      style: context.textStyles.bodySmall.copyWith(color: context.colors.error),
    ),
  );
}
