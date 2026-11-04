import 'package:flutter/material.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/widgets/empty_state.dart';
import 'package:orbit/core/widgets/error_state.dart';

import '../../domain/entities/customer_note_entity.dart';
import '../cubits/customer_notes_list/customer_notes_list_state.dart';
import 'note_refresh_notice.dart';
import 'note_thread_content.dart';
import 'note_thread_header.dart';
import 'note_thread_skeleton.dart';

/// One state of the notes thread: header, silent-refresh notice and the
/// loading / content / empty / error body.
class CustomerNotesView extends StatefulWidget {
  const CustomerNotesView({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onEdit,
    required this.onDelete,
  });

  final CustomerNotesListState state;
  final VoidCallback onRetry;
  final ValueChanged<CustomerNote> onEdit;
  final ValueChanged<CustomerNote> onDelete;

  @override
  State<CustomerNotesView> createState() => _CustomerNotesViewState();
}

class _CustomerNotesViewState extends State<CustomerNotesView> {
  /// Dismissal is UI-local: the cubit keeps the last failure so a rebuild
  /// cannot resurrect a notice the user closed. Identity, not equality, so a
  /// new failure with the same text shows again.
  Failure? _dismissedFailure;

  @override
  Widget build(BuildContext context) {
    final failure = _refreshFailure(widget.state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        NoteThreadHeader(total: _total(widget.state)),
        SizedBox(height: AppSpacing.md),
        if (failure != null && !identical(failure, _dismissedFailure)) ...[
          NoteRefreshNotice(
            message: context.t.crm.crmNotes.refreshFailed,
            dismissLabel: context.t.crm.common.dismiss,
            onDismiss: () => setState(() => _dismissedFailure = failure),
          ),
          SizedBox(height: AppSpacing.sm),
        ],
        AppAnimatedSwitcher(child: _body(context)),
      ],
    );
  }

  Widget _body(BuildContext context) {
    final state = widget.state;
    final labels = context.t.crm.crmNotes;

    return switch (state) {
      CustomerNotesListInitial() || CustomerNotesListLoading() =>
        const NoteThreadSkeleton(key: ValueKey('notes-skeleton')),
      CustomerNotesListSuccess(:final notes, :final isRefreshing) =>
        NoteThreadContent(
          key: const ValueKey('notes-content'),
          notes: notes,
          isRefreshing: isRefreshing,
          onEdit: widget.onEdit,
          onDelete: widget.onDelete,
        ),
      CustomerNotesListEmpty() => EmptyState(
        key: const ValueKey('notes-empty'),
        title: labels.empty,
        message: labels.emptyMessage,
        icon: Icons.sticky_note_2_outlined,
      ),
      CustomerNotesListError(:final failure) => ErrorState(
        key: const ValueKey('notes-error'),
        message: context.failureText(failure),
        retryAction: (
          label: context.t.crm.common.retry,
          onPressed: widget.onRetry,
        ),
      ),
    };
  }

  int? _total(CustomerNotesListState state) => switch (state) {
    CustomerNotesListSuccess(:final total) => total,
    CustomerNotesListEmpty() => 0,
    _ => null,
  };

  Failure? _refreshFailure(CustomerNotesListState state) => switch (state) {
    CustomerNotesListSuccess(:final refreshFailure) => refreshFailure,
    CustomerNotesListEmpty(:final refreshFailure) => refreshFailure,
    _ => null,
  };
}
