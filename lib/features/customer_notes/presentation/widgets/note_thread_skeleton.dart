import 'package:flutter/material.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';

import '../constants/note_layout_constants.dart';

/// Loading twin of the note thread: the same avatar and column geometry as
/// [NoteTile], swept by one [ShimmerScope] driver.
class NoteThreadSkeleton extends StatelessWidget {
  const NoteThreadSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final loadingLabel = context.t.crm.crmNotes.loading;

    return Semantics(
      label: loadingLabel,
      container: true,
      child: ExcludeSemantics(
        child: ShimmerScope(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (
                var index = 0;
                index < NoteLayoutConstants.skeletonRows;
                index++
              ) ...[
                if (index > 0)
                  SizedBox(height: NoteLayoutConstants.skeletonRowGap),
                const _SkeletonNoteRow(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonNoteRow extends StatelessWidget {
  const _SkeletonNoteRow();

  @override
  Widget build(BuildContext context) {
    final avatarSize = NoteLayoutConstants.avatarSize;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox.circle(width: avatarSize, height: avatarSize),
        SizedBox(width: NoteLayoutConstants.avatarGap),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ShimmerBox.textLine(
                      width:
                          constraints.maxWidth *
                          NoteLayoutConstants.skeletonAuthorWidth,
                    ),
                    const Spacer(),
                    ShimmerBox.textLine(
                      width:
                          constraints.maxWidth *
                          NoteLayoutConstants.skeletonTimestampWidth,
                    ),
                  ],
                ),
                SizedBox(height: NoteLayoutConstants.contentGap),
                const ShimmerBox.textLine(),
                SizedBox(height: NoteLayoutConstants.contentGap),
                const ShimmerBox.textLine(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
