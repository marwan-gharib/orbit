import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/features/onboarding/presentation/constants/onboarding_layout_constants.dart';
import 'package:orbit/features/onboarding/presentation/cubit/onboarding_constants.dart';

/// Bottom controls: a Back slot at the start side that animates its width to
/// zero on slide 1, and the Next / Get started button that morphs its width
/// factor to fill the remaining row on the last slide. The row never resizes
/// its height — the screen's controls band fixes it.
class OnboardingNavButtons extends StatelessWidget {
  const OnboardingNavButtons({
    required this.isFirstPage,
    required this.isLastPage,
    required this.onNext,
    required this.onBack,
    super.key,
  });

  final bool isFirstPage;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        // The controls band gives the button height; never below the
        // minimum touch target.
        final buttonHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : OnboardingLayout.minButtonHeight;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _BackSlot(
              isFirstPage: isFirstPage,
              buttonHeight: buttonHeight,
              slotWidth: buttonHeight + AppSpacing.sm,
              label: t.onboarding.a11y.backButton,
              onBack: onBack,
            ),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _NextButton(
                  isLastPage: isLastPage,
                  onPressed: onNext,
                  nextLabel: t.onboarding.next,
                  getStartedLabel: t.onboarding.getStarted,
                  semanticsLabelNext: t.onboarding.a11y.nextButton,
                  semanticsLabelGetStarted: t.onboarding.a11y.getStartedButton,
                  colors: colors,
                  buttonHeight: buttonHeight,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Start-side slot: 0 width on slide 1, button width (+ gap) from slide 2.
/// Clipped while collapsed so no invisible tappable area remains (UI-7).
class _BackSlot extends StatelessWidget {
  const _BackSlot({
    required this.isFirstPage,
    required this.buttonHeight,
    required this.slotWidth,
    required this.label,
    required this.onBack,
  });

  final bool isFirstPage;
  final double buttonHeight;
  final double slotWidth;
  final String label;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSizeWrapper(
        duration: OnboardingAnimationTimings.buttonMorph,
        curve: AppCurves.spring,
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox(
          width: isFirstPage ? 0 : slotWidth,
          child: IgnorePointer(
            ignoring: isFirstPage,
            child: ExcludeSemantics(
              excluding: isFirstPage,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: TapScale(
                  onTap: onBack,
                  child: SizedBox.square(
                    key: OnboardingLayoutKeys.backButton,
                    dimension: buttonHeight,
                    child: AppButton.icon(
                      variant: AppButtonVariant.text,
                      icon: const Icon(Icons.chevron_left),
                      mirrorInRtl: true,
                      semanticLabel: label,
                      onPressed: onBack,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.isLastPage,
    required this.onPressed,
    required this.nextLabel,
    required this.getStartedLabel,
    required this.semanticsLabelNext,
    required this.semanticsLabelGetStarted,
    required this.colors,
    required this.buttonHeight,
  });

  final bool isLastPage;
  final VoidCallback onPressed;
  final String nextLabel;
  final String getStartedLabel;
  final String semanticsLabelNext;
  final String semanticsLabelGetStarted;
  final AppColorsExtension colors;
  final double buttonHeight;

  @override
  Widget build(BuildContext context) {
    return ProgressDriver(
      duration: OnboardingAnimationTimings.buttonMorph,
      active: isLastPage,
      mode: ProgressDriverMode.toggle,
      builder: (context, p, _) {
        final isGetStarted = p > 0.5;

        // Label crossfade
        final nextOpacity = 1.0 - p;
        final getStartedOpacity = p;

        // Icon transition
        final iconRotation = p * 0.5; // slight rotation

        return Semantics(
          label: isGetStarted ? semanticsLabelGetStarted : semanticsLabelNext,
          button: true,
          child: TapScale(
            onTap: () {
              if (isLastPage) {
                AppHaptics.medium();
              }
              onPressed();
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Layout-driven morph: compact fraction of the remaining
                // row width on slides 1–3, full width on the last slide.
                final eased = AppCurves.spring.transform(p);
                final compactFactor = OnboardingLayout.compactNextWidthFactor(
                  constraints.maxWidth,
                );
                final widthFactor = lerpDouble(compactFactor, 1.0, eased)!;
                final labelSlide =
                    OnboardingLayoutRatios.nextLabelSlideOfButtonHeight *
                    buttonHeight;

                return FractionallySizedBox(
                  widthFactor: widthFactor,
                  alignment: AlignmentDirectional.centerEnd,
                  child: SizedBox(
                    height: buttonHeight,
                    child: AppButton.content(
                      key: OnboardingLayoutKeys.nextButton,
                      variant: AppButtonVariant.filled,
                      cornerRadius: BorderRadius.circular(AppRadius.md),
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      onPressed: onPressed,
                      content: Stack(
                        alignment: Alignment.center,
                        children: [
                          // "Next" label (fades out)
                          Opacity(
                            opacity: nextOpacity,
                            child: Transform.translate(
                              offset: Offset(-labelSlide * p, 0),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      nextLabel,
                                      style: context.textStyles.labelLarge
                                          .copyWith(color: colors.onPrimary),
                                    ),
                                    SizedBox(width: AppSpacing.sm),
                                    Transform.rotate(
                                      angle: iconRotation,
                                      child: Icon(
                                        Icons.chevron_right,
                                        size: OnboardingLayout.nextIconSize,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // "Get started" label (fades in)
                          Opacity(
                            opacity: getStartedOpacity,
                            child: Transform.translate(
                              offset: Offset(labelSlide * (1 - p), 0),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      getStartedLabel,
                                      style: context.textStyles.labelLarge
                                          .copyWith(color: colors.onPrimary),
                                    ),
                                    SizedBox(width: AppSpacing.sm),
                                    Transform.rotate(
                                      angle: 0.5 - iconRotation,
                                      child: Icon(
                                        Icons.check,
                                        size: OnboardingLayout.nextIconSize,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}
