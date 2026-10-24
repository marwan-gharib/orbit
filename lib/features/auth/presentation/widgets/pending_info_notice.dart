import 'package:flutter/material.dart';

import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import '../constants/auth_layout_constants.dart';

/// Neutral inline result for a status check that completed without a
/// decision ("No change yet. Your request is still under review.").
///
/// It is announced once as a live region and stays until the next check
/// replaces it; no motion of its own (the screen fades it in).
class PendingInfoNotice extends StatelessWidget {
  const PendingInfoNotice({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Semantics(
      liveRegion: true,
      label: message,
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsetsDirectional.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: AppRadius.borderMd,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: AuthLayout.noticeIconSize,
                color: colors.onSecondaryContainer,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: textStyles.bodySmall.copyWith(
                    color: colors.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
