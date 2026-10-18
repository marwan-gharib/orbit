import 'package:flutter/material.dart';
// intl also defines a `TextDirection` class that would shadow dart:ui's.
import 'package:intl/intl.dart' hide TextDirection;

import 'package:orbit/core/constants/assets.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/features/onboarding/presentation/constants/onboarding_illustration_constants.dart';
import 'package:orbit/features/onboarding/presentation/widgets/illustrations/illustration_motion.dart';
import 'package:orbit/features/onboarding/presentation/widgets/illustrations/layered_illustration.dart';

/// Illustration for Slide 3: Finance — a won deal flows into a finished
/// project along a curved path, and a profit number counts up below. The
/// artwork is the layered SVG set (`assets/svgs/onboarding/slide_3_finance`);
/// the number is a Flutter text slot, since numbers are not part of the SVGs.
class Slide3FinanceIllustration extends StatelessWidget {
  const Slide3FinanceIllustration({
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
          ? OnboardingIllustrationFit.s3ContentBounds
          : null,
      regionSize: regionSize,
      layers: [
        const SvgLayer(
          layerKey: OnboardingIllustrationKeys.s3DealCard,
          asset: OnboardingSvgs.s3DealCard,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s3DealCardBegin,
            end: OnboardingIllustrationMotion.s3DealCardEnd,
            from: Offset(OnboardingIllustrationMotion.s3DealCardFromX, 0.02),
            fromDegrees: OnboardingIllustrationMotion.s3DealCardFromDegrees,
            fromScale: OnboardingIllustrationMotion.s3DealCardFromScale,
            pivot: OnboardingIllustrationMotion.s3DealCardPivot,
          ),
        ),
        const SvgLayer(
          layerKey: OnboardingIllustrationKeys.s3ProjectCard,
          asset: OnboardingSvgs.s3ProjectCard,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s3ProjectCardBegin,
            end: OnboardingIllustrationMotion.s3ProjectCardEnd,
            from: OnboardingIllustrationMotion.s3ProjectCardFrom,
            fromDegrees: OnboardingIllustrationMotion.s3ProjectCardFromDegrees,
            fromScale: OnboardingIllustrationMotion.s3ProjectCardFromScale,
            pivot: OnboardingIllustrationMotion.s3ProjectCardPivot,
            overshoot: true,
          ),
        ),
        const SvgLayer(
          layerKey: OnboardingIllustrationKeys.s3Connector,
          asset: OnboardingSvgs.s3Connector,
          entrance: FadeInMotion(
            begin: OnboardingIllustrationMotion.s3ConnectorBegin,
            end: OnboardingIllustrationMotion.s3ConnectorEnd,
          ),
        ),
        const SvgLayer(
          layerKey: OnboardingIllustrationKeys.s3FlowDot,
          asset: OnboardingSvgs.s3FlowDot,
          entrance: BezierTravelMotion(
            begin: OnboardingIllustrationMotion.s3FlowDotInBegin,
            end: OnboardingIllustrationMotion.s3FlowDotInEnd,
            outBegin: OnboardingIllustrationMotion.s3FlowDotOutBegin,
            outEnd: OnboardingIllustrationMotion.s3FlowDotOutEnd,
            p0: OnboardingIllustrationMotion.s3FlowDotP0,
            p1: OnboardingIllustrationMotion.s3FlowDotP1,
            p2: OnboardingIllustrationMotion.s3FlowDotP2,
            p3: OnboardingIllustrationMotion.s3FlowDotP3,
          ),
          idle: TravelLoopIdle(
            period: OnboardingIllustrationMotion.s3FlowDotIdlePeriod,
            pauseFraction:
                OnboardingIllustrationMotion.s3FlowDotIdlePauseFraction,
            fadeFraction:
                OnboardingIllustrationMotion.s3FlowDotIdleFadeFraction,
            p0: OnboardingIllustrationMotion.s3FlowDotP0,
            p1: OnboardingIllustrationMotion.s3FlowDotP1,
            p2: OnboardingIllustrationMotion.s3FlowDotP2,
            p3: OnboardingIllustrationMotion.s3FlowDotP3,
          ),
        ),
        const SvgLayer(
          layerKey: OnboardingIllustrationKeys.s3TrendBadge,
          asset: OnboardingSvgs.s3TrendBadge,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s3TrendBadgeBegin,
            end: OnboardingIllustrationMotion.s3TrendBadgeEnd,
            from: OnboardingIllustrationMotion.s3TrendBadgeFrom,
            fromDegrees: OnboardingIllustrationMotion.s3TrendBadgeFromDegrees,
            fromScale: OnboardingIllustrationMotion.s3TrendBadgeFromScale,
            pivot: OnboardingIllustrationMotion.s3TrendBadgePivot,
            overshoot: true,
          ),
          idle: FloatIdle(
            period: OnboardingIllustrationMotion.s3TrendBadgeFloatPeriod,
            amplitudeOfSide:
                OnboardingIllustrationMotion.s3TrendBadgeFloatAmplitudeOfSide,
          ),
        ),
        const SvgLayer(
          layerKey: OnboardingIllustrationKeys.s3LabelPill,
          asset: OnboardingSvgs.s3LabelPill,
          entrance: AssemblyMotion(
            begin: OnboardingIllustrationMotion.s3LabelPillBegin,
            end: OnboardingIllustrationMotion.s3LabelPillEnd,
            from: OnboardingIllustrationMotion.s3LabelPillFrom,
            fromDegrees: 0,
            fromScale: OnboardingIllustrationMotion.s3LabelPillFromScale,
            pivot: OnboardingIllustrationMotion.s3LabelPillPivot,
          ),
        ),
        TextLayer(
          layerKey: OnboardingIllustrationKeys.s3ProfitText,
          rect: OnboardingIllustrationText.profitRect,
          entrance: const FadeInMotion(
            begin: OnboardingIllustrationMotion.s3ProfitTextBegin,
            end: OnboardingIllustrationMotion.s3ProfitTextEnd,
          ),
          builder: (context, eased, side) {
            final locale = Localizations.localeOf(context).toString();
            final amount = NumberFormat.compact(locale: locale).format(
              (OnboardingIllustrationText.profitCountTarget * eased).round(),
            );
            return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                context.t.onboarding.illustration.profitNumber(amount: amount),
                maxLines: 1,
                style: context.textStyles.titleLarge.copyWith(
                  color: context.colors.textSecondary,
                  fontSize: OnboardingIllustrationText.profitFontOfSide * side,
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
