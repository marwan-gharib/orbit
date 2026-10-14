import 'package:flutter/widgets.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';
import 'staggered_item.dart';

/// One row of a lazy list with a staggered entrance: row [index] starts
/// `index * AppDurations.stagger` later, rows past
/// [AppAnimationConstants.maxStaggerIndex] render immediately.
///
/// Plays once and never replays — not on rebuild, not on scroll-back, not
/// when [ListView.builder] recycles the element (see [StaggeredItem] for the
/// guarantee and its trade-offs).
///
/// ```dart
/// ListView.builder(
///   itemCount: orders.length,
///   itemBuilder: (context, index) => StaggeredListItem(
///     index: index,
///     child: OrderRow(order: orders[index]),
///   ),
/// )
/// ```
class StaggeredListItem extends StatelessWidget {
  const StaggeredListItem({
    super.key,
    required this.index,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.enter,
    this.offset = AppAnimationConstants.slideFromBottom,
    required this.child,
  });

  /// Position of the row in the list; drives the delay.
  final int index;

  /// Length of the entrance, excluding the index-derived delay.
  final Duration duration;

  /// Easing of the entrance.
  final Curve curve;

  /// Slide distance as a fraction of the child's size.
  final Offset offset;

  /// The row's subtree.
  final Widget child;

  @override
  Widget build(BuildContext context) => StaggeredItem(
    index: index,
    duration: duration,
    curve: curve,
    offset: offset,
    child: child,
  );
}
