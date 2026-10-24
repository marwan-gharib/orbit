import 'package:flutter/material.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import '../constants/auth_layout_constants.dart';

/// Brand badge, screen title and supporting sentence shared by the auth
/// screens. The badge is drawn from theme tokens instead of the splash image,
/// whose opaque white background cannot follow light and dark mode.
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({
    required this.title,
    required this.subtitle,
    super.key,
  });

  /// Localized screen title (for example "Welcome back").
  final String title;

  /// Localized supporting sentence under the title.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          image: true,
          label: context.t.app.title,
          child: ExcludeSemantics(
            child: Container(
              width: AuthLayout.brandMarkSize,
              height: AuthLayout.brandMarkSize,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: AppRadius.borderMd,
              ),
              child: Icon(
                Icons.radar,
                size: AuthLayout.brandMarkIconSize,
                color: colors.onPrimary,
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Text(title, style: textStyles.headlineMedium),
        SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: textStyles.bodyMedium.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
