import 'package:flutter/material.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

/// Thread title with the plural note count; [total] is null until the list
/// has loaded, so the trailing count never shows a fabricated number.
class NoteThreadHeader extends StatelessWidget {
  const NoteThreadHeader({super.key, required this.total});

  final int? total;

  @override
  Widget build(BuildContext context) {
    final labels = context.t.crm.crmNotes;
    final count = total;

    return Row(
      children: [
        Expanded(
          child: Text(
            labels.threadTitle,
            style: context.textStyles.titleMedium,
          ),
        ),
        if (count != null)
          Text(
            count == 1 ? labels.countOne : labels.countOther(n: count),
            style: context.textStyles.labelMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
      ],
    );
  }
}
