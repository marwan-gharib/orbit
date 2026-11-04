import 'package:flutter/material.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/utils/list_diff.dart';
import 'package:orbit/core/widgets/highlight_flash.dart';

import '../../domain/entities/customer_note_entity.dart';
import '../constants/note_layout_constants.dart';
import '../mappers/customer_note_mapper.dart';
import 'note_tile.dart';

/// The loaded notes of one customer, newest first.
///
/// The repository already sorts, so this widget never re-sorts. A silent
/// refetch is diffed by note id: arrivals slide in and flash, edits flash,
/// departures collapse, and every untouched row keeps its state.
class NoteThreadContent extends StatefulWidget {
  const NoteThreadContent({
    super.key,
    required this.notes,
    required this.isRefreshing,
    required this.onEdit,
    required this.onDelete,
  });

  final List<CustomerNote> notes;
  final bool isRefreshing;
  final ValueChanged<CustomerNote> onEdit;
  final ValueChanged<CustomerNote> onDelete;

  @override
  State<NoteThreadContent> createState() => _NoteThreadContentState();
}

class _NoteThreadContentState extends State<NoteThreadContent> {
  final Map<int, int> _flashTokens = {};
  List<_DepartedNote> _departed = const [];

  @override
  void didUpdateWidget(covariant NoteThreadContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    final diff = diffList<int>(
      previous: [for (final note in oldWidget.notes) note.noteId],
      next: [for (final note in widget.notes) note.noteId],
      keyOf: (noteId) => noteId,
    );

    final previousById = {
      for (final note in oldWidget.notes) note.noteId: note,
    };
    final addedIds = diff.added.toSet();
    for (final note in widget.notes) {
      final previous = previousById[note.noteId];
      final isChanged = previous != null && previous.noteText != note.noteText;
      if (addedIds.contains(note.noteId) || isChanged) {
        _flashTokens[note.noteId] = (_flashTokens[note.noteId] ?? 0) + 1;
      }
    }

    if (diff.removed.isNotEmpty) {
      final previousPositions = {
        for (var index = 0; index < oldWidget.notes.length; index++)
          oldWidget.notes[index].noteId: index,
      };
      final nextIds = {for (final note in widget.notes) note.noteId};
      final merged = [
        ..._departed.where((entry) => !nextIds.contains(entry.note.noteId)),
        for (final noteId in diff.removed)
          if (previousById[noteId] case final note?)
            _DepartedNote(
              note: note,
              position: previousPositions[noteId] ?? oldWidget.notes.length,
            ),
      ];
      _departed = merged.length > NoteLayoutConstants.maxDepartingRows
          ? merged.sublist(merged.length - NoteLayoutConstants.maxDepartingRows)
          : merged;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries();
    final lastNoteId = widget.notes.isEmpty ? null : widget.notes.last.noteId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedVisibility(
          visible: widget.isRefreshing,
          child: Padding(
            padding: EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
            child: const AnimatedProgressBar(),
          ),
        ),
        for (final entry in entries)
          _buildEntry(entry, isLastVisible: entry.note.noteId == lastNoteId),
      ],
    );
  }

  List<_ThreadEntry> _entries() {
    final entries = [
      for (var index = 0; index < widget.notes.length; index++)
        _ThreadEntry(
          note: widget.notes[index],
          position: index,
          isDeparted: false,
        ),
      for (final entry in _departed)
        _ThreadEntry(
          note: entry.note,
          position: entry.position,
          isDeparted: true,
        ),
    ];
    entries.sort((a, b) {
      final byPosition = a.position.compareTo(b.position);
      if (byPosition != 0) return byPosition;
      return a.isDeparted ? -1 : 1;
    });
    return entries;
  }

  Widget _buildEntry(_ThreadEntry entry, {required bool isLastVisible}) {
    final note = entry.note;
    final tile = NoteTile(
      note: note.toViewModel(),
      onEdit: () => widget.onEdit(note),
      onDelete: () => widget.onDelete(note),
    );
    final gap = isLastVisible ? 0.0 : NoteLayoutConstants.noteGap;

    if (entry.isDeparted) {
      return _CollapsingNote(
        key: ValueKey('note-departing-${note.noteId}'),
        child: IgnorePointer(
          child: ExcludeSemantics(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                bottom: NoteLayoutConstants.noteGap,
              ),
              child: tile,
            ),
          ),
        ),
      );
    }

    return StaggeredListItem(
      key: ValueKey('note-${note.noteId}'),
      index: entry.position,
      child: Padding(
        padding: EdgeInsetsDirectional.only(bottom: gap),
        child: HighlightFlash(
          token: _flashTokens[note.noteId],
          borderRadius: NoteLayoutConstants.highlightRadius,
          child: tile,
        ),
      ),
    );
  }
}

/// A row that mounted still visible for one frame, then collapses.
///
/// [AnimatedVisibility] starts at its target state, so a widget created with
/// `visible: false` would disappear without playing the reverse leg; flipping
/// after the first frame lets a removed note collapse where it used to be.
class _CollapsingNote extends StatefulWidget {
  const _CollapsingNote({super.key, required this.child});

  final Widget child;

  @override
  State<_CollapsingNote> createState() => _CollapsingNoteState();
}

class _CollapsingNoteState extends State<_CollapsingNote> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) =>
      AnimatedVisibility(visible: _visible, child: widget.child);
}

/// One row of the built thread; departed rows keep their old position so the
/// collapse happens where the note used to be.
class _ThreadEntry {
  const _ThreadEntry({
    required this.note,
    required this.position,
    required this.isDeparted,
  });

  final CustomerNote note;
  final int position;
  final bool isDeparted;
}

class _DepartedNote {
  const _DepartedNote({required this.note, required this.position});

  final CustomerNote note;
  final int position;
}
