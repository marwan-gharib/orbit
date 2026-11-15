import 'package:flutter/material.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/presentation/constants/interaction_layout_constants.dart';

/// Type icon in a tonal circle with a distinct color and a one-shot
/// micro-animation per type:
/// - Call: ring pulse (scale + opacity)
/// - Email: flap (horizontal scale oscillation)
/// - Meeting: pop (scale up + down)
///
/// Plays once when the tile first appears (capped to first visible tiles),
/// never on refresh, no infinite loops. Static under reduce-motion.
class InteractionTypeIcon extends StatefulWidget {
  const InteractionTypeIcon({super.key, required this.type, this.size});

  final InteractionType type;
  final double? size;

  @override
  State<InteractionTypeIcon> createState() => _InteractionTypeIconState();
}

class _InteractionTypeIconState extends State<InteractionTypeIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _played = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _animation = CurvedAnimation(parent: _controller, curve: AppCurves.spring);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (!_played && !disableAnimations) {
      _played = true;
      _controller.forward();
    } else if (disableAnimations) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveSize =
        widget.size ?? InteractionLayoutConstants.typeIconSize;
    final iconData = _iconData(widget.type);
    final backgroundColor = _backgroundColor(widget.type, colors);
    final iconColor = _iconColor(widget.type, colors);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final progress = _animation.value;
          final transform = _transformForType(widget.type, progress);
          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: child,
          );
        },
        child: Container(
          width: effectiveSize,
          height: effectiveSize,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, size: effectiveSize * 0.5, color: iconColor),
        ),
      ),
    );
  }

  Matrix4 _transformForType(InteractionType type, double progress) {
    switch (type) {
      case InteractionType.call:
        // Ring pulse: scale up slightly
        final scale = 1.0 + (0.15 * progress);
        return Matrix4.identity()..scaleByDouble(scale, scale, scale, 1.0);
      case InteractionType.email:
        // Flap: horizontal scale oscillation
        final scaleX = 1.0 - (0.15 * (1 - (2 * progress - 1).abs()));
        return Matrix4.identity()..scaleByDouble(scaleX, 1.0, 1.0, 1.0);
      case InteractionType.meeting:
        // Pop: quick scale up and down
        final scale = 1.0 + (0.2 * (1 - (2 * progress - 1).abs()));
        return Matrix4.identity()..scaleByDouble(scale, scale, scale, 1.0);
      case InteractionType.unknown:
        return Matrix4.identity();
    }
  }

  IconData _iconData(InteractionType type) {
    switch (type) {
      case InteractionType.call:
        return Icons.call_rounded;
      case InteractionType.email:
        return Icons.email_rounded;
      case InteractionType.meeting:
        return Icons.meeting_room_rounded;
      case InteractionType.unknown:
        return Icons.help_outline_rounded;
    }
  }

  Color _backgroundColor(InteractionType type, AppColorsExtension colors) {
    switch (type) {
      case InteractionType.call:
        return colors.primaryContainer;
      case InteractionType.email:
        return colors.secondaryContainer;
      case InteractionType.meeting:
        return colors.successContainer;
      case InteractionType.unknown:
        return colors.surfaceVariant;
    }
  }

  Color _iconColor(InteractionType type, AppColorsExtension colors) {
    switch (type) {
      case InteractionType.call:
        return colors.onPrimaryContainer;
      case InteractionType.email:
        return colors.onSecondaryContainer;
      case InteractionType.meeting:
        return colors.onSuccessContainer;
      case InteractionType.unknown:
        return colors.textSecondary;
    }
  }
}
