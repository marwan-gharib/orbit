import 'package:flutter/material.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';

import 'chip_item.dart';
import 'chip_item_widget.dart';

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
  late Animation<double> _top;
  late Animation<double> _width;
  late Animation<double> _height;

  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _indicatorKey = GlobalKey();
  late List<GlobalKey> _chipKeys;
  bool _isFirstMeasurement = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _chipKeys = List.generate(widget.items.length, (_) => GlobalKey());
    _buildAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measureSelectedChip();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1.0;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measureSelectedChip(animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedChipSelector<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length) {
      _chipKeys = List.generate(widget.items.length, (_) => GlobalKey());
    }
    if (widget.selectedValue != oldWidget.selectedValue ||
        widget.items.length != oldWidget.items.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _measureSelectedChip();
      });
    }
  }

  void _measureSelectedChip({bool animate = true}) {
    final selectedIndex = widget.items.indexWhere(
      (item) => item.value == widget.selectedValue,
    );
    if (selectedIndex < 0 || !mounted) return;

    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || !stackBox.hasSize) return;

    final selectedBox =
        _chipKeys[selectedIndex].currentContext?.findRenderObject()
            as RenderBox?;
    if (selectedBox == null || !selectedBox.hasSize) return;

    final targetOffset = stackBox.globalToLocal(
      selectedBox.localToGlobal(Offset.zero),
    );
    final targetWidth = selectedBox.size.width;
    final targetHeight = selectedBox.size.height;
    final targetLeft = targetOffset.dx;
    final targetTop = targetOffset.dy;

    final isReduceMotion = MediaQuery.disableAnimationsOf(context);
    final shouldAnimate = animate && !isReduceMotion && !_isFirstMeasurement;

    if (!shouldAnimate) {
      _position = AlwaysStoppedAnimation(targetLeft);
      _top = AlwaysStoppedAnimation(targetTop);
      _width = AlwaysStoppedAnimation(targetWidth);
      _height = AlwaysStoppedAnimation(targetHeight);
      _controller.value = 1.0;
    } else {
      _position = Tween<double>(
        begin: _position.value,
        end: targetLeft,
      ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.travel));
      _top = Tween<double>(
        begin: _top.value,
        end: targetTop,
      ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.travel));
      _width = Tween<double>(
        begin: _width.value,
        end: targetWidth,
      ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.travel));
      _height = Tween<double>(
        begin: _height.value,
        end: targetHeight,
      ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.travel));
      _controller.forward(from: 0.0);
    }

    _isFirstMeasurement = false;
    setState(() {});

    if (widget.scrollable) {
      final selectedContext = _chipKeys[selectedIndex].currentContext;
      if (selectedContext != null) {
        Scrollable.ensureVisible(
          selectedContext,
          duration: isReduceMotion ? Duration.zero : AppDurations.normal,
          curve: AppCurves.travel,
          alignment: 0.5,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _buildAnimations() {
    _position = const AlwaysStoppedAnimation(0.0);
    _top = const AlwaysStoppedAnimation(0.0);
    _width = const AlwaysStoppedAnimation(0.0);
    _height = const AlwaysStoppedAnimation(0.0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final indicator = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_width.value <= 0 || _height.value <= 0) {
          return const SizedBox.shrink();
        }
        return Positioned(
          left: _position.value,
          top: _top.value,
          width: _width.value,
          height: _height.value,
          child: Container(
            key: _indicatorKey,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: AppRadius.borderFull,
            ),
          ),
        );
      },
    );

    if (widget.scrollable) {
      final row = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, item) in widget.items.indexed)
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.xs / 2,
              ),
              child: ChipItemWidget<T>(
                key: _chipKeys[index],
                item: item,
                isSelected: item.value == widget.selectedValue,
                onSelected: () => widget.onChanged(item.value),
                labelStyle: widget.labelStyle,
                selectedLabelStyle: widget.selectedLabelStyle,
                iconSize: widget.iconSize,
              ),
            ),
        ],
      );

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.xs / 2,
          ),
          child: Stack(
            key: _stackKey,
            clipBehavior: Clip.none,
            children: [indicator, row],
          ),
        ),
      );
    }

    final row = Row(
      children: [
        for (final (index, item) in widget.items.indexed)
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.xs / 2,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ChipItemWidget<T>(
                  key: _chipKeys[index],
                  item: item,
                  isSelected: item.value == widget.selectedValue,
                  onSelected: () => widget.onChanged(item.value),
                  labelStyle: widget.labelStyle,
                  selectedLabelStyle: widget.selectedLabelStyle,
                  iconSize: widget.iconSize,
                ),
              ),
            ),
          ),
      ],
    );

    return Stack(
      key: _stackKey,
      clipBehavior: Clip.none,
      children: [indicator, row],
    );
  }
}
