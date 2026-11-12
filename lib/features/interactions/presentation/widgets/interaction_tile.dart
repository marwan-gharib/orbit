import 'package:flutter/material.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/utils/formatters.dart';

import '../constants/interaction_layout_constants.dart';
import '../view_models/interaction_tile_data.dart';
import 'interaction_swipe_background.dart';
import 'interaction_type_icon.dart';

/// Actions available from the tile's overflow menu.
enum InteractionTileAction { edit, delete }

/// One interaction tile: type icon, subject, description preview,
/// optional "Open opportunity" chip, overflow menu (Edit, Delete),
/// and swipe actions (edit/delete).
///
/// The whole tile is a single tap target (Q1). Swipe edit/delete both
/// return false from confirmDismiss so the tile stays in the tree;
/// removal happens via id-diff collapse-out after silent refresh.
class InteractionTile extends StatefulWidget {
  const InteractionTile({
    super.key,
    required this.data,
    this.showDate = true,
    this.showOpenOpportunityChip = true,
    this.showAuthorName = false,
    this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onOpenOpportunity,
  });

  final InteractionTileData data;
  final bool showDate;
  final bool showOpenOpportunityChip;
  final bool showAuthorName;
  final VoidCallback? onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onOpenOpportunity;

  @override
  State<InteractionTile> createState() => _InteractionTileState();
}

class _InteractionTileState extends State<InteractionTile> {
  /// Drag progress (0..1) of the current swipe; drives the reveal animation.
  final ValueNotifier<double> _progress = ValueNotifier<double>(0);

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labels = context.t.crm.crmInteractions;

    final tile = _TileContent(
      data: widget.data,
      showDate: widget.showDate,
      showOpenOpportunityChip: widget.showOpenOpportunityChip,
      showAuthorName: widget.showAuthorName,
      onOpenOpportunity: widget.onOpenOpportunity,
    );

    return Dismissible(
      key: ValueKey('interaction-tile-${widget.data.id}'),
      direction: DismissDirection.horizontal,
      onUpdate: (details) => _progress.value = details.progress,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          widget.onDelete();
        } else if (direction == DismissDirection.startToEnd) {
          widget.onEdit();
        }
        // Always false: the tile stays in the tree. Removal happens through
        // the id-diff collapse-out after the silent refresh.
        return false;
      },
      background: InteractionSwipeBackground(
        progress: _progress,
        alignment: AlignmentDirectional.centerStart,
        icon: Icons.edit_rounded,
        color: colors.primary,
        iconColor: colors.onPrimary,
      ),
      secondaryBackground: InteractionSwipeBackground(
        progress: _progress,
        alignment: AlignmentDirectional.centerEnd,
        icon: Icons.delete_rounded,
        color: colors.error,
        iconColor: colors.onError,
      ),
      child: Material(
        color: colors.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: InteractionLayoutConstants.tileBorderRadius,
          side: BorderSide(color: colors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: () => _showActions(context),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: InteractionLayoutConstants.tileHorizontalPadding,
              vertical: InteractionLayoutConstants.tileVerticalPadding,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InteractionTypeIcon(type: widget.data.type),
                SizedBox(width: InteractionLayoutConstants.typeIconGap),
                Expanded(child: tile),
                AppPopupMenu<InteractionTileAction>(
                  tooltip: context.t.crm.common.moreActions,
                  items: [
                    PopupMenuItem<InteractionTileAction>(
                      value: InteractionTileAction.edit,
                      child: Text(labels.edit),
                    ),
                    PopupMenuItem<InteractionTileAction>(
                      value: InteractionTileAction.delete,
                      child: Text(labels.delete),
                    ),
                  ],
                  onSelected: _run,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _run(InteractionTileAction action) {
    switch (action) {
      case InteractionTileAction.edit:
        widget.onEdit();
      case InteractionTileAction.delete:
        widget.onDelete();
    }
  }

  /// Long-press alternative to swiping (accessible path to the same actions).
  Future<void> _showActions(BuildContext context) async {
    final labels = context.t.crm.crmInteractions;
    final action = await AppBottomSheet.show<InteractionTileAction>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: Text(labels.edit),
              onTap: () =>
                  Navigator.pop(sheetContext, InteractionTileAction.edit),
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded),
              title: Text(labels.delete),
              onTap: () =>
                  Navigator.pop(sheetContext, InteractionTileAction.delete),
            ),
          ],
        ),
      ),
    );
    if (action != null) _run(action);
  }
}

class _TileContent extends StatelessWidget {
  const _TileContent({
    required this.data,
    required this.showDate,
    required this.showOpenOpportunityChip,
    required this.showAuthorName,
    required this.onOpenOpportunity,
  });

  final InteractionTileData data;
  final bool showDate;
  final bool showOpenOpportunityChip;
  final bool showAuthorName;
  final VoidCallback? onOpenOpportunity;

  @override
  Widget build(BuildContext context) {
    final labels = context.t.crm.crmInteractions;
    final colors = context.colors;
    final textStyles = context.textStyles;

    final children = <Widget>[
      Text(
        data.subject,
        style: textStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: InteractionLayoutConstants.contentGap),
      Text(
        data.description.isEmpty ? labels.item.noDescription : data.description,
        style: textStyles.bodyMedium.copyWith(color: colors.textSecondary),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ];

    if (showDate) {
      children.add(SizedBox(height: InteractionLayoutConstants.contentGap));
      children.add(
        Text(
          Formatters.crmDate(data.date),
          style: textStyles.labelSmall.copyWith(color: colors.textSecondary),
        ),
      );
    }

    if (showAuthorName && data.authorName != null) {
      children.add(SizedBox(height: InteractionLayoutConstants.contentGap));
      children.add(
        Text(
          data.authorName!,
          style: textStyles.labelSmall.copyWith(color: colors.textSecondary),
        ),
      );
    }

    if (showOpenOpportunityChip &&
        data.opportunityId != null &&
        onOpenOpportunity != null) {
      children.add(SizedBox(height: InteractionLayoutConstants.contentGap));
      children.add(
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ActionChip(
            avatar: Icon(
              Icons.work_outline_rounded,
              size: InteractionLayoutConstants.swipeIconSize * 0.8,
              color: colors.onPrimaryContainer,
            ),
            label: Text(
              labels.item.openOpportunity,
              style: textStyles.labelMedium.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: onOpenOpportunity,
            backgroundColor: colors.primaryContainer,
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: InteractionLayoutConstants.chipHorizontalPadding,
              vertical: AppSpacing.xxs,
            ),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderFull),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
