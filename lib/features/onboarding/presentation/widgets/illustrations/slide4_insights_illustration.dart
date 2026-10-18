import 'package:flutter/widgets.dart';

import 'package:orbit/core/constants/assets.dart';
import 'package:orbit/features/onboarding/presentation/constants/onboarding_illustration_constants.dart';
import 'package:orbit/features/onboarding/presentation/widgets/illustrations/illustration_motion.dart';
import 'package:orbit/features/onboarding/presentation/widgets/illustrations/layered_illustration.dart';

/// Illustration for Slide 4: Insights — dashboard frame with bars growing
/// from the baseline, a trend line revealed left to right, and a pulsing risk
/// alert. The layers are the SVG set from
/// `assets/svgs/onboarding/slide_4_insights`.
class Slide4InsightsIllustration extends StatelessWidget {
  const Slide4InsightsIllustration({
    required this.progress,
    required this.isActive,
    required this.size,
    super.key,
  });

  final double progress;
  final bool isActive;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return LayeredIllustration(
      progress: progress,
      isActive: isActive,
      size: size,
      layers: const [
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s4Frame,
          asset: OnboardingSvgs.s4Frame,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s4FrameBegin,
            end: OnboardingIllustrationMotion.s4FrameEnd,
            from: OnboardingIllustrationMotion.s4FrameFrom,
            fromDegrees: 0,
            fromScale: OnboardingIllustrationMotion.s4FrameFromScale,
            pivot: OnboardingIllustrationMotion.s4FramePivot,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s4Bar1,
          asset: OnboardingSvgs.s4Bar1,
          entrance: FadeScaleYMotion(
            begin: OnboardingIllustrationMotion.s4Bar1Begin,
            end: OnboardingIllustrationMotion.s4Bar1End,
            pivot: OnboardingIllustrationMotion.barPivot,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s4Bar2,
          asset: OnboardingSvgs.s4Bar2,
          entrance: FadeScaleYMotion(
            begin: OnboardingIllustrationMotion.s4Bar2Begin,
            end: OnboardingIllustrationMotion.s4Bar2End,
            pivot: OnboardingIllustrationMotion.barPivot,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s4Bar3,
          asset: OnboardingSvgs.s4Bar3,
          entrance: FadeScaleYMotion(
            begin: OnboardingIllustrationMotion.s4Bar3Begin,
            end: OnboardingIllustrationMotion.s4Bar3End,
            pivot: OnboardingIllustrationMotion.barPivot,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s4Bar4,
          asset: OnboardingSvgs.s4Bar4,
          entrance: FadeScaleYMotion(
            begin: OnboardingIllustrationMotion.s4Bar4Begin,
            end: OnboardingIllustrationMotion.s4Bar4End,
            pivot: OnboardingIllustrationMotion.barPivot,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s4Bar5,
          asset: OnboardingSvgs.s4Bar5,
          entrance: FadeScaleYMotion(
            begin: OnboardingIllustrationMotion.s4Bar5Begin,
            end: OnboardingIllustrationMotion.s4Bar5End,
            pivot: OnboardingIllustrationMotion.barPivot,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s4Line,
          asset: OnboardingSvgs.s4Line,
          entrance: ClipRevealMotion(
            begin: OnboardingIllustrationMotion.s4LineRevealBegin,
            end: OnboardingIllustrationMotion.s4LineRevealEnd,
            fromX: OnboardingIllustrationMotion.s4LineRevealFromX,
            toX: OnboardingIllustrationMotion.s4LineRevealToX,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s4LineDots,
          asset: OnboardingSvgs.s4LineDots,
          entrance: ClipRevealMotion(
            begin: OnboardingIllustrationMotion.s4LineRevealBegin,
            end: OnboardingIllustrationMotion.s4LineRevealEnd,
            fromX: OnboardingIllustrationMotion.s4LineRevealFromX,
            toX: OnboardingIllustrationMotion.s4LineRevealToX,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s4AlertPulse,
          asset: OnboardingSvgs.s4AlertPulse,
          entrance: HiddenEntranceMotion(),
          idle: PulseIdle(
            period: OnboardingIllustrationMotion.s4AlertPulseIdlePeriod,
            scaleTo: OnboardingIllustrationMotion.s4AlertPulseIdleScaleTo,
            pivot: OnboardingIllustrationMotion.s4AlertBadgePivot,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s4AlertBadge,
          asset: OnboardingSvgs.s4AlertBadge,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s4AlertBadgeBegin,
            end: OnboardingIllustrationMotion.s4AlertBadgeEnd,
            from: OnboardingIllustrationMotion.s4AlertBadgeFrom,
            fromDegrees: OnboardingIllustrationMotion.s4AlertBadgeFromDegrees,
            fromScale: OnboardingIllustrationMotion.s4AlertBadgeFromScale,
            pivot: OnboardingIllustrationMotion.s4AlertBadgePivot,
            overshoot: true,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s4Legend,
          asset: OnboardingSvgs.s4Legend,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s4LegendBegin,
            end: OnboardingIllustrationMotion.s4LegendEnd,
            from: OnboardingIllustrationMotion.s4LegendFrom,
            fromDegrees: 0,
            fromScale: OnboardingIllustrationMotion.s4LegendFromScale,
            pivot: OnboardingIllustrationMotion.s4LegendPivot,
          ),
        ),
      ],
    );
  }
}
