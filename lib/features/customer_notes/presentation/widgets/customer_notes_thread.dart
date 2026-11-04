import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orbit/core/animations/overlays/app_bottom_sheet.dart';
import 'package:orbit/core/animations/overlays/app_dialog_route.dart';
import 'package:orbit/core/di/injection_container.dart';

import '../../domain/entities/customer_note_entity.dart';
import '../cubits/customer_note_delete/customer_note_delete_cubit.dart';
import '../cubits/customer_note_form/customer_note_form_cubit.dart';
import '../cubits/customer_notes_list/customer_notes_list_cubit.dart';
import '../cubits/customer_notes_list/customer_notes_list_state.dart';
import 'customer_notes_view.dart';
import 'note_delete_dialog.dart';
import 'note_edit_sheet.dart';

/// The customer's notes thread, newest first.
///
/// Sizes to its content and never scrolls itself, so a page decides how the
/// thread moves. Owns its list cubit (recreated when [customerId] changes)
/// and the one-shot form/delete cubits of the sheets and dialog it opens.
class CustomerNotesThread extends StatelessWidget {
  const CustomerNotesThread({super.key, required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    key: ValueKey(customerId),
    create: (_) => getIt<CustomerNotesListCubit>()..load(customerId),
    child: BlocBuilder<CustomerNotesListCubit, CustomerNotesListState>(
      builder: (context, state) => CustomerNotesView(
        state: state,
        onRetry: () => context.read<CustomerNotesListCubit>().refresh(),
        onEdit: (note) => _edit(context, note),
        onDelete: (note) => _delete(context, note),
      ),
    ),
  );

  Future<void> _edit(BuildContext context, CustomerNote note) async {
    final formCubit = getIt<CustomerNoteFormCubit>()..startEdit(note);
    try {
      await AppBottomSheet.show<void>(
        context: context,
        isScrollControlled: true,
        enableDrag: false,
        showDragHandle: false,
        builder: (_) => BlocProvider.value(
          value: formCubit,
          child: NoteEditSheet(noteId: note.noteId, initialText: note.noteText),
        ),
      );
    } finally {
      await formCubit.close();
    }
  }

  Future<void> _delete(BuildContext context, CustomerNote note) async {
    final deleteCubit = getIt<CustomerNoteDeleteCubit>();
    try {
      await showAppDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => BlocProvider.value(
          value: deleteCubit,
          child: NoteDeleteDialog(onConfirm: () => deleteCubit.delete(note)),
        ),
      );
    } finally {
      await deleteCubit.close();
    }
  }
}
