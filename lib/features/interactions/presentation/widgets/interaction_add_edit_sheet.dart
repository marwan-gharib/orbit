import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/utils/formatters.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/core/widgets/app_text_field.dart' show AppTextField;
import 'package:orbit/core/widgets/confirm_dialog.dart';

import '../../domain/enums/interaction_type.dart' show InteractionType;
import '../../domain/params/add_interaction_params.dart'
    show AddInteractionParams;
import '../../domain/params/update_interaction_params.dart'
    show UpdateInteractionParams;
import '../constants/interaction_layout_constants.dart';
import '../cubits/interaction_form/interaction_form_cubit.dart'
    show InteractionFormCubit;
import '../cubits/interaction_form/interaction_form_state.dart'
    show
        InteractionFormState,
        InteractionFormSubmitting,
        InteractionFormSuccess,
        InteractionFormSubmitError;
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
    _subjectController.dispose();
    _descriptionController.dispose();
    _subjectFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  bool get _isDirty {
    if (widget.mode == SheetMode.add) {
      return _subjectController.text.trim().isNotEmpty ||
          _descriptionController.text.trim().isNotEmpty ||
          _selectedContactId != widget.initialContactId ||
          _selectedType != (widget.initialType ?? InteractionType.call) ||
          !_isSameDay(_selectedDate, widget.initialDate ?? DateTime.now());
    } else {
      final data = widget.editData!;
      return _subjectController.text.trim() != data.subject.trim() ||
          _descriptionController.text.trim() != data.description.trim() ||
          _selectedType != data.type ||
          !_isSameDay(_selectedDate, data.date);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool get _canSave {
    if (!_isDirty) return false;
    if (_subjectController.text.trim().isEmpty) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<InteractionFormCubit, InteractionFormState>(
      listener: _onStateChanged,
      builder: (context, state) {
        final isSubmitting = state is InteractionFormSubmitting;

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
                    _buildHeader(context),
                    SizedBox(height: InteractionLayoutConstants.sheetFieldGap),
                    _buildTypeSelector(context),
                    SizedBox(height: InteractionLayoutConstants.sheetFieldGap),
                    _buildDatePicker(context),
                    SizedBox(height: InteractionLayoutConstants.sheetFieldGap),
                    _buildSubjectField(context),
                    SizedBox(height: InteractionLayoutConstants.sheetFieldGap),
                    _buildDescriptionField(context),
                    if (widget.mode == SheetMode.add) ...[
                      SizedBox(
                        height: InteractionLayoutConstants.sheetFieldGap,
                      ),
                      _buildContactSelector(context),
                    ],
                    if (widget.contextLabel != null) ...[
                      SizedBox(
                        height: InteractionLayoutConstants.sheetFieldGap,
                      ),
                      _buildContextLabel(context),
                    ],
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
                    _buildActions(context, isSubmitting),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final labels = context.t.crm.editor;
    return Text(
      widget.mode == SheetMode.add ? labels.titleAdd : labels.titleEdit,
      style: context.textStyles.headlineSmall,
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    final labels = context.t.crm.editor;
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labels.type, style: textStyles.labelMedium),
        SizedBox(height: AppSpacing.xs),
        SegmentedButton<InteractionType>(
          segments: [
            ButtonSegment(
              value: InteractionType.call,
              label: Text(labels.typeCall),
              icon: const Icon(Icons.call_rounded, size: 20),
            ),
            ButtonSegment(
              value: InteractionType.email,
              label: Text(labels.typeEmail),
              icon: const Icon(Icons.email_rounded, size: 20),
            ),
            ButtonSegment(
              value: InteractionType.meeting,
              label: Text(labels.typeMeeting),
              icon: const Icon(Icons.meeting_room_rounded, size: 20),
            ),
          ],
          selected: {_selectedType},
          onSelectionChanged: (set) {
            if (set.isNotEmpty) {
              setState(() => _selectedType = set.first);
            }
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colors.primary;
              }
              return colors.surfaceVariant;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colors.onPrimary;
              }
              return colors.textSecondary;
            }),
            side: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return BorderSide.none;
              }
              return BorderSide(color: colors.border);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final labels = context.t.crm.editor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labels.date, style: context.textStyles.labelMedium),
        SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: () => _pickDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: labels.date,
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(color: context.colors.border),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            child: Text(
              Formatters.crmDate(_selectedDate),
              style: context.textStyles.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildSubjectField(BuildContext context) {
    return ShakeWidget(
      trigger: _failureTrigger,
      haptic: true,
      child: AppTextField(
        controller: _subjectController,
        focusNode: _subjectFocusNode,
        label: context.t.crm.editor.subject,
        hint: context.t.crm.editor.subject,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (_) => setState(() => _failure = null),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return context.t.crm.editor.subjectRequired;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return AppTextField(
      controller: _descriptionController,
      focusNode: _descriptionFocusNode,
      label: context.t.crm.editor.description,
      hint: context.t.crm.editor.description,
      minLines: InteractionLayoutConstants.sheetMinLines,
      maxLines: InteractionLayoutConstants.sheetMaxLines,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (_) => setState(() => _failure = null),
    );
  }

  Widget _buildContactSelector(BuildContext context) {
    final labels = context.t.crm.editor;
    final colors = context.colors;
    final contacts = widget.contacts ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labels.contactOptional, style: context.textStyles.labelMedium),
        SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            FilterChip(
              label: Text(labels.contactNone),
              selected: _selectedContactId == null,
              onSelected: (_) => setState(() => _selectedContactId = null),
              backgroundColor: colors.surfaceVariant,
              selectedColor: colors.primaryContainer,
              checkmarkColor: colors.onPrimaryContainer,
            ),
            for (final contact in contacts)
              FilterChip(
                label: Text(contact.label),
                selected: _selectedContactId == contact.id,
                onSelected: (_) =>
                    setState(() => _selectedContactId = contact.id),
                backgroundColor: colors.surfaceVariant,
                selectedColor: colors.primaryContainer,
                checkmarkColor: colors.onPrimaryContainer,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildContextLabel(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colors.textSecondary, size: 20),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              widget.contextLabel!,
              style: context.textStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isSubmitting) {
    final common = context.t.crm.common;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppButton.text(
          label: common.cancel,
          onPressed: isSubmitting ? null : _cancel,
        ),
        SizedBox(width: AppSpacing.sm),
        AppButton(
          label: common.save,
          isLoading: isSubmitting,
          onPressed: _canSave && !isSubmitting ? _submit : null,
        ),
      ],
    );
  }

  void _onStateChanged(BuildContext context, InteractionFormState state) {
    if (state is InteractionFormSuccess) {
      if (context.mounted) Navigator.of(context).pop();
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

    if (widget.mode == SheetMode.add) {
      final params = AddInteractionParams(
        type: _selectedType,
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        interactionDate: _selectedDate,
        customerId: widget.customerId!,
        contactId: _selectedContactId,
        opportunityId: widget.opportunityId,
      );
      widget.onSubmit(params);
    } else {
      final params = UpdateInteractionParams(
        interactionId: widget.editData!.interactionId,
        type: _selectedType,
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        interactionDate: _selectedDate,
      );
      widget.onSubmit(params);
    }
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
