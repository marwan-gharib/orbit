import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/confirm_dialog.dart';

import '../../domain/enums/interaction_type.dart' show InteractionType;
import '../constants/interaction_layout_constants.dart';
import '../pure/interaction_form_dirty.dart';
import '../pure/interaction_submit_params.dart';
import '../cubits/interaction_form/interaction_form_cubit.dart'
    show InteractionFormCubit;
import '../cubits/interaction_form/interaction_form_state.dart'
    show
        InteractionFormState,
        InteractionFormSubmitting,
        InteractionFormSuccess,
        InteractionFormSubmitError;
import 'interaction_sheet_fields.dart';
import 'interaction_text_fields.dart';
import 'interaction_submit_button.dart';
import '../view_models/interaction_tile_data.dart'
    show InteractionEditData, InteractionContactOption, SheetMode;

/// Bottom sheet for adding or editing an interaction.
/// Receives plain values only; owns its form cubit per invocation.
class InteractionAddEditSheet extends StatefulWidget {
  const InteractionAddEditSheet({
    super.key,
    required this.mode,
    required this.onSubmit,
    this.customerId,
    this.opportunityId,
    this.contacts,
    this.initialContactId,
    this.initialType,
    this.initialDate,
    this.contextLabel,
    this.editData,
  });

  final SheetMode mode;
  final void Function(dynamic)
  onSubmit; // AddInteractionParams | UpdateInteractionParams
  final int? customerId;
  final int? opportunityId;
  final List<InteractionContactOption>? contacts;
  final int? initialContactId;
  final InteractionType? initialType;
  final DateTime? initialDate;
  final String? contextLabel;
  final InteractionEditData? editData;

  @override
  State<InteractionAddEditSheet> createState() =>
      _InteractionAddEditSheetState();
}

class _InteractionAddEditSheetState extends State<InteractionAddEditSheet> {
  late final TextEditingController _subjectController;
  late final TextEditingController _descriptionController;
  late final FocusNode _subjectFocusNode;
  late final FocusNode _descriptionFocusNode;
  late InteractionType _selectedType;
  late DateTime _selectedDate;
  int? _selectedContactId;
  Failure? _failure;
  int _failureTrigger = 0;
  String? _subjectError;
  int _validationTrigger = 0;
  bool _succeeded = false;
  Timer? _closeTimer;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController();
    _descriptionController = TextEditingController();
    _subjectFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();

    if (widget.mode == SheetMode.add) {
      _selectedType = widget.initialType ?? InteractionType.call;
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedContactId = widget.initialContactId;
    } else {
      final data = widget.editData!;
      _selectedType = data.type;
      _selectedDate = data.date;
      _subjectController.text = data.subject;
      _descriptionController.text = data.description;
      _selectedContactId = null; // Contacts not editable in edit mode
    }
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _subjectController.dispose();
    _descriptionController.dispose();
    _subjectFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  bool get _isDirty {
    final edit = widget.editData;
    return isInteractionFormDirty(
      subject: _subjectController.text,
      description: _descriptionController.text,
      type: _selectedType,
      date: _selectedDate,
      contactId: _selectedContactId,
      baselineSubject: edit?.subject ?? '',
      baselineDescription: edit?.description ?? '',
      baselineType: edit?.type ?? widget.initialType ?? InteractionType.call,
      baselineDate: edit?.date ?? widget.initialDate ?? DateTime.now(),
      baselineContactId: edit == null ? widget.initialContactId : null,
    );
  }

  bool get _canSave => _isDirty;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<InteractionFormCubit, InteractionFormState>(
      listener: _onStateChanged,
      builder: (context, state) {
        final isSubmitting = state is InteractionFormSubmitting;
        final locked = isSubmitting || _succeeded;

        return PopScope(
          canPop: !_isDirty && !locked,
          onPopInvokedWithResult: (didPop, _) => _handlePop(didPop, locked),
          child: Padding(
            padding: EdgeInsetsDirectional.only(bottom: keyboardInset),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: AppSpacing.page,
                child: StaggeredColumn(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.mode == SheetMode.add
                          ? context.t.crm.editor.titleAdd
                          : context.t.crm.editor.titleEdit,
                      style: context.textStyles.headlineSmall,
                    ),
                    _gap,
                    InteractionTypeSelector(
                      selected: _selectedType,
                      onChanged: (type) => setState(() => _selectedType = type),
                    ),
                    _gap,
                    InteractionDateField(
                      date: _selectedDate,
                      onChanged: (date) => setState(() => _selectedDate = date),
                    ),
                    _gap,
                    InteractionSubjectField(
                      controller: _subjectController,
                      focusNode: _subjectFocusNode,
                      errorText: _subjectError,
                      validationTrigger: _validationTrigger,
                      onChanged: (_) => setState(() {
                        _failure = null;
                        _subjectError = null;
                      }),
                    ),
                    _gap,
                    InteractionDescriptionField(
                      controller: _descriptionController,
                      focusNode: _descriptionFocusNode,
                      onChanged: (_) => setState(() => _failure = null),
                    ),
                    if (widget.mode == SheetMode.add &&
                        (widget.contacts?.isNotEmpty ?? false)) ...[
                      _gap,
                      InteractionContactSelector(
                        contacts: widget.contacts!,
                        selectedId: _selectedContactId,
                        onChanged: (id) =>
                            setState(() => _selectedContactId = id),
                      ),
                    ],
                    if (widget.contextLabel != null) ...[
                      _gap,
                      InteractionContextLabel(text: widget.contextLabel!),
                    ],
                    if (_failure case final failure?)
                      Padding(
                        padding: EdgeInsetsDirectional.only(top: AppSpacing.sm),
                        child: Text(
                          context.failureText(failure),
                          style: context.textStyles.bodySmall.copyWith(
                            color: context.colors.error,
                          ),
                        ),
                      ),
                    SizedBox(height: AppSpacing.lg),
                    InteractionSheetActions(
                      isSubmitting: isSubmitting,
                      succeeded: _succeeded,
                      failureTrigger: _failureTrigger,
                      onCancel: _cancel,
                      onSubmit: _canSave ? _submit : null,
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

  Widget get _gap => SizedBox(height: InteractionLayoutConstants.sheetFieldGap);

  void _onStateChanged(BuildContext context, InteractionFormState state) {
    if (state is InteractionFormSuccess) {
      // Let the drawn check play, then close.
      setState(() => _succeeded = true);
      _closeTimer = Timer(AppDurations.slow, () {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }
    if (state is InteractionFormSubmitError) {
      setState(() {
        _failure = state.failure;
        _failureTrigger++;
      });
    }
  }

  void _submit() {
    if (!_canSave) return;
    if (_subjectController.text.trim().isEmpty) {
      setState(() {
        _subjectError = context.t.crm.editor.subjectRequired;
        _validationTrigger++;
      });
      return;
    }

    widget.onSubmit(
      buildInteractionSubmitParams(
        mode: widget.mode,
        type: _selectedType,
        subject: _subjectController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        customerId: widget.customerId,
        contactId: _selectedContactId,
        opportunityId: widget.opportunityId,
        editData: widget.editData,
      ),
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
      confirmLabel: strings.crmInteractions.deleteConfirm.title,
      cancelLabel: strings.common.cancel,
      destructive: true,
    );
    if (!discard || !mounted) return;
    Navigator.of(context).pop();
  }
}
