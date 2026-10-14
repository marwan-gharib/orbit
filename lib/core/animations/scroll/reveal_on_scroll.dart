import 'dart:math' as math;

import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:flutter/widgets.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';

/// Fades [child] in with a small upward slide the first time it enters the
/// viewport of the nearest [Scrollable]; once revealed it never hides or
/// replays.
///
/// The visibility check is one render-object transform per scroll tick, and
/// the scroll listener detaches as soon as the child reveals, so it stays
/// cheap inside long lists. Without an ancestor [Scrollable] the child is
/// revealed on the first frame. When `MediaQuery.disableAnimations` is true
/// the child renders in its final state immediately.
///
/// A lazily built list disposes this state once the item leaves the viewport,
/// so a recycled item plays the entrance again; keep the item alive (e.g.
/// `AutomaticKeepAliveClientMixin`) if that matters.
///
/// ```dart
/// ListView.builder(
///   itemCount: reports.length,
///   itemBuilder: (context, i) => RevealOnScroll(
///     child: ReportCard(report: reports[i]),
///   ),
/// )
/// ```
class RevealOnScroll extends StatefulWidget {
  const RevealOnScroll({
    super.key,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.enter,
    this.visibleFraction = AppAnimationConstants.revealVisibleFraction,
    required this.child,
  });

  /// Length of the fade-and-slide once the child enters the viewport.
  final Duration duration;

  /// Easing of the fade-and-slide.
  final Curve curve;

  /// Share of the child that must be visible before the entrance starts;
  /// capped at the viewport size for children taller than the viewport.
  final double visibleFraction;

  /// The subtree revealed on scroll; never rebuilt by the animation.
  final Widget child;

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _drive;
  ScrollableState? _scrollable;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _drive = _controller.drive(CurveTween(curve: widget.curve));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachToNearestScrollable();
    if (MediaQuery.disableAnimationsOf(context)) {
      _reveal();
      return;
    }
    // Geometry only exists after the first layout, so the initial check runs
    // on the frame that follows it.
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void didUpdateWidget(covariant RevealOnScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration == oldWidget.duration &&
        widget.curve == oldWidget.curve) {
      return;
    }
    _controller.duration = widget.duration;
    _drive = _controller.drive(CurveTween(curve: widget.curve));
  }

  @override
  void dispose() {
    _detach();
    _controller.dispose();
    super.dispose();
  }

  void _attachToNearestScrollable() {
    final scrollable = Scrollable.maybeOf(context);
    if (identical(scrollable, _scrollable)) return;
    _detach();
    _scrollable = scrollable;
    scrollable?.position.addListener(_check);
  }

  void _detach() {
    final scrollable = _scrollable;
    _scrollable = null;
    // An ancestor scrollable may already be disposed with the subtree.
    if (scrollable != null && scrollable.mounted) {
      scrollable.position.removeListener(_check);
    }
  }

  void _check() {
    if (_revealed || !mounted) return;
    if (_isInsideViewport()) _reveal();
  }

  bool _isInsideViewport() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.attached ||
        !renderObject.hasSize) {
      return false;
    }
    // RenderAbstractViewport.of asserts when the search finds no viewport,
    // so only look for one inside a scrollable; without a measurable
    // viewport the child cannot be hidden on purpose — reveal rather than
    // risk keeping content invisible.
    if (Scrollable.maybeOf(context) == null) return true;
    final viewportBox = switch (RenderAbstractViewport.of(renderObject)) {
      RenderBox box => box,
      _ => null,
    };
    if (viewportBox == null || !viewportBox.attached || !viewportBox.hasSize) {
      return true;
    }
    final topLeft = renderObject.localToGlobal(
      Offset.zero,
      ancestor: viewportBox,
    );
    final bottomRight = renderObject.localToGlobal(
      renderObject.size.bottomRight(Offset.zero),
      ancestor: viewportBox,
    );
    final visibleWidth =
        math.min(bottomRight.dx, viewportBox.size.width) -
        math.max(topLeft.dx, 0.0);
    final visibleHeight =
        math.min(bottomRight.dy, viewportBox.size.height) -
        math.max(topLeft.dy, 0.0);
    if (visibleWidth <= 0.0 || visibleHeight <= 0.0) return false;
    final fraction = widget.visibleFraction.clamp(0.0, 1.0).toDouble();
    final requiredWidth = math.min(
      fraction * renderObject.size.width,
      viewportBox.size.width,
    );
    final requiredHeight = math.min(
      fraction * renderObject.size.height,
      viewportBox.size.height,
    );
    return visibleWidth >= requiredWidth && visibleHeight >= requiredHeight;
  }

  void _reveal() {
    if (_revealed) return;
    _revealed = true;
    _detach();
    if (!mounted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1.0;
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AnimatedBuilder(
      animation: _drive,
      child: widget.child,
      builder: (context, child) => FadeTransition(
        opacity: _drive,
        child: SlideTransition(
          position: _drive.drive(
            Tween<Offset>(
              begin: AppAnimationConstants.slideFromBottom,
              end: Offset.zero,
            ),
          ),
          child: child,
        ),
      ),
    ),
  );
}
