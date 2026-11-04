import 'package:flutter/material.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import '../constants/interaction_layout_constants.dart';

/// Loading twin of [InteractionTile]: same geometry, driven by one
/// [ShimmerScope] per feed. Static under reduce-motion.
class InteractionTileSkeleton extends StatelessWidget {
  const InteractionTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final loadingLabel = context.t.crm.crmInteractions.loading;

    return Semantics(
      label: loadingLabel,
      container: true,
      child: ExcludeSemantics(
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: InteractionLayoutConstants.tileBorderRadius,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: InteractionLayoutConstants.tileHorizontalPadding,
              vertical: InteractionLayoutConstants.tileVerticalPadding,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox.circle(
                  width: InteractionLayoutConstants.typeIconSize,
                  height: InteractionLayoutConstants.typeIconSize,
                ),
                SizedBox(width: InteractionLayoutConstants.typeIconGap),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShimmerBox.textLine(
                          width:
                              constraints.maxWidth *
                              InteractionLayoutConstants.skeletonSubjectWidth,
                          height: context.textStyles.titleMedium.fontSize,
                        ),
                        SizedBox(height: InteractionLayoutConstants.contentGap),
                        ShimmerBox.textLine(
                          width:
                              constraints.maxWidth *
                              InteractionLayoutConstants
                                  .skeletonDescriptionWidth,
                          height: context.textStyles.bodyMedium.fontSize,
                        ),
                        SizedBox(height: InteractionLayoutConstants.contentGap),
                        ShimmerBox.textLine(
                          width:
                              constraints.maxWidth *
                              InteractionLayoutConstants.skeletonDateWidth,
                          height: context.textStyles.labelSmall.fontSize,
                        ),
                      ],
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
