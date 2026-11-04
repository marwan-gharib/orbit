import 'package:flutter/material.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/widgets/app_button.dart';

import '../constants/note_layout_constants.dart';

/// How the composer's send action currently reads.
enum NoteSendStatus { idle, sending, sent, failed }

/// The composer's circular send action: morphs between idle, sending, sent
/// and failed, and is disabled while the field has nothing sendable.
class NoteSendButton extends StatelessWidget {
  const NoteSendButton({
    super.key,
    required this.status,
    required this.onPressed,
  });

  final NoteSendStatus status;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final labels = context.t.crm.crmNotes;

    return AppButton.icon(
      semanticLabel: switch (status) {
        NoteSendStatus.idle => labels.sendA11y,
        NoteSendStatus.sending => labels.sending,
        NoteSendStatus.sent => labels.sent,
        NoteSendStatus.failed => labels.sendFailed,
      },
      variant: AppButtonVariant.filled,
      destructive: status == NoteSendStatus.failed,
      isLoading: status == NoteSendStatus.sending,
      size: NoteLayoutConstants.sendButtonSize,
      onPressed: onPressed,
      icon: AppAnimatedSwitcher(
        child: Icon(
          switch (status) {
            NoteSendStatus.sent => Icons.check,
            NoteSendStatus.failed => Icons.priority_high,
            _ => Icons.arrow_upward,
          },
          key: ValueKey(status),
          size: Responsive.adapt(24),
        ),
      ),
    );
  }
}
