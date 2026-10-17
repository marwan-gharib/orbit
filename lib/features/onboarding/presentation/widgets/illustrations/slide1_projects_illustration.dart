import 'package:flutter/material.dart';
// intl also defines a `TextDirection` class that would shadow dart:ui's.
import 'package:intl/intl.dart' hide TextDirection;

import 'package:orbit/core/constants/assets.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/features/onboarding/presentation/constants/onboarding_illustration_constants.dart';
import 'package:orbit/features/onboarding/presentation/widgets/illustrations/illustration_motion.dart';
import 'package:orbit/features/onboarding/presentation/widgets/illustrations/layered_illustration.dart';

/// Illustration for Slide 1: Projects — Kanban board with staggered task
/// cards, a card moving between columns, and a health ring at 75%. The
/// artwork is the layered SVG set (`assets/svgs/onboarding/slide_1_projects`);
/// the percent number is a Flutter text slot, since numbers are not part of
/// the SVGs.
class Slide1ProjectsIllustration extends StatelessWidget {
  const Slide1ProjectsIllustration({
    required this.progress,
    required this.isActive,
    required this.size,
    this.regionSize,
    super.key,
  });

  final double progress;
  final bool isActive;
  final Size size;
  final Size? regionSize;

  @override
  Widget build(BuildContext context) {
    return LayeredIllustration(
      progress: progress,
      isActive: isActive,
      size: size,
      contentBounds: regionSize != null
          ? OnboardingIllustrationFit.s1ContentBounds
          : null,
      regionSize: regionSize,
      layers: [
        const SvgLayer(
          layerKey: OnboardingIllustrationKeys.s1Board,
          asset: OnboardingSvgs.s1Board,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s1BoardBegin,
            end: OnboardingIllustrationMotion.s1BoardEnd,
            from: OnboardingIllustrationMotion.s1BoardFrom,
            fromDegrees: OnboardingIllustrationMotion.s1BoardFromDegrees,
            fromScale: OnboardingIllustrationMotion.s1BoardFromScale,
            pivot: OnboardingIllustrationMotion.s1BoardPivot,
          ),
        ),
        const SvgLayer(
          layerKey: OnboardingIllustrationKeys.s1CardA,
          asset: OnboardingSvgs.s1CardA,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s1CardABegin,
            end: OnboardingIllustrationMotion.s1CardAEnd,
            from: OnboardingIllustrationMotion.s1CardAFrom,
            fromDegrees: OnboardingIllustrationMotion.s1CardAFromDegrees,
            fromScale: OnboardingIllustrationMotion.s1CardsFromScale,
            pivot: OnboardingIllustrationMotion.s1CardAPivot,
          ),
        ),
        const SvgLayer(
          layerKey: OnboardingIllustrationKeys.s1CardB,
          asset: OnboardingSvgs.s1CardB,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s1CardBBegin,
            end: OnboardingIllustrationMotion.s1CardBEnd,
            from: OnboardingIllustrationMotion.s1CardBFrom,
            fromDegrees: OnboardingIllustrationMotion.s1CardBFromDegrees,
            fromScale: OnboardingIllustrationMotion.s1CardsFromScale,
            pivot: OnboardingIllustrationMotion.s1CardBPivot,
          ),
        ),
        const SvgLayer(
          layerKey: OnboardingIllustrationKeys.s1CardC,
          asset: OnboardingSvgs.s1CardC,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s1CardCBegin,
            end: OnboardingIllustrationMotion.s1CardCEnd,
            from: OnboardingIllustrationMotion.s1CardCFrom,
            fromDegrees: OnboardingIllustrationMotion.s1CardCFromDegrees,
            fromScale: OnboardingIllustrationMotion.s1CardsFromScale,
            pivot: OnboardingIllustrationMotion.s1CardCPivot,
          ),
        ),
        const SvgLayer(
          layerKey: OnboardingIllustrationKeys.s1CardD,
          asset: OnboardingSvgs.s1CardD,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s1CardDBegin,
            end: OnboardingIllustrationMotion.s1CardDEnd,
            from: OnboardingIllustrationMotion.s1CardDFrom,
            fromDegrees: OnboardingIllustrationMotion.s1CardDFromDegrees,
            fromScale: OnboardingIllustrationMotion.s1CardsFromScale,
            pivot: OnboardingIllustrationMotion.s1CardDPivot,
          ),
        ),
        const SvgLayer(
          layerKey: OnboardingIllustrationKeys.s1CardMoving,
          asset: OnboardingSvgs.s1CardMoving,
          entrance: TravelRevealMotion(
            begin: OnboardingIllustrationMotion.s1CardMovingBegin,
            end: OnboardingIllustrationMotion.s1CardMovingEnd,
            from: Offset(OnboardingIllustrationMotion.s1CardMovingFromX, 0),
            fadeFraction: OnboardingIllustrationMotion.s1CardMovingFadeFraction,
            liftScale: OnboardingIllustrationMotion.s1CardMovingLiftScale,
            pivot: OnboardingIllustrationMotion.s1CardMovingPivot,
          ),
        ),
        const SvgLayer(
          layerKey: OnboardingIllustrationKeys.s1RingTrack,
          asset: OnboardingSvgs.s1RingTrack,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s1RingTrackBegin,
            end: OnboardingIllustrationMotion.s1RingTrackEnd,
            from: OnboardingIllustrationMotion.s1RingTrackFrom,
            fromDegrees: 0,
            fromScale: OnboardingIllustrationMotion.s1RingTrackFromScale,
            pivot: OnboardingIllustrationMotion.s1RingPivot,
            overshoot: true,
          ),
          idle: BreatheIdle(
            period: OnboardingIllustrationMotion.s1RingIdlePeriod,
            scaleTo: OnboardingIllustrationMotion.s1RingIdleScaleTo,
            pivot: OnboardingIllustrationMotion.s1RingPivot,
          ),
        ),
        const SvgLayer(
          layerKey: OnboardingIllustrationKeys.s1RingProgress,
          asset: OnboardingSvgs.s1RingProgress,
          entrance: SweepRevealMotion(
            begin: OnboardingIllustrationMotion.s1RingProgressBegin,
            end: OnboardingIllustrationMotion.s1RingProgressEnd,
            center: OnboardingIllustrationMotion.s1RingCenter,
            radius: OnboardingIllustrationMotion.s1RingRadiusOfSide,
            startAngleDegrees:
                OnboardingIllustrationMotion.s1RingStartAngleDegrees,
            sweepDegrees: OnboardingIllustrationMotion.s1RingSweepDegrees,
            capAngleRadians: OnboardingIllustrationMotion.s1RingCapAngleRadians,
          ),
          idle: BreatheIdle(
            period: OnboardingIllustrationMotion.s1RingIdlePeriod,
            scaleTo: OnboardingIllustrationMotion.s1RingIdleScaleTo,
            pivot: OnboardingIllustrationMotion.s1RingPivot,
          ),
        ),
        TextLayer(
          layerKey: OnboardingIllustrationKeys.s1HealthText,
          rect: OnboardingIllustrationText.healthRect,
          entrance: const FadeInMotion(
            begin: OnboardingIllustrationMotion.s1HealthTextBegin,
            end: OnboardingIllustrationMotion.s1HealthTextEnd,
          ),
          builder: (context, eased, side) {
            final percent = NumberFormat.percentPattern(
              Localizations.localeOf(context).toString(),
            ).format(OnboardingIllustrationText.healthCountTarget * eased);
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                percent,
                maxLines: 1,
                style: context.textStyles.labelLarge.copyWith(
                  color: context.colors.textSecondary,
                  fontSize: OnboardingIllustrationText.healthFontOfSide * side,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
