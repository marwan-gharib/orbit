import 'package:flutter/material.dart';

import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

import '../constants/interaction_layout_constants.dart';
import '../view_models/interaction_tile_data.dart';
import 'interaction_tile.dart';
import 'interaction_type_icon.dart';

/// Non-scrolling timeline of interactions for the opportunity detail tab.
/// Newest first, vertical connector line behind type-icon nodes, tiles on the end side.
class InteractionsTimeline extends StatefulWidget {
  const InteractionsTimeline({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onDelete,
    this.isRefreshing = false,
  });

  final List<InteractionTileData> items;
  final ValueChanged<InteractionTileData> onEdit;
  final ValueChanged<InteractionTileData> onDelete;
  final bool isRefreshing;

  @override
  State<InteractionsTimeline> createState() => _InteractionsTimelineState();
}

class _InteractionsTimelineState extends State<InteractionsTimeline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _connectorController;
  late final Animation<double> _connectorProgress;

  @override
  void initState() {
    super.initState();
    _connectorController = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _connectorProgress = CurvedAnimation(
      parent: _connectorController,
      curve: AppCurves.enter,
    );
    _connectorController.forward();
  }

  @override
  void didUpdateWidget(covariant InteractionsTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isRefreshing && widget.isRefreshing) {
      _connectorController.reset();
      _connectorController.forward();
    }
  }

  @override
  void dispose() {
    _connectorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isRefreshing) ...[
          const AnimatedProgressBar(),
          SizedBox(height: AppSpacing.sm),
        ],
        if (widget.items.isEmpty) ...[
          _buildEmpty(context),
        ] else ...[
          for (var i = 0; i < widget.items.length; i++)
            _TimelineItem(
              tile: widget.items[i],
              index: i,
              isFirst: i == 0,
              isLast: i == widget.items.length - 1,
              onEdit: widget.onEdit,
              onDelete: widget.onDelete,
              progress: _connectorProgress,
            ),
        ],
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final labels = context.t.crm.crmInteractions;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: context.colors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              labels.interactionsEmpty,
              style: context.textStyles.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.tile,
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
    required this.progress,
  });

  final InteractionTileData tile;
  final int index;
  final bool isFirst;
  final bool isLast;
  final ValueChanged<InteractionTileData> onEdit;
  final ValueChanged<InteractionTileData> onDelete;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        bottom: isLast ? 0 : InteractionLayoutConstants.timelineGap,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connector line + type icon node
          SizedBox(
            width: InteractionLayoutConstants.typeIconSize,
            child: Stack(
              children: [
                // Vertical connector line (draws progressively)
                if (!isFirst)
                  AnimatedBuilder(
                    animation: progress,
                    builder: (context, child) => CustomPaint(
                      size: Size(
                        InteractionLayoutConstants.timelineConnectorWidth,
                        InteractionLayoutConstants.timelineGap +
                            InteractionLayoutConstants.typeIconSize,
                      ),
                      painter: _ConnectorPainter(
                        progress: progress.value,
                        color: context.colors.border,
                        lineWidth:
                            InteractionLayoutConstants.timelineConnectorWidth,
                      ),
                    ),
                  ),
                // Type icon node (centered)
                Center(child: InteractionTypeIcon(type: tile.type)),
              ],
            ),
          ),
          SizedBox(width: InteractionLayoutConstants.typeIconGap),
          // Tile content
          Expanded(
            child: InteractionTile(
              data: tile,
              showDate: true,
              showOpenOpportunityChip: false, // Already in opportunity detail
              showAuthorName: true,
              onEdit: () => onEdit(tile),
              onDelete: () => onDelete(tile),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({
    required this.progress,
    required this.color,
    required this.lineWidth,
  });

  final double progress;
  final Color color;
  final double lineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    final drawHeight = size.height * progress.clamp(0.0, 1.0);
    final startY = size.height - drawHeight;

    canvas.drawLine(
      Offset(size.width / 2, startY),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
