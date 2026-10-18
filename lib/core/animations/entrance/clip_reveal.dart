import 'package:flutter/widgets.dart';

import '../tokens/app_curves.dart';

/// Reveals [child] left to right (LTR space; mirror the parent stack for
/// RTL) by clipping horizontally from [fromX] to [toX] as [progress] grows
/// over its [begin]/[end] window.
///
/// Purely progress-driven — no controller inside. The caller supplies the
/// window and the current progress; rebuilds redraw the frame. The window is
/// eased by [curve] before mapping onto [fromX]/[toX].
///
/// ```dart
/// ClipReveal(
///   progress: state.entranceProgress,
///   begin: 0.5,
///   end: 0.85,
///   fromX: 0.13,
///   toX: 0.87,
///   child: const TrendLine(),
/// )
/// ```
class ClipReveal extends StatelessWidget {
  const ClipReveal({
    super.key,
    required this.progress,
    required this.begin,
    required this.end,
    required this.fromX,
    required this.toX,
    this.curve = AppCurves.enter,
    required this.child,
  }) : assert(begin <= end),
       assert(fromX <= toX);

  /// Current entrance progress; fully revealed at 1.
  final double progress;

  /// Window in progress: fully clipped before [begin], complete at [end].
  final double begin;
  final double end;

  /// Left reveal edge at the window's start, as a fraction of the width.
  final double fromX;

  /// Left reveal edge at the window's end, as a fraction of the width.
  final double toX;

  /// Easing applied inside the window.
  final Curve curve;

  /// The subtree the reveal opens.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final eased = curve.transform(
      ((progress - begin) / (end - begin)).clamp(0.0, 1.0),
    );
    return ClipRect(
      clipper: _HorizontalRevealClipper(
        progress: eased,
        fromX: fromX,
        toX: toX,
      ),
      child: child,
    );
  }
}

class _HorizontalRevealClipper extends CustomClipper<Rect> {
  const _HorizontalRevealClipper({
    required this.progress,
    required this.fromX,
    required this.toX,
  });

  final double progress;
  final double fromX;
  final double toX;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(
    0,
    0,
    (fromX + (toX - fromX) * progress) * size.width,
    size.height,
  );

  @override
  bool shouldReclip(covariant _HorizontalRevealClipper old) =>
      old.progress != progress || old.fromX != fromX || old.toX != toX;
}
