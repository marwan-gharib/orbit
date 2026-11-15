import 'package:flutter/material.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/utils/formatters.dart';

/// Relative time of a note with its absolute CRM date in the tooltip and the
/// semantics label (no ambiguous month/day ordering on screen).
class NoteTimestamp extends StatelessWidget {
  const NoteTimestamp({super.key, required this.createdAt, this.now});

  final DateTime createdAt;

  /// Reference instant; tests pin it, production uses the current time.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final labels = context.t.crm.crmNotes;
    final relative = _relativeLabel(
      context,
      Formatters.relativeParts(createdAt, now: now),
    );
    final absolute = Formatters.crmDate(createdAt);

    return Semantics(
      label: labels.timestampA11y(relative: relative, date: absolute),
      excludeSemantics: true,
      child: Tooltip(
        message: absolute,
        child: Text(
          relative,
          style: context.textStyles.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

String _relativeLabel(BuildContext context, RelativeTimeParts parts) {
  final labels = context.t.crm.crmNotes.relative;
  return switch (parts.unit) {
    RelativeTimeUnit.justNow => labels.now,
    RelativeTimeUnit.minutes =>
      parts.value == 1 ? labels.minuteAgo : labels.minutesAgo(n: parts.value),
    RelativeTimeUnit.hours =>
      parts.value == 1 ? labels.hourAgo : labels.hoursAgo(n: parts.value),
    RelativeTimeUnit.days =>
      parts.value == 1 ? labels.dayAgo : labels.daysAgo(n: parts.value),
  };
}
