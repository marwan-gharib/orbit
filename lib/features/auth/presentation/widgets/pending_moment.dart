import 'package:flutter/material.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import '../../domain/enums/employment_status.dart';
import '../constants/auth_layout_constants.dart';

/// The short terminal card shown for `AppConsts.pendingMomentHold` after an
/// approval or rejection, before the screen leaves the flow.
///
/// Entrance: [FadeIn] + [ScaleIn] (both one-shot, `AppDurations.normal`,
/// `AppCurves.enter`), reduced motion renders the final state immediately.
/// The screen owns the hold timer and the exit action; this widget only
/// presents the decision and announces it once as a live region.
class PendingMoment extends StatelessWidget {
  const PendingMoment({required this.status, super.key});

  /// Either `approved` or `rejected`.
  final EmploymentStatus status;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = context.colors;
    final textStyles = context.textStyles;
    final approved = status == EmploymentStatus.approved;
    final background = approved
        ? colors.successContainer
        : colors.errorContainer;
    final foreground = approved
        ? colors.onSuccessContainer
        : colors.onErrorContainer;
    final accent = approved ? colors.success : colors.error;
    final icon = approved ? Icons.check_rounded : Icons.close_rounded;
    final message = approved
        ? t.auth.pending.moments.approved
        : t.auth.pending.moments.rejected;

    return Semantics(
      liveRegion: true,
      label: message,
      child: ExcludeSemantics(
        child: FadeIn(
          child: Container(
            padding: EdgeInsetsDirectional.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: background,
              borderRadius: AppRadius.borderXl,
            ),
            child: Column(
              children: [
                Container(
                  width: AuthLayout.momentHaloSize,
                  height: AuthLayout.momentHaloSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(
                      alpha: AuthLayout.momentHaloOpacity,
                    ),
                  ),
                  child: ScaleIn(
                    child: Icon(
                      icon,
                      size: AuthLayout.momentIconSize,
                      color: accent,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: textStyles.titleMedium.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
