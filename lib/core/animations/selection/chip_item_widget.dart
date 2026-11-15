import 'package:flutter/material.dart';
import 'package:orbit/core/animations/tokens/app_animation_constants.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import 'chip_item.dart';

/// Single selectable chip widget used inside [AnimatedChipSelector].
///
/// The chip paints no fill when selected: the sliding indicator of
/// [AnimatedChipSelector] sits behind it and provides the selected
/// background. It deliberately does not use `FilterChip`, whose own selected
/// container would be drawn on top of that indicator and hide the label.
class ChipItemWidget<T> extends StatelessWidget {
  const ChipItemWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onSelected,
    this.labelStyle,
    this.selectedLabelStyle,
    this.iconSize,
  });

  final ChipItem<T> item;
  final bool isSelected;
  final VoidCallback onSelected;
  final TextStyle? labelStyle;
  final TextStyle? selectedLabelStyle;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    final effectiveLabelStyle = isSelected
        ? (selectedLabelStyle ??
              textStyles.labelMedium.copyWith(color: colors.onPrimary))
        : (labelStyle ??
              textStyles.labelMedium.copyWith(color: colors.textSecondary));

    final effectiveIconColor = isSelected
        ? colors.onPrimary
        : colors.textSecondary;

    final hasBadge = item.badge != null && item.badge! > 0;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppAnimationConstants.chipMinHeight,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isSelected ? null : colors.surfaceVariant,
                  borderRadius: AppRadius.borderFull,
                  border: Border.all(
                    color: isSelected ? Colors.transparent : colors.border,
                  ),
                ),
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onSelected,
                customBorder: const StadiumBorder(),
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.icon != null) ...[
                          Icon(
                            item.icon,
                            size:
                                iconSize ?? AppAnimationConstants.overlayIconGap,
                            color: effectiveIconColor,
                          ),
                          SizedBox(width: AppSpacing.xs),
                        ],
                        Flexible(
                          child: Text(
                            item.label,
                            style: effectiveLabelStyle,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (hasBadge)
              PositionedDirectional(
                end: AppAnimationConstants.chipBadgeOffset,
                top: AppAnimationConstants.chipBadgeOffset,
                child: Container(
                  width: AppAnimationConstants.chipBadgeSize,
                  height: AppAnimationConstants.chipBadgeSize,
                  decoration: BoxDecoration(
                    color: colors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? colors.onPrimary : colors.surface,
                      width: AppAnimationConstants.chipBadgeBorderWidth,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item.badge.toString(),
                      style: textStyles.labelSmall.copyWith(
                        color: colors.onError,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
