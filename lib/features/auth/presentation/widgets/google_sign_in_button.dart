import 'package:flutter/material.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/constants/assets.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_button.dart';

/// Interactive button for "Continue with Google" sign-in flow.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    required this.onPressed,
    this.isLoading = false,
    this.delay = const Duration(milliseconds: 300),
    super.key,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final t = context.t;

    final iconSize = Responsive.adapt(20);
    final boxSize = Responsive.adapt(24);

    return RepaintBoundary(
      child: FadeSlideIn(
        delay: delay,
        child: AppButton.content(
          onPressed: isLoading ? null : onPressed,
          variant: AppButtonVariant.elevated,
          cornerRadius: AppRadius.borderLg,
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          semanticLabel: t.auth.login.a11y.googleSignIn,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: boxSize,
                height: boxSize,
                child: Center(
                  child: AppAnimatedSwitcher(
                    duration: AppDurations.fast,
                    child: isLoading
                        ? SizedBox(
                            key: const ValueKey<String>('google_loading_indicator'),
                            width: iconSize,
                            height: iconSize,
                            child: CircularProgressIndicator(
                              strokeWidth: Responsive.adapt(2),
                              valueColor: AlwaysStoppedAnimation(colors.primary),
                            ),
                          )
                        : RepaintBoundary(
                            key: const ValueKey<String>('google_logo_image'),
                            child: Image.asset(
                              Assets.googleLogo,
                              width: iconSize,
                              height: iconSize,
                              fit: BoxFit.contain,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  isLoading
                      ? t.auth.login.googleSignInLoading
                      : t.auth.login.googleSignIn,
                  style: textStyles.labelLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
