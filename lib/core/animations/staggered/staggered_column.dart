import 'package:flutter/widgets.dart';

import 'staggered_item.dart';

/// A [Column] whose children cascade in one after another — for dashboards,
/// KPI stacks and forms. Child [i] starts `i * AppDurations.stagger` later;
/// children past [AppAnimationConstants.maxStaggerIndex] render immediately.
///
/// Children are wrapped, so flex children (`Expanded`, `Spacer`) cannot be
/// passed through — build a [Column] yourself and use [StaggeredListItem]
/// in that case. Layout parameters behave exactly like [Column]'s.
///
/// ```dart
/// StaggeredColumn(
///   crossAxisAlignment: CrossAxisAlignment.stretch,
///   children: const [KpiRow(), RevenueChart(), RecentOrders()],
/// )
/// ```
class StaggeredColumn extends StatelessWidget {
  const StaggeredColumn({
    super.key,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    required this.children,
  });

  /// How the children are placed horizontally; [Column]'s default.
  final CrossAxisAlignment crossAxisAlignment;

  /// How the children are placed vertically; [Column]'s default.
  final MainAxisAlignment mainAxisAlignment;

  /// Whether the column sizes to its children; [Column]'s default.
  final MainAxisSize mainAxisSize;

  /// The children, staggered by their position in this list.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: crossAxisAlignment,
    mainAxisAlignment: mainAxisAlignment,
    mainAxisSize: mainAxisSize,
    children: [
      for (var index = 0; index < children.length; index++)
        StaggeredItem(index: index, child: children[index]),
    ],
  );
}
