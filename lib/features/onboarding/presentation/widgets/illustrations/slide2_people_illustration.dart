import 'package:flutter/widgets.dart';

import 'package:orbit/core/constants/assets.dart';
import 'package:orbit/features/onboarding/presentation/constants/onboarding_illustration_constants.dart';
import 'package:orbit/features/onboarding/presentation/widgets/illustrations/illustration_motion.dart';
import 'package:orbit/features/onboarding/presentation/widgets/illustrations/layered_illustration.dart';

/// Illustration for Slide 2: People — check-in button with radar pulse rings
/// and a leave request that moves from pending to approved with a stamp. The
/// layers are the SVG set from `assets/svgs/onboarding/slide_2_people`.
class Slide2PeopleIllustration extends StatelessWidget {
  const Slide2PeopleIllustration({
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
          layerKey: OnboardingIllustrationKeys.s2PulseRingA,
          asset: OnboardingSvgs.s2PulseRing,
          entrance: HiddenEntranceMotion(),
          idle: PulseIdle(
            period: OnboardingIllustrationMotion.s2PulseIdlePeriod,
            scaleTo: OnboardingIllustrationMotion.s2PulseIdleScaleTo,
            pivot: OnboardingIllustrationMotion.s2ButtonPivot,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s2PulseRingB,
          asset: OnboardingSvgs.s2PulseRing,
          entrance: HiddenEntranceMotion(),
          idle: PulseIdle(
            period: OnboardingIllustrationMotion.s2PulseIdlePeriod,
            scaleTo: OnboardingIllustrationMotion.s2PulseIdleScaleTo,
            pivot: OnboardingIllustrationMotion.s2ButtonPivot,
            phaseOffset: OnboardingIllustrationMotion.s2PulseIdleSecondPhase,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s2CheckinButton,
          asset: OnboardingSvgs.s2CheckinButton,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s2CheckinBegin,
            end: OnboardingIllustrationMotion.s2CheckinEnd,
            from: OnboardingIllustrationMotion.s2CheckinFrom,
            fromDegrees: 0,
            fromScale: OnboardingIllustrationMotion.s2CheckinFromScale,
            pivot: OnboardingIllustrationMotion.s2ButtonPivot,
            overshoot: true,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s2IconClock,
          asset: OnboardingSvgs.s2IconClock,
          entrance: CrossfadeMotion(
            begin: OnboardingIllustrationMotion.s2ClockInBegin,
            end: OnboardingIllustrationMotion.s2ClockInEnd,
            outBegin: OnboardingIllustrationMotion.s2ClockOutBegin,
            outEnd: OnboardingIllustrationMotion.s2ClockOutEnd,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s2IconCheck,
          asset: OnboardingSvgs.s2IconCheck,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s2CheckInBegin,
            end: OnboardingIllustrationMotion.s2CheckInEnd,
            from: Offset.zero,
            fromDegrees: 0,
            fromScale: OnboardingIllustrationMotion.s2CheckFromScale,
            pivot: OnboardingIllustrationMotion.s2CheckPivot,
            overshoot: true,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s2CardBg,
          asset: OnboardingSvgs.s2CardBg,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s2CardBgBegin,
            end: OnboardingIllustrationMotion.s2CardBgEnd,
            from: OnboardingIllustrationMotion.s2CardBgFrom,
            fromDegrees: 0,
            fromScale: OnboardingIllustrationMotion.s2CardBgFromScale,
            pivot: OnboardingIllustrationMotion.s2CardBgPivot,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s2Avatar,
          asset: OnboardingSvgs.s2Avatar,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s2AvatarBegin,
            end: OnboardingIllustrationMotion.s2AvatarEnd,
            from: OnboardingIllustrationMotion.s2AvatarFrom,
            fromDegrees: OnboardingIllustrationMotion.s2AvatarFromDegrees,
            fromScale: OnboardingIllustrationMotion.s2AvatarFromScale,
            pivot: OnboardingIllustrationMotion.s2AvatarPivot,
            overshoot: true,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s2Lines,
          asset: OnboardingSvgs.s2Lines,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s2LinesBegin,
            end: OnboardingIllustrationMotion.s2LinesEnd,
            from: OnboardingIllustrationMotion.s2LinesFrom,
            fromDegrees: 0,
            fromScale: OnboardingIllustrationMotion.s2LinesFromScale,
            pivot: OnboardingIllustrationMotion.s2LinesPivot,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s2PillPending,
          asset: OnboardingSvgs.s2PillPending,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s2PillPendingInBegin,
            end: OnboardingIllustrationMotion.s2PillPendingInEnd,
            from: OnboardingIllustrationMotion.s2PillPendingFrom,
            fromDegrees: 0,
            fromScale: OnboardingIllustrationMotion.s2PillPendingFromScale,
            pivot: OnboardingIllustrationMotion.s2PillPivot,
            outBegin: OnboardingIllustrationMotion.s2PillPendingOutBegin,
            outEnd: OnboardingIllustrationMotion.s2PillPendingOutEnd,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s2PillApproved,
          asset: OnboardingSvgs.s2PillApproved,
          entrance: FadeInMotion(
            begin: OnboardingIllustrationMotion.s2PillApprovedBegin,
            end: OnboardingIllustrationMotion.s2PillApprovedEnd,
          ),
        ),
        SvgLayer(
          layerKey: OnboardingIllustrationKeys.s2Stamp,
          asset: OnboardingSvgs.s2Stamp,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s2StampBegin,
            end: OnboardingIllustrationMotion.s2StampEnd,
            from: OnboardingIllustrationMotion.s2StampFrom,
            fromDegrees: OnboardingIllustrationMotion.s2StampFromDegrees,
            fromScale: OnboardingIllustrationMotion.s2StampFromScale,
            pivot: OnboardingIllustrationMotion.s2StampPivot,
            overshoot: true,
            opacityEnd: OnboardingIllustrationMotion.s2StampOpacityEnd,
          ),
        ),
      ],
    );
  }
}
