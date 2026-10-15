import 'package:flutter/widgets.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';
import 'staggered_item.dart';

/// One cell of a grid with a staggered entrance: cell [index] starts
/// `index * AppDurations.stagger` later, cells past
/// [AppAnimationConstants.maxStaggerIndex] render immediately.
///
/// The delay follows the linear index (reading order). For a delay per visual
/// row — cards of the same row entering together — pass `index ~/ columns`:
///
/// ```dart
/// GridView.builder(
///   itemCount: kpis.length,
///   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
///     crossAxisCount: 2,
///   ),
///   itemBuilder: (context, i) => StaggeredGridItem(
///     index: i ~/ 2, // two columns: one delay per row
///     child: KpiCard(kpi: kpis[i]),
///   ),
/// )
/// ```
class StaggeredGridItem extends StatelessWidget {
  const StaggeredGridItem({
    super.key,
    required this.index,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.enter,
    this.offset = AppAnimationConstants.slideFromBottom,
    required this.child,
  });

  /// Position of the cell in the sequence; drives the delay.
  final int index;

  /// Length of the entrance, excluding the index-derived delay.
  final Duration duration;

  /// Easing of the entrance.
  final Curve curve;

  /// Slide distance as a fraction of the child's size.
  final Offset offset;

  /// The cell's subtree.
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
