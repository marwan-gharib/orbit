import 'dart:async';

import 'package:flutter/material.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/utils/list_diff.dart';
import 'package:orbit/core/widgets/highlight_flash.dart';

import '../constants/interaction_layout_constants.dart';
import '../pure/date_grouping.dart' show groupInteractionsByDate;
import '../view_models/interaction_tile_data.dart';
import 'interaction_tile.dart';
import 'interaction_tile_skeleton.dart';
import 'interactions_group_header.dart';

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
  Set<int> _entering = {};
  Timer? _enterTimer;

  @override
  void initState() {
    super.initState();
    if (widget.isSkeleton) return;
    _entering = widget.interactions
        .take(InteractionLayoutConstants.staggerItemCap)
        .map((t) => t.id)
        .toSet();
    _enterTimer = Timer(AppDurations.extraSlow, () {
      if (mounted) setState(() => _entering = {});
    });
  }

  @override
  void dispose() {
    _enterTimer?.cancel();
    super.dispose();
  }

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
      return SliverToBoxAdapter(child: _buildSkeleton(context));
    }
    if (widget.interactions.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final groups = groupInteractionsByDate(
      widget.interactions,
      today: DateTime.now(),
    );

    return SliverMainAxisGroup(
      slivers: [
        if (widget.isRefreshing)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
              child: const AnimatedProgressBar(),
            ),
          ),
        for (final entry in groups.entries)
          SliverMainAxisGroup(
            key: ValueKey('group-${entry.key}'),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: InteractionsGroupHeaderDelegate(
                  label: entry.key,
                  count: entry.value.length,
                ),
              ),
              SliverList.builder(
                itemCount: entry.value.length,
                itemBuilder: (context, i) => _buildTileEntry(
                  entry.value[i],
                  i == entry.value.length - 1,
                ),
              ),
            ],
          ),
        if (_departed.isNotEmpty)
          SliverToBoxAdapter(child: Column(children: _departedTiles())),
      ],
    );
  }

  List<Widget> _departedTiles() => [
    for (final departed in _departed)
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
                    ? () =>
                          widget.onOpenOpportunity(departed.tile.opportunityId!)
                    : null,
              ),
            ),
          ),
        ),
      ),
  ];

  Widget _buildTileEntry(InteractionTileData tile, bool isLastInGroup) {
    final gap = isLastInGroup
        ? 0.0
        : InteractionLayoutConstants.tileVerticalPadding;

    Widget entry = Padding(
      padding: EdgeInsetsDirectional.only(bottom: gap),
      child: HighlightFlash(
        token: _flashTokens[tile.id],
        borderRadius: InteractionLayoutConstants.tileBorderRadius,
        child: InteractionTile(
          data: tile,
          showDate: false,
          onEdit: () => widget.onEdit(tile),
          onDelete: () => widget.onDelete(tile),
          onOpenOpportunity: tile.opportunityId != null
              ? () => widget.onOpenOpportunity(tile.opportunityId!)
              : null,
        ),
      ),
    );
    if (_entering.contains(tile.id)) {
      final index = widget.interactions.indexWhere((t) => t.id == tile.id);
      entry = StaggeredListItem(index: index, child: entry);
    }
    return KeyedSubtree(key: ValueKey('tile-${tile.id}'), child: entry);
  }

  Widget _buildSkeleton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var group = 0; group < 2; group++) ...[
          const InteractionGroupHeaderSkeleton(),
          InteractionTileSkeletonList(count: group == 0 ? 2 : 3),
        ],
      ],
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
