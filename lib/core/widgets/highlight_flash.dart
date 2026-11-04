import 'package:flutter/material.dart';

import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';

/// One-shot highlight behind [child], decaying to transparent.
///
/// Plays whenever [token] changes — a note id, a revision counter, any value
/// whose change means "this row just arrived or changed". A non-null token
/// also plays on the first build, so a freshly inserted row flashes without
/// the caller tracking a previous value. A null token never plays.
///
/// The color defaults to the theme's `primarySoft`; [color] overrides it for
/// callers that need another accent. With `MediaQuery.disableAnimations` the
/// highlight is skipped entirely.
///
/// ```dart
/// HighlightFlash(
///   token: note.revision,
///   borderRadius: AppRadius.borderMd,
///   child: NoteRow(note: note),
/// )
/// ```
class HighlightFlash extends StatefulWidget {
  const HighlightFlash({
    super.key,
    required this.token,
    required this.child,
    this.color,
    this.borderRadius,
  });

  /// Value whose change replays the flash; null disables it.
  final Object? token;

  /// The subtree the highlight sits behind.
  final Widget child;

  /// Highlight color; defaults to the theme's `primarySoft`.
  final Color? color;

  /// Rounded corners of the highlight wash.
  final BorderRadius? borderRadius;

  @override
  State<HighlightFlash> createState() => _HighlightFlashState();
}

class _HighlightFlashState extends State<HighlightFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _decay;
  bool _started = false;
  bool _disableAnimations = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.extraSlow,
    );
    _decay = _controller.drive(CurveTween(curve: AppCurves.exit));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (_started) return;
    _started = true;
    if (widget.token == null || _disableAnimations) {
      _controller.value = 0;
      return;
    }
    _controller.reverse(from: 1);
  }

  @override
  void didUpdateWidget(covariant HighlightFlash oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.token == oldWidget.token) return;
    if (widget.token == null || _disableAnimations) {
      _controller.value = 0;
      return;
    }
    _controller.reverse(from: 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlight = widget.color ?? context.colors.primarySoft;
    return AnimatedBuilder(
      animation: _decay,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          color: highlight.withValues(alpha: _decay.value),
          borderRadius: widget.borderRadius,
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}
