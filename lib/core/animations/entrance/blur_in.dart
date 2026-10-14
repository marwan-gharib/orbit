import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';
import 'entrance.dart';

/// Resolves [child] from blurred to sharp, once, on its first build — the
/// entrance for dialog and overlay content. Rebuilds do not replay it.
///
/// [delay], [duration] and [curve] behave as in [Entrance]. Once sharp, the
/// filter is dropped so the steady state costs nothing.
///
/// ```dart
/// BlurIn(
///   child: const AlertDialog(content: Text('Delete project?')),
/// )
/// ```
class BlurIn extends StatelessWidget {
  const BlurIn({
    super.key,
    this.delay = Duration.zero,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.enter,
    required this.child,
  });

  /// Hold time before the focus pull starts.
  final Duration delay;

  /// Length of the focus pull, excluding [delay].
  final Duration duration;

  /// Easing of the focus pull.
  final Curve curve;

  /// The subtree that resolves from blurred to sharp.
  final Widget child;

  @override
  Widget build(BuildContext context) => Entrance(
    delay: delay,
    duration: duration,
    curve: curve,
    transition: (context, drive, child) {
      double sigmaAt(double progress) =>
          AppAnimationConstants.blurSigma * (1.0 - progress);
      return RepaintBoundary(
        child: AnimatedBuilder(
          animation: drive,
          builder: (context, _) {
            final sigma = sigmaAt(drive.value);
            if (sigma <= 0.0) return child;
            return ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: child,
            );
          },
        ),
      );
    },
    child: child,
  );
}
