import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:orbit/core/animations/tokens/app_curves.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';

import '../constants/interaction_layout_constants.dart';

/// Swipe background: the colour fades in and the icon scales up with the
/// drag progress.
class InteractionSwipeBackground extends StatelessWidget {
  const InteractionSwipeBackground({
    super.key,
    required this.progress,
    required this.alignment,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  final ValueListenable<double> progress;
  final AlignmentGeometry alignment;
  final IconData icon;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final idle = context.colors.surfaceVariant;

    return ValueListenableBuilder<double>(
      valueListenable: progress,
      builder: (context, value, _) {
        final t = AppCurves.standard.transform(value.clamp(0.0, 1.0));
        return Container(
          decoration: BoxDecoration(
            color: Color.lerp(idle, color, t),
            borderRadius: InteractionLayoutConstants.tileBorderRadius,
          ),
          alignment: alignment,
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: InteractionLayoutConstants.tileHorizontalPadding,
          ),
          child: Transform.scale(
            scale:
                InteractionLayoutConstants.swipeIconMinScale +
                (InteractionLayoutConstants.swipeIconMaxScale -
                        InteractionLayoutConstants.swipeIconMinScale) *
                    t,
            child: Icon(
              icon,
              color: iconColor,
              size: InteractionLayoutConstants.swipeIconSize,
            ),
          ),
        );
      },
    );
  }
}
