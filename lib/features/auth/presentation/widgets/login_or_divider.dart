import 'package:flutter/material.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

/// A subtle horizontal divider row with centered "or" text.
class LoginOrDivider extends StatelessWidget {
  const LoginOrDivider({
    this.delay = const Duration(milliseconds: 250),
    super.key,
  });

  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return FadeSlideIn(
      delay: delay,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: colors.border,
              thickness: 1,
              height: 1,
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
            child: Text(
              context.t.auth.login.orDivider,
              style: textStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: colors.border,
              thickness: 1,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
