import 'package:flutter/material.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_button.dart';

import '../constants/note_layout_constants.dart';

/// The note body, clamped to [maxLines] with a Show more / Show less action
/// only when the text actually overflows at the current width and text scale.
class NoteTextBody extends StatefulWidget {
  const NoteTextBody({
    super.key,
    required this.text,
    this.maxLines = NoteLayoutConstants.collapsedLines,
  });

  final String text;
  final int maxLines;

  @override
  State<NoteTextBody> createState() => _NoteTextBodyState();
}

class _NoteTextBodyState extends State<NoteTextBody> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final labels = context.t.crm.crmNotes;
    final style = context.textStyles.bodyMedium.copyWith(
      color: context.colors.textPrimary,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final overflows = _overflows(context, style, constraints.maxWidth);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSizeWrapper(
              alignment: AlignmentDirectional.topStart,
              child: Text(
                widget.text,
                style: style,
                maxLines: _expanded ? null : widget.maxLines,
                overflow: _expanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
            ),
            if (overflows)
              AppButton.text(
                label: _expanded ? labels.showLess : labels.showMore,
                minimumSize: Size.square(NoteLayoutConstants.minTapTarget),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
          ],
        );
      },
    );
  }

  bool _overflows(BuildContext context, TextStyle style, double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: style),
      maxLines: widget.maxLines,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);
    final overflows = painter.didExceedMaxLines;
    painter.dispose();
    return overflows;
  }
}
