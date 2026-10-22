import 'package:flutter/material.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_card.dart';
import 'package:orbit/core/widgets/status_badge.dart';

import '../../domain/enums/employment_status.dart';
import '../mappers/employment_status_view.dart';
import 'pending_stepper.dart';

/// The pending flow's main card: who is waiting, the current status badge,
/// the three-step progress and when the status was last checked.
///
/// The greeting appears only once a check has returned the person's name;
/// before that the screen knows only the work email.
class PendingStatusCard extends StatelessWidget {
  const PendingStatusCard({
    required this.email,
    required this.status,
    required this.lastCheckedAt,
    this.firstName,
    super.key,
  });

  /// Work email the account was created with; shown unmasked (D7).
  final String email;

  /// Latest known status; pending before the first check.
  final EmploymentStatus status;

  /// When the latest check finished, or `null` before the first check.
  final DateTime? lastCheckedAt;

  /// First name from a successful check, when one has happened.
  final String? firstName;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = context.colors;
    final textStyles = context.textStyles;
    final name = firstName?.trim();
    final checkedAt = lastCheckedAt;
    final lastChecked = checkedAt == null
        ? t.auth.pending.lastCheckedNever
        : t.auth.pending.lastCheckedAt(
            time: MaterialLocalizations.of(context).formatTimeOfDay(
              TimeOfDay.fromDateTime(checkedAt),
              alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(
                context,
              ),
            ),
          );

    return AppCard(
      padding: EdgeInsetsDirectional.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (name != null && name.isNotEmpty) ...[
            Text(
              t.auth.pending.greeting(name: name),
              style: textStyles.titleMedium,
            ),
            SizedBox(height: AppSpacing.lg),
          ],
          Text(
            t.auth.pending.emailLabel,
            style: textStyles.labelMedium.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(email, style: textStyles.bodyMedium),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  t.auth.pending.statusLabel,
                  style: textStyles.labelMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              StatusBadge(
                label: status.label(context),
                status: status.badgeStatus,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          PendingStepper(status: status),
          SizedBox(height: AppSpacing.md),
          Text(
            lastChecked,
            style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
