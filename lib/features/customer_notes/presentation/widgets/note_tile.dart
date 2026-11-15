import 'package:flutter/material.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import '../constants/note_layout_constants.dart';
import '../view_models/customer_note_view_model.dart';
import 'note_text_body.dart';
import 'note_timestamp.dart';

/// What the row's overflow menu can do to its note.
enum NoteAction { edit, delete }

/// One note in the thread: initials avatar, author, relative time, the
/// clamped body and the Edit / Delete overflow menu.
class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  final CustomerNoteViewModel note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final labels = context.t.crm.crmNotes;
    final textStyles = context.textStyles;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: _InitialsAvatar(initials: note.initials)),
        SizedBox(width: NoteLayoutConstants.avatarGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.authorName,
                      style: textStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  NoteTimestamp(createdAt: note.createdAt),
                  AppPopupMenu<NoteAction>(
                    tooltip: labels.moreActions,
                    items: [
                      PopupMenuItem(
                        value: NoteAction.edit,
                        child: Text(labels.edit),
                      ),
                      PopupMenuItem(
                        value: NoteAction.delete,
                        child: Text(labels.delete),
                      ),
                    ],
                    onSelected: (action) {
                      switch (action) {
                        case NoteAction.edit:
                          onEdit();
                        case NoteAction.delete:
                          onDelete();
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: NoteLayoutConstants.contentGap),
              NoteTextBody(text: note.text),
            ],
          ),
        ),
      ],
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final size = NoteLayoutConstants.avatarSize;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: context.textStyles.labelMedium.copyWith(
          color: context.colors.onPrimaryContainer,
        ),
      ),
    );
  }
}
