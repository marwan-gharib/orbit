import 'package:flutter/material.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/widgets/app_text_field.dart' show AppTextField;

import '../constants/interaction_layout_constants.dart';

/// Required subject: shakes and shows its inline message when
/// [validationTrigger] changes.
class InteractionSubjectField extends StatelessWidget {
  const InteractionSubjectField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.errorText,
    required this.validationTrigger,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final int validationTrigger;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = context.t.crm.editor;

    return ShakeWidget(
      trigger: validationTrigger,
      haptic: true,
      child: AppTextField(
        controller: controller,
        focusNode: focusNode,
        label: labels.subject,
        hint: labels.subject,
        errorText: errorText,
        textCapitalization: TextCapitalization.sentences,
        onChanged: onChanged,
      ),
    );
  }
}

/// Multi-line description that grows smoothly up to a few lines.
class InteractionDescriptionField extends StatelessWidget {
  const InteractionDescriptionField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = context.t.crm.editor;

    return AnimatedSizeWrapper(
      child: AppTextField(
        controller: controller,
        focusNode: focusNode,
        label: labels.description,
        hint: labels.description,
        minLines: InteractionLayoutConstants.sheetMinLines,
        maxLines: InteractionLayoutConstants.sheetMaxLines,
        textCapitalization: TextCapitalization.sentences,
        onChanged: onChanged,
      ),
    );
  }
}
