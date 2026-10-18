import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/features/onboarding/presentation/constants/onboarding_illustration_constants.dart';
import 'package:orbit/features/onboarding/presentation/constants/onboarding_layout_constants.dart';
import 'package:orbit/features/onboarding/presentation/cubit/onboarding_constants.dart';
import 'package:orbit/features/onboarding/presentation/view_models/onboarding_page_view_model.dart';
import 'package:orbit/features/onboarding/presentation/widgets/illustrations/onboarding_illustration_factory.dart';

/// Single onboarding page with illustration, headline, and body text.
/// Handles its own entrance choreography driven by [progress] and [isActive].
/// The illustration lives in a bounded square that shrinks under text
/// pressure; the text keeps its natural height (UI-6).
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    required this.page,
    required this.progress,
    required this.isActive,
    required this.layout,
    super.key,
  });

  final OnboardingPageViewModel page;

  /// 0.0..1.0 entrance progress driven by the screen's master timeline; the
  /// headline and body read it directly.
  final double progress;

  /// Whether this is the center page; it owns the illustration replay.
  final bool isActive;

  final OnboardingLayout layout;

  Rect? _illustrationContentBounds(OnboardingIllustrationType type) =>
      switch (type) {
        OnboardingIllustrationType.projects =>
          OnboardingIllustrationFit.s1ContentBounds,
        OnboardingIllustrationType.finance =>
          OnboardingIllustrationFit.s3ContentBounds,
        OnboardingIllustrationType.people ||
        OnboardingIllustrationType.insights => null,
      };

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final textStyles = context.textStyles;
    final colors = context.colors;

    // Entrance progress for each element (timed per spec).
    final p = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Illustration region absorbs any layout pressure; bounded by the
        // region the text leaves over, so it can never cover the headline
        // or body. Slides 1 and 3 fit the region to their settled content
        // instead of the full 400x400 canvas.
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentBounds = _illustrationContentBounds(
                page.illustrationType,
              );
              final double canvasSide;
              final Size? regionSize;
              if (contentBounds != null) {
                final aspect = contentBounds.width / contentBounds.height;
                var width = math.min(
                  constraints.maxWidth,
                  OnboardingLayout.maxIllustrationSide,
                );
                var height = width / aspect;
                if (height > constraints.maxHeight) {
                  height = constraints.maxHeight;
                  width = height * aspect;
                }
                regionSize = Size(width, height);
                canvasSide = width / contentBounds.width;
              } else {
                canvasSide = layout.illustrationSide(
                  maxWidth: constraints.maxWidth,
                  maxHeight: constraints.maxHeight,
                );
                regionSize = null;
              }

              return Center(
                child: SizedBox(
                  key: OnboardingLayoutKeys.illustration,
                  width: regionSize?.width ?? canvasSide,
                  height: regionSize?.height ?? canvasSide,
                  child: ProgressDriver(
                    duration:
                        OnboardingAnimationTimings.illustrationEntranceDuration,
                    delayFraction: OnboardingAnimationTimings
                        .illustrationEntranceDelayFraction,
                    active: isActive,
                    builder: (context, progress, child) => createIllustration(
                      type: page.illustrationType,
                      progress: progress,
                      isActive: isActive,
                      size: Size.square(canvasSide),
                      regionSize: regionSize,
                    ),
                    child: const SizedBox.shrink(),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: layout.illustrationToTextGap),

        // Headline — masked slide-up + fade
        FadeSlideIn(
          delay: Duration.zero,
          duration: OnboardingAnimationTimings.headlineReveal,
          curve: OnboardingAnimationTimings.entranceCurve,
          offset: AppAnimationConstants.slideFromBottom * 0.5,
          child: Opacity(
            opacity: p,
            child: Transform.translate(
              offset: Offset(
                0,
                layout.headlineSlide * (1 - AppCurves.enter.transform(p)),
              ),
              child: Text(
                page.headline,
                key: OnboardingLayoutKeys.headline,
                style: textStyles.headlineMedium.copyWith(
                  color: colors.textPrimary,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                semanticsLabel: t.onboarding.a11y.pageIndicator(
                  current: page.id + 1,
                  total: 4,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: layout.textGap),

        // Body — fade + slide up
        FadeSlideIn(
          delay: Duration.zero,
          duration: OnboardingAnimationTimings.bodyReveal,
          curve: OnboardingAnimationTimings.entranceCurve,
          offset: AppAnimationConstants.slideFromBottom * 0.4,
          child: Opacity(
            opacity: p,
            child: Transform.translate(
              offset: Offset(
                0,
                layout.bodySlide * (1 - AppCurves.enter.transform(p)),
              ),
              child: Text(
                page.body,
                key: OnboardingLayoutKeys.body,
                style: textStyles.bodyLarge.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
