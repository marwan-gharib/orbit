import 'package:flutter/material.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/features/onboarding/presentation/constants/onboarding_layout_constants.dart';
import 'package:orbit/features/onboarding/presentation/cubit/onboarding_constants.dart';

/// Skip button at the end side of the fixed-height top bar.
/// On the last slide it fades, slides and shrinks out while the bar keeps its
/// full height; while hidden it is not tappable and excluded from semantics.
class OnboardingSkipButton extends StatelessWidget {
  const OnboardingSkipButton({
    required this.isLastPage,
    required this.onPressed,
    super.key,
  });

  final bool isLastPage;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = context.colors;

    return AnimatedVisibility(
      visible: !isLastPage,
      duration: OnboardingAnimationTimings.skipTransition,
      curve: OnboardingAnimationTimings.entranceCurve,
      reverseCurve: AppCurves.exit,
      offset: AppAnimationConstants.slideFromEnd * 1.5,
      scaleBegin: 0.85,
      collapseSize: false,
      child: AppButton.content(
        key: OnboardingLayoutKeys.skipButton,
        variant: AppButtonVariant.text,
        semanticLabel: t.onboarding.a11y.skipButton,
        onPressed: onPressed,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        minimumSize: Size.square(OnboardingLayout.minTouchTarget),
        content: Text(
          t.onboarding.skip,
          style: context.textStyles.labelLarge.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
