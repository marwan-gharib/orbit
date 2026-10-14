import 'package:flutter/widgets.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';
import 'entrance.dart';

/// Fades and slides [child] in together — the default entrance for cards and
/// list items. Plays once, on its first build; rebuilds do not replay it.
///
/// [delay], [duration] and [curve] behave as in [Entrance]; [offset] sets the
/// slide distance as a fraction of the child's size.
///
/// ```dart
/// FadeSlideIn(
///   child: const Card(child: Text('Revenue')),
/// )
///
/// // In a list, keep it snappy and let the staggered group add the delay:
/// FadeSlideIn(
///   delay: AppDurations.stagger * index,
///   duration: AppDurations.fast,
///   child: const ListTile(title: Text('Invoice 42')),
/// )
/// ```
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    this.delay = Duration.zero,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.enter,
    this.offset = AppAnimationConstants.slideFromBottom,
    required this.child,
  });

  /// Hold time before the entrance starts.
  final Duration delay;

  /// Length of the entrance, excluding [delay].
  final Duration duration;

  /// Easing applied to both the fade and the slide.
  final Curve curve;

  /// Begin offset as a fraction of the child's size.
  final Offset offset;

  /// The subtree that fades and slides in; never rebuilt by the animation.
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
      child: SlideTransition(
        position: drive.drive(Tween<Offset>(begin: offset, end: Offset.zero)),
        child: child,
      ),
    ),
    child: child,
  );
}
