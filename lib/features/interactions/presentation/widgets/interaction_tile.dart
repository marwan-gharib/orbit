import 'package:flutter/material.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/animations/overlays/app_popup_menu.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/utils/formatters.dart';

import '../constants/interaction_layout_constants.dart';
import '../view_models/interaction_tile_data.dart';
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
class InteractionTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labels = context.t.crm.crmInteractions;

    final tile = _TileContent(
      data: data,
      showDate: showDate,
      showOpenOpportunityChip: showOpenOpportunityChip,
      showAuthorName: showAuthorName,
      onOpenOpportunity: onOpenOpportunity,
    );

    return Dismissible(
      key: ValueKey('interaction-tile-${data.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete direction
          onDelete();
        } else if (direction == DismissDirection.startToEnd) {
          // Edit direction
          onEdit();
        }
        // Always return false so the tile stays in the tree.
        // Removal happens via id-diff collapse-out after silent refresh.
        return false;
      },
      background: _SwipeBackground(
        direction: DismissDirection.startToEnd,
        icon: Icons.edit_rounded,
        color: colors.primary,
        iconColor: colors.onPrimary,
      ),
      secondaryBackground: _SwipeBackground(
        direction: DismissDirection.endToStart,
        icon: Icons.delete_rounded,
        color: colors.error,
        iconColor: colors.onError,
      ),
      child: Material(
        color: colors.surface,
        borderRadius: InteractionLayoutConstants.tileBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: InteractionLayoutConstants.tileBorderRadius,
          child: Ink(
            decoration: BoxDecoration(
              color: colors.surface,
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
                  InteractionTypeIcon(type: data.type),
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
                    onSelected: (action) {
                      switch (action) {
                        case InteractionTileAction.edit:
                          onEdit();
                        case InteractionTileAction.delete:
                          onDelete();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
        ActionChip(
          label: Text(
            labels.item.openOpportunity,
            style: textStyles.labelSmall.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: onOpenOpportunity,
          backgroundColor: colors.primaryContainer,
          padding: EdgeInsets.symmetric(
            horizontal: InteractionLayoutConstants.chipHorizontalPadding,
            vertical: AppSpacing.xxs,
          ),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderFull),
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

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.direction,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  final DismissDirection direction;
  final IconData icon;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: InteractionLayoutConstants.swipeActionWidth,
      decoration: BoxDecoration(
        color: color,
        borderRadius: InteractionLayoutConstants.tileBorderRadius,
      ),
      alignment: direction == DismissDirection.startToEnd
          ? Alignment.centerLeft
          : Alignment.centerRight,
      padding: EdgeInsets.symmetric(
        horizontal: InteractionLayoutConstants.tileHorizontalPadding,
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: InteractionLayoutConstants.swipeIconSize,
      ),
    );
  }
}
