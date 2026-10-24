import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';

import '../../domain/enums/employment_status.dart';
import '../constants/auth_layout_constants.dart';
import '../mappers/employment_status_view.dart';

/// Orbit artwork for the pending-approval screen: a ring, a centre badge that
/// reflects the current status, and a dot orbiting the ring while the account
/// is still waiting.
///
/// Motion contract (ANIM-2):
/// - trigger: mounted while [status] is not terminal and [active] is true;
/// - period/curve: `AppDurations.indeterminate` (1200 ms), `AppCurves.linear`,
///   repeating forward (one full turn per period);
/// - reduced motion: `IdleLoop` never starts and holds the settled frame (dot
///   at the top of the ring);
/// - rebuild isolation: the animated subtree is passed to `IdleLoop` as its
///   `child`, so ticks only rebuild the rotation transform, never the artwork;
/// - lifecycle: the ticker stops when the route is disposed or the app is in
///   the background (Flutter pauses frames).
class PendingHero extends StatelessWidget {
  const PendingHero({required this.status, this.active = true, super.key});

  /// Status that tints the ring, badge and icon.
  final EmploymentStatus status;

  /// Whether the orbit may run; the screen turns this off for a terminal
  /// moment.
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = switch (status) {
      EmploymentStatus.approved => colors.success,
      EmploymentStatus.rejected => colors.error,
      EmploymentStatus.pending || EmploymentStatus.unknown => colors.primary,
    };
    final icon = switch (status) {
      EmploymentStatus.approved => Icons.check_rounded,
      EmploymentStatus.rejected => Icons.close_rounded,
      EmploymentStatus.unknown => Icons.visibility_outlined,
      EmploymentStatus.pending => Icons.hourglass_top_rounded,
    };

    return Semantics(
      image: true,
      label: context.t.auth.pending.a11y.hero,
      child: ExcludeSemantics(
        child: SizedBox(
          width: AuthLayout.heroSize,
          height: AuthLayout.heroSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: AuthLayout.heroRingOpacity),
                    width: AuthLayout.heroRingStroke,
                  ),
                ),
              ),
              IdleLoop(
                active: active && !status.isTerminal,
                period: AppDurations.indeterminate,
                curve: AppCurves.linear,
                phaseBuilder: (context, phase, child) =>
                    Transform.rotate(angle: phase * 2 * math.pi, child: child),
                child: SizedBox(
                  width: AuthLayout.heroSize,
                  height: AuthLayout.heroSize,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: AuthLayout.heroDotSize,
                      height: AuthLayout.heroDotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: AuthLayout.heroCenterSize,
                height: AuthLayout.heroCenterSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(
                    alpha: AuthLayout.heroCenterFillOpacity,
                  ),
                ),
                child: Icon(
                  icon,
                  size: AuthLayout.heroCenterIconSize,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
