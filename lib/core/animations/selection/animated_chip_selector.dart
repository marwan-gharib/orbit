import 'package:flutter/material.dart';
import 'package:orbit/core/animations/tokens/app_animation_constants.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';

import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import 'chip_item.dart';

/// A horizontally-arranged row of chips with an animated sliding indicator
/// that tracks the selected chip. Used by CRM shell tabs, stage chips and
/// type chips — one shared component for all three.
final class AnimatedChipSelector<T> extends StatefulWidget {
  const AnimatedChipSelector({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.scrollable = false,
    this.labelStyle,
    this.selectedLabelStyle,
    this.iconSize,
  });

  /// The selectable chips.
  final List<ChipItem<T>> items;

  /// The currently selected value.
  final T selectedValue;

  /// Called when the user taps a chip.
  final void Function(T value) onChanged;

  /// Whether chips scroll horizontally when they don't fit.
  final bool scrollable;

  /// Text style for unselected labels.
  final TextStyle? labelStyle;

  /// Text style for the selected label.
  final TextStyle? selectedLabelStyle;

  /// Size of leading icons. Defaults to [AppAnimationConstants].overlayIconGap
  /// when null.
  final double? iconSize;

  @override
  State<AnimatedChipSelector<T>> createState() =>
      _AnimatedChipSelectorState<T>();
}

class _AnimatedChipSelectorState<T> extends State<AnimatedChipSelector<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _position;
  late Animation<double> _width;

  final GlobalKey _indicatorKey = GlobalKey();
  late final List<GlobalKey> _chipKeys;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _chipKeys = List.generate(widget.items.length, (_) => GlobalKey());
    _buildAnimations();
    _controller.value = 1.0; // snap to selected on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measureSelectedChip();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-measure when the OS flips reduce-motion mid-animation.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedChipSelector<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      _controller.forward(from: 0.0);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _measureSelectedChip();
      });
    }
  }

  void _measureSelectedChip() {
    final selectedIndex = widget.items.indexWhere(
      (item) => item.value == widget.selectedValue,
    );
    if (selectedIndex < 0 || !mounted) return;

    final renderBox =
        _indicatorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final selectedBox =
        _chipKeys[selectedIndex].currentContext?.findRenderObject()
            as RenderBox?;
    if (selectedBox == null) return;

    final targetLeft =
        selectedBox.localToGlobal(Offset.zero).dx -
        renderBox.localToGlobal(Offset.zero).dx;
    final targetWidth = selectedBox.size.width;

    setState(() {
      _position = Tween<double>(
        begin: _position.value,
        end: targetLeft,
      ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.travel));
      _width = Tween<double>(
        begin: _width.value,
        end: targetWidth,
      ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.travel));
      _controller.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _buildAnimations() {
    _position = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.travel));
    _width = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.travel));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    final chips = <Widget>[];
    for (final (index, item) in widget.items.indexed) {
      final isSelected = item.value == widget.selectedValue;
      chips.add(
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.xs / 2,
          ),
          child: _buildChip(
            context,
            item,
            index,
            isSelected,
            textStyles,
            colors,
          ),
        ),
      );
    }

    final children = <Widget>[
      ...chips,
      AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Positioned(
          left: _position.value,
          top: 0,
          bottom: 0,
          width: _width.value,
          child: Container(
            key: _indicatorKey,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: AppRadius.borderFull,
            ),
          ),
        ),
      ),
    ];

    final stack = Stack(clipBehavior: Clip.none, children: children);

    if (widget.scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.xs / 2,
          ),
          child: stack,
        ),
      );
    }

    return stack;
  }

  Widget _buildChip(
    BuildContext context,
    ChipItem<T> item,
    int index,
    bool isSelected,
    AppTextStylesExtension textStyles,
    AppColorsExtension colors,
  ) {
    final effectiveLabelStyle = isSelected
        ? (widget.selectedLabelStyle ??
              textStyles.labelMedium.copyWith(color: colors.onPrimary))
        : (widget.labelStyle ??
              textStyles.labelMedium.copyWith(color: colors.textSecondary));
    final effectiveBackgroundColor = isSelected
        ? colors.primary
        : Colors.transparent;

    final badge = item.badge != null && item.badge! > 0;
    return FilterChip(
      key: _chipKeys[index],
      label: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: widget.iconSize ?? AppAnimationConstants.overlayIconGap,
                  color: isSelected ? colors.onPrimary : colors.textSecondary,
                ),
                SizedBox(width: AppSpacing.xxs),
              ],
              Text(item.label, style: effectiveLabelStyle),
            ],
          ),
          if (badge) ...[
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? colors.onPrimary : colors.surface,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    item.badge.toString(),
                    style: TextStyle(
                      color: colors.onError,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (_) => widget.onChanged(item.value),
      labelPadding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.sm),
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      backgroundColor: effectiveBackgroundColor,
      selectedColor: colors.primary,
      checkmarkColor: colors.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderFull,
        side: BorderSide(
          color: isSelected ? Colors.transparent : colors.border,
        ),
      ),
    );
  }
}
