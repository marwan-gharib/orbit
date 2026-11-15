import 'package:flutter/material.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import '../constants/dashboard_layout_constants.dart';

/// One legend row: colour dot, label (start) and value (end).
class DashboardLegendItem extends StatelessWidget {
  const DashboardLegendItem({
    super.key,
    required this.color,
    required this.label,
    required this.value,
    this.caption,
  });

  final Color color;
  final String label;
  final String value;

  /// Small secondary text under the value (e.g. a share of the total).
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: DashboardLayoutConstants.legendDot,
            height: DashboardLayoutConstants.legendDot,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: textStyles.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: textStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (caption != null)
                Text(
                  caption!,
                  style: textStyles.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
