import 'package:flutter/widgets.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';
import 'entrance.dart';

/// Zooms [child] in with a subtle scale, once, on its first build; rebuilds
/// do not replay it.
///
/// [delay], [duration] and [curve] behave as in [Entrance].
///
/// ```dart
/// ScaleIn(
///   duration: AppDurations.fast,
///   child: const Icon(Icons.check_circle_outline),
/// )
/// ```
class ScaleIn extends StatelessWidget {
  const ScaleIn({
    super.key,
    this.delay = Duration.zero,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.enter,
    required this.child,
  });

  /// Hold time before the zoom starts.
  final Duration delay;

  /// Length of the zoom, excluding [delay].
  final Duration duration;

  /// Easing of the zoom.
  final Curve curve;

  /// The subtree that zooms in; never rebuilt by the animation.
  final Widget child;

  @override
  Widget build(BuildContext context) => Entrance(
    delay: delay,
    duration: duration,
    curve: curve,
    transition: (context, drive, child) => ScaleTransition(
      scale: drive.drive(
        Tween<double>(
          begin: AppAnimationConstants.scaleInBegin,
          end: AppAnimationConstants.scaleInEnd,
        ),
      ),
      child: child,
    ),
    child: child,
  );
}
