import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../tokens/app_animation_constants.dart';

import 'package:orbit/core/responsive/responsive.dart';

/// Scroll-linked 0..1 progress shared with descendant [FadeOnScrollBar]s:
/// 0 at the top of the followed scroll view, 1 once scrolled past the
/// [AppBarFadeOnScroll.threshold].
///
/// The mapping is instantaneous — a pure function of the scroll offset with
/// no time-based animation — so `MediaQuery.disableAnimations` pins the
/// progress to its final value (1: opaque and elevated) instead of
/// animating anything.
///
/// Two ways to feed it, both driving a [FadeOnScrollBar] that reads the
/// progress through [AppBarFadeOnScroll.maybeProgressOf]:
///
/// ```dart
/// // 1. Follow a specific scroll view from anywhere (e.g. Scaffold.appBar):
/// Scaffold(
///   appBar: AppBarFadeOnScroll(
///     scrollController: _scrollController,
///     child: FadeOnScrollBar(
///       backgroundColor: Theme.of(context).colorScheme.surface,
///       child: const SizedBox(
///         height: kToolbarHeight,
///         child: Center(child: Text('Employees')),
///       ),
///     ),
///   ),
///   body: ListView(controller: _scrollController, children: rows),
/// )
///
/// // 2. Let bubbling scroll notifications drive it: wrap the screen, and
/// //    stack the bar over the scroll view.
/// AppBarFadeOnScroll(
///   child: Stack(
///     children: [
///       const EmployeeList(),
///       PositionedDirectional(
///         top: 0, start: 0, end: 0,
///         child: FadeOnScrollBar(
///           backgroundColor: Theme.of(context).colorScheme.surface,
///           child: const SizedBox(height: kToolbarHeight),
///         ),
///       ),
///     ],
///   ),
/// )
/// ```
class AppBarFadeOnScroll extends StatefulWidget {
  const AppBarFadeOnScroll({
    super.key,
    this.threshold = AppAnimationConstants.appBarFadeThreshold,
    this.scrollController,
    required this.child,
  });

  /// Scroll distance (logical pixels) over which the progress goes 0 → 1.
  final double threshold;

  /// Scroll view to follow. When null, bubbling [ScrollNotification]s of the
  /// wrapped subtree drive the progress instead, so this widget must then be
  /// an ancestor of the scroll view.
  final ScrollController? scrollController;

  /// The subtree that receives the progress — typically the bar, wrapped in
  /// a [FadeOnScrollBar]. Anything else is passed through unchanged.
  final Widget child;

  /// The nearest ancestor [AppBarFadeOnScroll]'s progress, or null when
  /// there is none. [FadeOnScrollBar] then renders its final (opaque)
  /// state, so a bar stays readable without the wrapper.
  static ValueListenable<double>? maybeProgressOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_FadeOnScrollProgress>()
          ?._progress;

  @override
  State<AppBarFadeOnScroll> createState() => _AppBarFadeOnScrollState();
}

class _AppBarFadeOnScrollState extends State<AppBarFadeOnScroll> {
  final ValueNotifier<double> _progress = ValueNotifier<double>(
    AppAnimationConstants.fadeOpacityBegin,
  );
  double _scrollOffset = 0.0;
  bool _disableAnimations = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    _sync();
  }

  @override
  void didUpdateWidget(covariant AppBarFadeOnScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController == oldWidget.scrollController) return;
    oldWidget.scrollController?.removeListener(_sync);
    widget.scrollController?.addListener(_sync);
    _sync();
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_sync);
    _progress.dispose();
    super.dispose();
  }

  void _sync() {
    if (!mounted) return;
    if (_disableAnimations) {
      _progress.value = AppAnimationConstants.fadeOpacityEnd;
      return;
    }
    final controller = widget.scrollController;
    if (controller != null) {
      _scrollOffset = controller.hasClients ? controller.position.pixels : 0.0;
    }
    final threshold = Responsive.adapt(widget.threshold);
    _progress.value = threshold <= 0.0
        ? AppAnimationConstants.fadeOpacityEnd
        : (_scrollOffset / threshold)
              .clamp(
                AppAnimationConstants.fadeOpacityBegin,
                AppAnimationConstants.fadeOpacityEnd,
              )
              .toDouble();
  }

  bool _onScroll(ScrollNotification notification) {
    _scrollOffset = notification.metrics.pixels;
    _sync();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final wrapped = _FadeOnScrollProgress(
      progress: _progress,
      child: widget.child,
    );
    if (widget.scrollController != null) return wrapped;
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: wrapped,
    );
  }
}

class _FadeOnScrollProgress extends InheritedWidget {
  const _FadeOnScrollProgress({required this._progress, required super.child});

  final ValueListenable<double> _progress;

  @override
  bool updateShouldNotify(_FadeOnScrollProgress oldWidget) =>
      !identical(_progress, oldWidget._progress);
}

/// Fades [child]'s background in and lifts it with an elevation shadow as
/// the surrounding [AppBarFadeOnScroll] progress grows — the "solid app
/// bar" effect. The bar content itself stays fully opaque.
///
/// Reads the progress from the nearest [AppBarFadeOnScroll]
/// ([AppBarFadeOnScroll.maybeProgressOf]); without one it renders its final
/// state — opaque background, full [elevation] — so it degrades safely.
///
/// ```dart
/// FadeOnScrollBar(
///   backgroundColor: Theme.of(context).colorScheme.surface,
///   child: const SizedBox(height: kToolbarHeight, child: AppToolbar()),
/// )
/// ```
class FadeOnScrollBar extends StatelessWidget {
  const FadeOnScrollBar({
    super.key,
    this.backgroundColor,
    this.elevation = AppAnimationConstants.appBarFadeElevation,
    required this.child,
  });

  /// Painted behind [child] with a growing opacity; usually a theme color.
  /// It also tints the elevation shadow, so pass one for the shadow to be
  /// visible.
  final Color? backgroundColor;

  /// Elevation (logical pixels) the bar reaches at full progress.
  final double elevation;

  /// The bar content; always rendered fully opaque.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final progress =
        AppBarFadeOnScroll.maybeProgressOf(context) ??
        const AlwaysStoppedAnimation<double>(
          AppAnimationConstants.fadeOpacityEnd,
        );
    return AnimatedBuilder(
      animation: progress,
      child: child,
      builder: (context, child) {
        final alpha = progress.value;
        return PhysicalModel(
          elevation: Responsive.adapt(elevation) * alpha,
          color: (backgroundColor ?? Colors.transparent).withValues(
            alpha: alpha,
          ),
          child: child,
        );
      },
    );
  }
}
