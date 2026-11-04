import 'package:flutter/material.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/utils/list_diff.dart';
import 'package:orbit/core/widgets/highlight_flash.dart';

import '../constants/interaction_layout_constants.dart';
import '../pure/date_grouping.dart' show groupInteractionsByDate;
import '../view_models/interaction_tile_data.dart';
import 'interaction_tile.dart';

/// The scrollable content of the interactions feed: grouped by date with
/// sticky headers, id-diffed tiles with arrival/edit flash and departure
/// collapse.
class InteractionsFeedContent extends StatefulWidget {
  const InteractionsFeedContent({
    super.key,
    required this.interactions,
    required this.isRefreshing,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenOpportunity,
    this.isSkeleton = false,
  });

  final List<InteractionTileData> interactions;
  final bool isRefreshing;
  final bool isSkeleton;
  final ValueChanged<InteractionTileData> onEdit;
  final ValueChanged<InteractionTileData> onDelete;
  final ValueChanged<int> onOpenOpportunity;

  @override
  State<InteractionsFeedContent> createState() =>
      _InteractionsFeedContentState();
}

class _InteractionsFeedContentState extends State<InteractionsFeedContent> {
  final Map<int, int> _flashTokens = {};
  List<_DepartedTile> _departed = const [];

  @override
  void didUpdateWidget(covariant InteractionsFeedContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSkeleton || oldWidget.isSkeleton) return;

    final diff = diffList<int>(
      previous: [for (final t in oldWidget.interactions) t.id],
      next: [for (final t in widget.interactions) t.id],
      keyOf: (id) => id,
    );

    final previousById = {for (final t in oldWidget.interactions) t.id: t};
    final addedIds = diff.added.toSet();
    for (final tile in widget.interactions) {
      final previous = previousById[tile.id];
      final isChanged =
          previous != null &&
          (previous.subject != tile.subject ||
              previous.description != tile.description);
      if (addedIds.contains(tile.id) || isChanged) {
        _flashTokens[tile.id] = (_flashTokens[tile.id] ?? 0) + 1;
      }
    }

    if (diff.removed.isNotEmpty) {
      final previousPositions = {
        for (var i = 0; i < oldWidget.interactions.length; i++)
          oldWidget.interactions[i].id: i,
      };
      final nextIds = {for (final t in widget.interactions) t.id};
      final merged = [
        ..._departed.where((entry) => !nextIds.contains(entry.tile.id)),
        for (final tileId in diff.removed)
          if (previousById[tileId] case final tile?)
            _DepartedTile(
              tile: tile,
              position:
                  previousPositions[tileId] ?? oldWidget.interactions.length,
            ),
      ];
      _departed = merged.length > InteractionLayoutConstants.maxDepartingRows
          ? merged.sublist(
              merged.length - InteractionLayoutConstants.maxDepartingRows,
            )
          : merged;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSkeleton) {
      return _buildSkeleton(context);
    }

    if (widget.interactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final groups = groupInteractionsByDate(
      widget.interactions,
      today: DateTime.now(),
    );

    final entries = _buildEntries(groups);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isRefreshing) ...[
          const AnimatedProgressBar(),
          SizedBox(height: AppSpacing.sm),
        ],
        ...entries,
      ],
    );
  }

  List<Widget> _buildEntries(Map<String, List<InteractionTileData>> groups) {
    final entries = <Widget>[];
    var groupIndex = 0;

    for (final groupEntry in groups.entries) {
      final label = groupEntry.key;
      final tiles = groupEntry.value;

      entries.add(
        _StickyGroupHeader(key: ValueKey('group-header-$label'), label: label),
      );

      for (var i = 0; i < tiles.length; i++) {
        final tile = tiles[i];
        final isLastInGroup = i == tiles.length - 1;
        entries.add(_buildTileEntry(tile, isLastInGroup, groupIndex));
      }

      groupIndex++;
    }

    // Add departed tiles at the end
    for (final departed in _departed) {
      entries.add(
        _CollapsingTile(
          key: ValueKey('tile-departing-${departed.tile.id}'),
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  bottom: InteractionLayoutConstants.tileVerticalPadding,
                ),
                child: InteractionTile(
                  data: departed.tile,
                  onEdit: () => widget.onEdit(departed.tile),
                  onDelete: () => widget.onDelete(departed.tile),
                  onOpenOpportunity: departed.tile.opportunityId != null
                      ? () => widget.onOpenOpportunity(
                          departed.tile.opportunityId!,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return entries;
  }

  Widget _buildTileEntry(
    InteractionTileData tile,
    bool isLastInGroup,
    int groupIndex,
  ) {
    final gap = isLastInGroup
        ? 0.0
        : InteractionLayoutConstants.tileVerticalPadding;

    return StaggeredListItem(
      key: ValueKey('tile-${tile.id}'),
      index: groupIndex * 100 + tile.id,
      child: Padding(
        padding: EdgeInsetsDirectional.only(bottom: gap),
        child: HighlightFlash(
          token: _flashTokens[tile.id],
          borderRadius: InteractionLayoutConstants.tileBorderRadius,
          child: InteractionTile(
            data: tile,
            onEdit: () => widget.onEdit(tile),
            onDelete: () => widget.onDelete(tile),
            onOpenOpportunity: tile.opportunityId != null
                ? () => widget.onOpenOpportunity(tile.opportunityId!)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < InteractionLayoutConstants.skeletonRows; i++) ...[
          if (i > 0)
            SizedBox(height: InteractionLayoutConstants.skeletonRowGap),
          _SkeletonGroupRow(),
        ],
      ],
    );
  }
}

class _StickyGroupHeader extends StatelessWidget {
  const _StickyGroupHeader({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    String displayLabel;
    if (label == 'crm.common.today') {
      displayLabel = context.t.crm.common.today;
    } else if (label == 'crm.common.yesterday') {
      displayLabel = context.t.crm.common.yesterday;
    } else {
      displayLabel = label;
    }

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: InteractionLayoutConstants.groupHeaderTopGap,
        bottom: InteractionLayoutConstants.groupHeaderPadding,
        start: InteractionLayoutConstants.tileHorizontalPadding,
        end: InteractionLayoutConstants.tileHorizontalPadding,
      ),
      child: Text(
        displayLabel,
        style: textStyles.labelLarge.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SkeletonGroupRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: InteractionLayoutConstants.groupHeaderTopGap,
        bottom: InteractionLayoutConstants.groupHeaderPadding,
        start: InteractionLayoutConstants.tileHorizontalPadding,
        end: InteractionLayoutConstants.tileHorizontalPadding,
      ),
      child: ShimmerBox.textLine(
        width: InteractionLayoutConstants.typeIconSize * 3,
        height: context.textStyles.labelLarge.fontSize,
      ),
    );
  }
}

class _CollapsingTile extends StatefulWidget {
  const _CollapsingTile({super.key, required this.child});

  final Widget child;

  @override
  State<_CollapsingTile> createState() => _CollapsingTileState();
}

class _CollapsingTileState extends State<_CollapsingTile> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) =>
      AnimatedVisibility(visible: _visible, child: widget.child);
}

class _DepartedTile {
  const _DepartedTile({required this.tile, required this.position});

  final InteractionTileData tile;
  final int position;
}
