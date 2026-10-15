import 'package:flutter/widgets.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';
import 'entrance.dart';

/// Fades [child] in once, on its first build; rebuilds do not replay it.
///
/// [delay], [duration] and [curve] behave as in [Entrance].
///
/// ```dart
/// FadeIn(
///   delay: AppDurations.stagger,
///   child: const Text('Saved'),
/// )
/// ```
class FadeIn extends StatelessWidget {
  const FadeIn({
    super.key,
    this.delay = Duration.zero,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.enter,
    required this.child,
  });

  /// Hold time before the fade starts.
  final Duration delay;

  /// Length of the fade, excluding [delay].
  final Duration duration;

  /// Easing of the fade.
  final Curve curve;

  /// The subtree that fades in; never rebuilt by the animation.
  final Widget child;

  @override
  Widget build(BuildContext context) => Entrance(
    delay: delay,
    duration: duration,
    curve: curve,
    transition: (context, drive, child) => FadeTransition(
      opacity: drive.drive(
        Tween<double>(
          begin: AppAnimationConstants.fadeOpacityBegin,
          end: AppAnimationConstants.fadeOpacityEnd,
        ),
      ),
      child: child,
    ),
    child: child,
  );
}
