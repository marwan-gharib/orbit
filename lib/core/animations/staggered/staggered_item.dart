import 'package:flutter/widgets.dart';

import '../entrance/fade_slide_in.dart';
import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';

/// Shared engine behind [StaggeredListItem] and [StaggeredGridItem]; prefer
/// those wrappers and use this only for a custom staggered child.
///
/// Delays the entrance of [child] by `index * AppDurations.stagger`. Indices
/// outside `0..AppAnimationConstants.maxStaggerIndex` (negative or past the
/// cap) render immediately with no entrance at all, so a long list keeps
/// neither a cascading tail nor unbounded keep-alive memory.
///
/// Play-once guarantee:
/// * The entrance lives in [FadeSlideIn]/[Entrance], whose controller starts
///   once per element — rebuilds and index changes never restart it, so a
///   recycled element shows the finished state instead of replaying.
/// * Scrolling away would dispose that element, so animated items request
///   keep-alive via [AutomaticKeepAliveClientMixin] and survive leaving the
///   viewport; scrolling back finds the finished animation, never a new one.
/// * Keep-alive is only requested while an entrance exists, so at most
///   `maxStaggerIndex + 1` items are kept per list.
/// * Requires `addAutomaticKeepAlives: true`, the default of [ListView],
///   [GridView], [SliverList] and [SliverGrid].
///
/// ```dart
/// StaggeredItem(
///   index: index,
///   child: const OrderRow(),
/// )
/// ```
class StaggeredItem extends StatefulWidget {
  const StaggeredItem({
    super.key,
    required this.index,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.enter,
    this.offset = AppAnimationConstants.slideFromBottom,
    required this.child,
  });

  /// Position in the sequence; drives the delay.
  final int index;

  /// Length of the entrance, excluding the index-derived delay.
  final Duration duration;

  /// Easing of the entrance.
  final Curve curve;

  /// Slide distance as a fraction of the child's size.
  final Offset offset;

  /// The subtree that enters once and then never replays.
  final Widget child;

  @override
  State<StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<StaggeredItem>
    with AutomaticKeepAliveClientMixin {
  bool get _animatesEntrance =>
      widget.index >= 0 &&
      widget.index <= AppAnimationConstants.maxStaggerIndex;

  @override
  bool get wantKeepAlive => _animatesEntrance;

  @override
  void didUpdateWidget(covariant StaggeredItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      updateKeepAlive();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Registers/releases keep-alive; the return value must be ignored.
    super.build(context);
    if (!_animatesEntrance) return widget.child;
    return FadeSlideIn(
      delay: AppDurations.stagger * widget.index,
      duration: widget.duration,
      curve: widget.curve,
      offset: widget.offset,
      child: widget.child,
    );
  }
}
