import 'package:flutter/material.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';

/// A pinned collapsing header for a `CustomScrollView`: [title] renders
/// large while expanded (scaled by [expandedTitleScale]) and eases into the
/// toolbar as the view scrolls, over an optional [background] slot that
/// fades out with a slight zoom.
///
/// Built on [SliverAppBar] + [FlexibleSpaceBar]; the collapse is a pure
/// scroll-extent mapping with no time-based animation (the same contract
/// Flutter's own app bar keeps), so it behaves identically when
/// `MediaQuery.disableAnimations` is true.
///
/// ```dart
/// CustomScrollView(
///   slivers: [
///     CollapsingHeader(
///       expandedHeight: 220,
///       title: const Text('Sara Ahmed'),
///       background: Image.network(employeePhotoUrl, fit: BoxFit.cover),
///       actions: [
///         IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
///       ],
///     ),
///     SliverToBoxAdapter(child: ProfileSections(employee: employee)),
///   ],
/// )
/// ```
class CollapsingHeader extends StatelessWidget {
  const CollapsingHeader({
    super.key,
    required this.title,
    this.background,
    this.expandedHeight,
    this.expandedTitleScale = AppAnimationConstants.collapsingTitleScale,
    this.pinned = true,
    this.leading,
    this.actions,
    this.bottom,
  });

  /// The header's title: shown large (scaled by [expandedTitleScale]) while
  /// fully expanded, compact in the toolbar once collapsed;
  /// [FlexibleSpaceBar] fades between the two.
  final Widget title;

  /// Full-bleed content behind [title] — a cover photo, an avatar collage;
  /// fades out and zooms slightly while the header collapses.
  final Widget? background;

  /// Total height of the expanded header in logical pixels; when null the
  /// app bar's own default applies.
  final double? expandedHeight;

  /// Scale of [title] while fully expanded.
  final double expandedTitleScale;

  /// Whether the header stays pinned at the top while the view scrolls.
  final bool pinned;

  /// Leading widget of the collapsed toolbar.
  final Widget? leading;

  /// Trailing widgets of the collapsed toolbar.
  final List<Widget>? actions;

  /// Optional bottom slot of the collapsed toolbar (tabs, a search field).
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final background = this.background;
    return SliverAppBar(
      pinned: pinned,
      expandedHeight: expandedHeight,
      leading: leading,
      actions: actions,
      bottom: bottom,
      flexibleSpace: FlexibleSpaceBar(
        title: title,
        expandedTitleScale: expandedTitleScale,
        background: background == null
            ? null
            : _CollapsingBackground(child: background),
      ),
    );
  }
}

/// Fades and zooms a collapsing header's background slot by the enclosing
/// [FlexibleSpaceBar]'s collapse progress. The progress is written straight
/// into an [AnimationController] value in [didChangeDependencies], so no
/// `setState` runs per scroll tick — only the transition rebuilds.
class _CollapsingBackground extends StatefulWidget {
  const _CollapsingBackground({required this.child});

  /// The background subtree; never rebuilt by the collapse.
  final Widget child;

  @override
  State<_CollapsingBackground> createState() => _CollapsingBackgroundState();
}

class _CollapsingBackgroundState extends State<_CollapsingBackground>
    with SingleTickerProviderStateMixin {
  /// Value holder for the collapse progress (1 = fully expanded); nothing is
  /// ever animated over time, so no duration is needed.
  late final AnimationController _controller;
  late final Animation<double> _drive;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(
      vsync: this,
      value: AppAnimationConstants.fadeOpacityEnd,
    );
    _drive = _controller.drive(CurveTween(curve: AppCurves.standard));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    if (settings == null) return;
    final extent = settings.maxExtent - settings.minExtent;
    _controller.value = extent <= 0.0
        ? AppAnimationConstants.fadeOpacityEnd
        : ((settings.currentExtent - settings.minExtent) / extent)
              .clamp(0.0, 1.0)
              .toDouble();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: FadeTransition(
      opacity: _drive,
      child: AnimatedBuilder(
        animation: _drive,
        child: widget.child,
        builder: (context, child) => Transform.scale(
          scale:
              1.0 +
              (AppAnimationConstants.collapsingBackgroundScale - 1.0) *
                  _drive.value,
          child: child,
        ),
      ),
    ),
  );
}
