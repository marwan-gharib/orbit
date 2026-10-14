import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:flutter/widgets.dart';

import '../tokens/app_animation_constants.dart';

/// Shifts [child] behind the scroll content at a fraction of the scroll
/// speed — the classic "background moves slower than the content" effect.
///
/// Driven by the nearest [Scrollable]'s position, so no animation
/// controller is needed; pass [scrollController] to pin it to a specific
/// scroll view when several are nested. [parallaxFactor] is how much motion
/// the child gives up (0 = glued to the content, 1 = fixed to the viewport).
///
/// The child is laid out with `parallaxFactor * viewport` of extra size
/// along the scroll axis and clipped to the widget's slot, so give it a
/// child that paints its whole area (`Image` with `BoxFit.cover`, a
/// `ColoredBox`, ...). Inside a list, place it in a fixed-size tile.
/// Horizontal scrolling is RTL-aware: the direction comes from the scroll
/// position's [AxisDirection], which already mirrors under RTL.
/// When `MediaQuery.disableAnimations` is true the child renders without any
/// offset.
///
/// ```dart
/// SizedBox(
///   height: 160,
///   child: Stack(
///     fit: StackFit.expand,
///     children: [
///       ParallaxWidget(child: Image.network(coverUrl, fit: BoxFit.cover)),
///       const Align(
///         alignment: AlignmentDirectional.bottomStart,
///         child: Text('Sara Ahmed'),
///       ),
///     ],
///   ),
/// )
/// ```
class ParallaxWidget extends StatefulWidget {
  const ParallaxWidget({
    super.key,
    this.parallaxFactor = AppAnimationConstants.parallaxDefaultFactor,
    this.scrollController,
    required this.child,
  });

  /// Share of the scroll speed the child gives up; values are clamped to
  /// 0..1 so the background always moves slower than the content.
  final double parallaxFactor;

  /// Scroll view to follow; defaults to the nearest [Scrollable].
  final ScrollController? scrollController;

  /// The background subtree; should paint its whole (oversized) area.
  final Widget child;

  @override
  State<ParallaxWidget> createState() => _ParallaxWidgetState();
}

class _ParallaxWidgetState extends State<ParallaxWidget> {
  /// Translation of the background, recomputed on every scroll tick.
  final ValueNotifier<Offset> _offset = ValueNotifier<Offset>(Offset.zero);

  /// Extra extent of the background along the scroll axis; changes only on
  /// attach/resize, never on a scroll tick.
  final ValueNotifier<double> _slack = ValueNotifier<double>(0.0);

  /// Slot constraints of the last layout; the slot's size is read from here
  /// because a not-yet-slid child can report a zero extent of its own.
  BoxConstraints? _slotConstraints;

  ScrollPosition? _position;
  ScrollableState? _scrollable;
  bool _disableAnimations = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    _attach();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // An external controller may only get clients during the first build.
      _attach();
      _update();
    });
  }

  @override
  void didUpdateWidget(covariant ParallaxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController == oldWidget.scrollController &&
        widget.parallaxFactor == oldWidget.parallaxFactor) {
      return;
    }
    _attach();
    _update();
  }

  @override
  void dispose() {
    _detach();
    _offset.dispose();
    _slack.dispose();
    super.dispose();
  }

  void _attach() {
    final controller = widget.scrollController;
    final position = controller != null
        ? (controller.hasClients ? controller.position : null)
        : _takeNearestPosition();
    if (identical(position, _position)) return;
    _detach();
    _position = position;
    position?.addListener(_update);
  }

  ScrollPosition? _takeNearestPosition() {
    final scrollable = Scrollable.maybeOf(context);
    _scrollable = scrollable;
    return scrollable?.position;
  }

  void _detach() {
    final position = _position;
    _position = null;
    final scrollable = _scrollable;
    _scrollable = null;
    if (position == null) return;
    // An ancestor scrollable may already be disposed with the subtree; an
    // explicit controller always outlives this widget.
    if (scrollable == null || scrollable.mounted) {
      position.removeListener(_update);
    }
  }

  void _update() {
    if (!mounted) return;
    final position = _position;
    if (position == null ||
        _disableAnimations ||
        widget.parallaxFactor <= 0.0) {
      _settle();
      return;
    }
    // A scroll notification fires before the scrollable re-lays out its
    // children, so the slot geometry is only fresh on the next frame. Measuring
    // right away would read the pre-scroll position and never converge during
    // a drag; measuring every frame is wasteful. One post-frame check bridges
    // the two.
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFromLayout());
    _updateFromLayout();
  }

  void _updateFromLayout() {
    if (!mounted) return;
    final position = _position;
    if (position == null ||
        _disableAnimations ||
        widget.parallaxFactor <= 0.0) {
      _settle();
      return;
    }
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.attached ||
        !renderObject.hasSize) {
      return;
    }
    // RenderAbstractViewport.of asserts outside a viewport, so only look for
    // one inside a scrollable; a controller can point at a scroll view this
    // widget is not part of, and then there is nothing to parallax.
    if (Scrollable.maybeOf(context) == null) {
      _settle();
      return;
    }
    final viewportBox = switch (RenderAbstractViewport.of(renderObject)) {
      RenderBox box => box,
      _ => null,
    };
    if (viewportBox == null || !viewportBox.attached || !viewportBox.hasSize) {
      _settle();
      return;
    }
    final constraints = _slotConstraints;
    if (constraints == null) return;
    final viewport = position.viewportDimension;
    final horizontal = position.axis == Axis.horizontal;
    final slotExtent = horizontal
        ? constraints.maxWidth
        : constraints.maxHeight;
    if (viewport <= slotExtent) {
      // The slot fills the viewport along the scroll axis: nothing to slide.
      _settle();
      return;
    }
    final factor = widget.parallaxFactor.clamp(0.0, 1.0).toDouble();
    // `distance` is how far the slot has travelled past the viewport's start
    // edge. Clamping it to one traversal keeps the background inside its
    // slack, even during overscroll, so it never uncovers the slot.
    final distance = _startDistance(
      renderObject,
      viewportBox,
      position.axisDirection,
    ).clamp(slotExtent - viewport, slotExtent).toDouble();
    final travel = factor * (distance - slotExtent + viewport / 2);
    final slack = factor * viewport;
    if (_slack.value != slack) _slack.value = slack;
    _offset.value = _axisVector(position.axisDirection) * travel;
  }

  /// How far the slot's start edge has travelled past the viewport's start
  /// edge, in scroll pixels. Measured through the accumulated paint
  /// transforms, so RTL horizontal scrolling (whose start edge sits on the
  /// right) comes out mirrored for free.
  double _startDistance(
    RenderBox slot,
    RenderBox viewport,
    AxisDirection axisDirection,
  ) {
    final topLeft = slot.localToGlobal(Offset.zero, ancestor: viewport);
    return switch (axisDirection) {
      AxisDirection.down => -topLeft.dy,
      AxisDirection.up => topLeft.dy + slot.size.height - viewport.size.height,
      AxisDirection.left => -topLeft.dx,
      AxisDirection.right => topLeft.dx + slot.size.width - viewport.size.width,
    };
  }

  void _settle() {
    _offset.value = Offset.zero;
    if (_slack.value != 0.0) _slack.value = 0.0;
  }

  /// Points from the slot toward the scroll axis' trailing edge: the
  /// background lags behind the content, so its in-slot offset grows that
  /// way. Mirrors automatically for RTL horizontal scrolling, whose start
  /// edge sits on the right.
  Offset _axisVector(AxisDirection axisDirection) => switch (axisDirection) {
    AxisDirection.down => const Offset(0, 1),
    AxisDirection.up => const Offset(0, -1),
    AxisDirection.left => const Offset(1, 0),
    AxisDirection.right => const Offset(-1, 0),
  };

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      _slotConstraints = constraints;
      return AnimatedBuilder(
        animation: _slack,
        child: widget.child,
        builder: (context, child) =>
            _buildSlidingBackground(constraints, child),
      );
    },
  );

  Widget _buildSlidingBackground(BoxConstraints constraints, Widget? child) {
    final position = _position;
    final slack = _slack.value;
    if (position == null ||
        slack <= 0.0 ||
        _disableAnimations ||
        !constraints.hasBoundedWidth ||
        !constraints.hasBoundedHeight) {
      return child ?? widget.child;
    }
    final horizontal = position.axis == Axis.horizontal;
    return ClipRect(
      child: AnimatedBuilder(
        animation: _offset,
        child: OverflowBox(
          alignment: AlignmentDirectional.center,
          minWidth: horizontal
              ? constraints.maxWidth + slack
              : constraints.maxWidth,
          maxWidth: horizontal
              ? constraints.maxWidth + slack
              : constraints.maxWidth,
          minHeight: horizontal
              ? constraints.maxHeight
              : constraints.maxHeight + slack,
          maxHeight: horizontal
              ? constraints.maxHeight
              : constraints.maxHeight + slack,
          child: child,
        ),
        builder: (context, child) =>
            Transform.translate(offset: _offset.value, child: child),
      ),
    );
  }
}
