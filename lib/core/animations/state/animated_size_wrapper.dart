import 'package:flutter/widgets.dart';

import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';

/// Animates its own size whenever [child] grows or shrinks, so an inline
/// change never snaps.
///
/// ```dart
/// AnimatedSizeWrapper(
///   child: showDetails ? const DetailsPanel() : const SizedBox.shrink(),
/// )
/// ```
///
/// [alignment] is an [AlignmentGeometry]: pass an [AlignmentDirectional]
/// (e.g. `AlignmentDirectional.topStart`) to keep a shrinking child anchored
/// to the reading start in RTL. When `MediaQuery.disableAnimations` is true
/// the new size applies immediately.
class AnimatedSizeWrapper extends StatelessWidget {
  const AnimatedSizeWrapper({
    super.key,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.standard,
    this.alignment = Alignment.center,
    required this.child,
  });

  /// How long a resize takes.
  final Duration duration;

  /// Easing of the resize.
  final Curve curve;

  /// Where [child] sits while the wrapper has not caught up with its size.
  final AlignmentGeometry alignment;

  /// The subtree whose size changes are animated.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }
    return AnimatedSize(
      duration: duration,
      curve: curve,
      alignment: alignment,
      child: child,
    );
  }
}
