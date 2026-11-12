import 'package:flutter/material.dart';
import 'package:orbit/core/animations/state/animated_counter.dart';
import 'package:orbit/core/animations/state/progress_driver.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/progress_ring.dart';

import '../constants/dashboard_layout_constants.dart';

/// A progress ring that sweeps from 0 with its percentage counting up.
/// [fraction] is 0..1.
class DashboardRing extends StatelessWidget {
  const DashboardRing({
    super.key,
    required this.fraction,
    required this.color,
  });

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = DashboardLayoutConstants.heroRingSize;
    final target = fraction.clamp(0.0, 1.0);

    return ProgressDriver(
      duration: AppDurations.extraSlow,
      active: true,
      builder: (context, progress, _) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ProgressRing(
              size: size,
              progress: target * AppCurves.standard.transform(progress),
              strokeWidth: DashboardLayoutConstants.heroRingStroke,
              trackColor: colors.surfaceContainerHighest,
              progressColor: color,
            ),
            AnimatedCounter(
              value: target * 100,
              progress: progress,
              formatter: (n) => '${n.round()}%',
              style: context.textStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
      child: const SizedBox.shrink(),
    );
  }
}
