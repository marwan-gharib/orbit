import 'dart:async';

import 'package:flutter/material.dart';
import 'package:orbit/core/animations/staggered/staggered_list_item.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/widgets/highlight_flash.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';
import 'package:orbit/features/opportunities/presentation/pure/list_highlight_ids.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunities_list_footer.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_card.dart';

/// Lazy list of opportunity cards plus the footer, as one sliver.
///
/// - First display: the first few cards play the staggered entrance, once.
/// - Silent refresh: ids that are new flash an accent highlight; cards that
///   were already shown are not re-animated. Load-more appends quietly.
class OpportunitiesListSliver extends StatefulWidget {
  const OpportunitiesListSliver({
    super.key,
    required this.items,
    required this.hasMore,
    required this.isLoadingMore,
    required this.loadMoreFailure,
    required this.onOpen,
    required this.onRetryLoadMore,
  });

  final List<Opportunity> items;
  final bool hasMore;
  final bool isLoadingMore;
  final Failure? loadMoreFailure;
  final ValueChanged<int> onOpen;
  final VoidCallback onRetryLoadMore;

  @override
  State<OpportunitiesListSliver> createState() =>
      _OpportunitiesListSliverState();
}

class _OpportunitiesListSliverState extends State<OpportunitiesListSliver> {
  Set<int> _entering = {};
  Set<int> _highlighted = const {};
  Timer? _settleTimer;

  static final Duration _settleDelay =
      AppDurations.extraSlow + AppDurations.normal;

  @override
  void initState() {
    super.initState();
    _entering = widget.items
        .take(OpportunityLayoutConstants.staggerItemCap)
        .map((o) => o.opportunityId)
        .toSet();
    _scheduleSettle();
  }

  @override
  void didUpdateWidget(covariant OpportunitiesListSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    final added = listHighlightIds(
      previous: oldWidget.items.map((o) => o.opportunityId).toList(),
      next: widget.items.map((o) => o.opportunityId).toList(),
    );
    if (added.isNotEmpty) {
      _highlighted = added;
      _scheduleSettle();
    }
  }

  void _scheduleSettle() {
    _settleTimer?.cancel();
    _settleTimer = Timer(_settleDelay, () {
      if (!mounted) return;
      setState(() {
        _entering = {};
        _highlighted = const {};
      });
    });
  }

  @override
  void dispose() {
    _settleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;

    return SliverPadding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverList.builder(
            itemCount: items.length,
            findChildIndexCallback: (key) {
              if (key is! ValueKey<int>) return null;
              final index = items.indexWhereId(key.value);
              return index < 0 ? null : index;
            },
            itemBuilder: (context, index) {
              final opportunity = items[index];
              final id = opportunity.opportunityId;
              Widget card = Padding(
                padding: EdgeInsetsDirectional.only(
                  bottom: OpportunityLayoutConstants.cardListItemGap,
                ),
                child: HighlightFlash(
                  token: _highlighted.contains(id) ? id : null,
                  borderRadius: OpportunityLayoutConstants.cardRadius,
                  child: OpportunityCard(
                    opportunity: opportunity,
                    onTap: widget.onOpen,
                  ),
                ),
              );
              if (_entering.contains(id)) {
                card = StaggeredListItem(index: index, child: card);
              }
              return KeyedSubtree(key: ValueKey<int>(id), child: card);
            },
          ),
          SliverToBoxAdapter(
            child: OpportunitiesListFooter(
              hasMore: widget.hasMore,
              isLoadingMore: widget.isLoadingMore,
              failure: widget.loadMoreFailure,
              onRetry: widget.onRetryLoadMore,
            ),
          ),
        ],
      ),
    );
  }
}

extension on List<Opportunity> {
  int indexWhereId(int id) => indexWhere((o) => o.opportunityId == id);
}
