import 'package:flutter/material.dart';
import 'package:orbit/core/animations/selection/selection.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/utils/formatters.dart';

import '../../domain/enums/interaction_type.dart';
import '../constants/interaction_layout_constants.dart';
import '../view_models/interaction_tile_data.dart' show InteractionContactOption;

/// Label above a sheet field.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
    child: Text(text, style: context.textStyles.labelMedium),
  );
}

/// Call / Email / Meeting as a segmented control with a sliding indicator.
class InteractionTypeSelector extends StatelessWidget {
  const InteractionTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final InteractionType selected;
  final ValueChanged<InteractionType> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = context.t.crm.editor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(labels.type),
        AnimatedChipSelector<InteractionType>(
          selectedValue: selected,
          onChanged: onChanged,
          items: [
            ChipItem(
              value: InteractionType.call,
              label: labels.typeCall,
              icon: Icons.call_rounded,
            ),
            ChipItem(
              value: InteractionType.email,
              label: labels.typeEmail,
              icon: Icons.email_rounded,
            ),
            ChipItem(
              value: InteractionType.meeting,
              label: labels.typeMeeting,
              icon: Icons.meeting_room_rounded,
            ),
          ],
        ),
      ],
    );
  }
}

/// Tappable date field that opens the date picker.
class InteractionDateField extends StatelessWidget {
  const InteractionDateField({
    super.key,
    required this.date,
    required this.onChanged,
  });

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labels = context.t.crm.editor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(labels.date),
        InkWell(
          onTap: () => _pick(context),
          borderRadius: AppRadius.borderMd,
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(color: colors.border),
              ),
              suffixIcon: const Icon(Icons.calendar_today_rounded),
              contentPadding: EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            child: Text(
              Formatters.crmDate(date),
              style: context.textStyles.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}

/// Optional contact: a horizontal chip row ("None" + the customer's contacts).
class InteractionContactSelector extends StatelessWidget {
  const InteractionContactSelector({
    super.key,
    required this.contacts,
    required this.selectedId,
    required this.onChanged,
  });

  final List<InteractionContactOption> contacts;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = context.t.crm.editor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(labels.contactOptional),
        AnimatedChipSelector<int?>(
          scrollable: true,
          selectedValue: selectedId,
          onChanged: onChanged,
          items: [
            ChipItem<int?>(value: null, label: labels.contactNone),
            for (final contact in contacts)
              ChipItem<int?>(value: contact.id, label: contact.label),
          ],
        ),
      ],
    );
  }
}

/// Read-only line showing the customer / opportunity the interaction is for.
class InteractionContextLabel extends StatelessWidget {
  const InteractionContextLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: colors.textSecondary,
            size: InteractionLayoutConstants.swipeIconSize,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: context.textStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
