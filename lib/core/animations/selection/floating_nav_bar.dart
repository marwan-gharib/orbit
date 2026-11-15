import 'package:flutter/material.dart';
import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import '../tokens/app_animation_constants.dart';
import '../tokens/app_curves.dart';
import '../tokens/app_durations.dart';

/// One destination of a [FloatingNavBar].
class FloatingNavItem {
  const FloatingNavItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
  });

  final String label;
  final IconData icon;

  /// Icon shown while selected; falls back to [icon].
  final IconData? selectedIcon;
}

/// Rounded navigation bar that floats above the content, away from the
/// screen edges.
///
/// The bar is driven by one continuous position (0 .. items-1): the pill sits
/// at that position and each item blends its colour and icon scale by how
/// close the position is to it. With [position] (e.g.
/// `TabController.animation`) the bar follows taps *and* swipes frame by
/// frame; without it, a change of [selectedIndex] glides there once. No
/// second animation layer is stacked on top, so nothing overshoots or jitters.
///
/// ```dart
/// FloatingNavBar(
///   items: [
///     FloatingNavItem(label: 'Opportunities', icon: Icons.work_outline),
///     FloatingNavItem(label: 'Interactions', icon: Icons.forum_outlined),
///   ],
///   selectedIndex: tabController.index,
///   position: tabController.animation,
///   onSelected: (i) => tabController.animateTo(i),
/// )
/// ```
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.position,
  }) : assert(items.length >= 2, 'A navigation bar needs 2+ items');

  final List<FloatingNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Continuous position in item units. When null the bar animates between
  /// [selectedIndex] values itself.
  final Animation<double>? position;

  @override
  Widget build(BuildContext context) {
    final external = position;
    if (external != null) {
      return AnimatedBuilder(
        animation: external,
        builder: (context, _) => _Bar(
          items: items,
          value: external.value,
          selectedIndex: selectedIndex,
          onSelected: onSelected,
        ),
      );
    }
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: selectedIndex.toDouble()),
      duration: reduceMotion ? Duration.zero : AppDurations.normal,
      curve: AppCurves.standard,
      builder: (context, value, _) => _Bar(
        items: items,
        value: value,
        selectedIndex: selectedIndex,
        onSelected: onSelected,
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.items,
    required this.value,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<FloatingNavItem> items;
  final double value;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Share of the bar width an icon-only item gets, relative to an equal
  /// split. The selected item takes the rest, so its label fits.
  static const double _compactShare = 0.78;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = items.length;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppSpacing.lg,
          end: AppSpacing.lg,
          bottom: AppSpacing.md,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.adapt(AppAnimationConstants.floatingNavMaxWidth),
          ),
          child: Material(
            color: colors.surfaceElevated,
            elevation: AppAnimationConstants.floatingNavElevation,
            shadowColor: colors.shadow,
            shape: StadiumBorder(side: BorderSide(color: colors.border)),
            child: SizedBox(
              height: Responsive.adapt(AppAnimationConstants.floatingNavHeight),
              child: Padding(
                padding: EdgeInsetsDirectional.all(AppSpacing.xs),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final total = constraints.maxWidth;
                    final compact = total / count * _compactShare;
                    final wide = total - compact * (count - 1);
                    // 1 when the pill is on item i, 0 when away.
                    double closeness(int i) =>
                        (1 - (value - i).abs()).clamp(0.0, 1.0);
                    double widthOf(int i) =>
                        compact + (wide - compact) * closeness(i);

                    final lefts = <double>[];
                    var cursor = 0.0;
                    for (var i = 0; i < count; i++) {
                      lefts.add(cursor);
                      cursor += widthOf(i);
                    }
                    var pillLeft = 0.0;
                    var pillWidth = 0.0;
                    for (var i = 0; i < count; i++) {
                      pillLeft += lefts[i] * closeness(i);
                      pillWidth += widthOf(i) * closeness(i);
                    }

                    return Stack(
                      children: [
                        PositionedDirectional(
                          start: pillLeft,
                          width: pillWidth,
                          top: 0,
                          bottom: 0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: AppRadius.borderFull,
                            ),
                          ),
                        ),
                        for (var i = 0; i < count; i++)
                          PositionedDirectional(
                            start: lefts[i],
                            width: widthOf(i),
                            top: 0,
                            bottom: 0,
                            child: _NavItem(
                              item: items[i],
                              closeness: closeness(i),
                              selected: i == selectedIndex,
                              onTap: () => onSelected(i),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.closeness,
    required this.selected,
    required this.onTap,
  });

  final FloatingNavItem item;
  final double closeness;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = Color.lerp(
      colors.textSecondary,
      colors.onPrimaryContainer,
      closeness,
    );
    final scale =
        1 + (AppAnimationConstants.floatingNavSelectedScale - 1) * closeness;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        borderRadius: AppRadius.borderFull,
        child: ClipRect(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: scale,
                  child: Icon(
                    closeness > 0.5
                        ? (item.selectedIcon ?? item.icon)
                        : item.icon,
                    size: AppAnimationConstants.floatingNavIconSize,
                    color: color,
                  ),
                ),
                // The label grows from nothing as the pill arrives, so an
                // icon-only item never overflows.
                ClipRect(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: closeness,
                    child: Opacity(
                      opacity: closeness,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: AppSpacing.xs,
                        ),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.clip,
                          style: context.textStyles.labelLarge.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
