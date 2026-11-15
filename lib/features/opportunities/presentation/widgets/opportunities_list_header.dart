import 'package:flutter/material.dart';
import 'package:orbit/core/animations/loading/shimmer_box.dart';
import 'package:orbit/core/animations/loading/shimmer_scope.dart';
import 'package:orbit/core/animations/state/animated_counter.dart';
import 'package:orbit/core/animations/state/animated_visibility.dart';
import 'package:orbit/core/animations/state/app_animated_switcher.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_text_field.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// Top row of the opportunities tab: animated total count that gives way to a
/// search field when the search icon is tapped, plus the filter button with
/// its active-filters badge.
///
/// Every text change is forwarded as-is: the Bloc debounces, never the widget.
class OpportunitiesListHeader extends StatefulWidget {
  const OpportunitiesListHeader({
    super.key,
    required this.totalCount,
    required this.isLoading,
    required this.controller,
    required this.hasActiveFilters,
    required this.onSearchChanged,
    required this.onClearFilters,
  });

  final int? totalCount;

  /// True while the first page loads: the count shows a skeleton.
  final bool isLoading;

  /// Owned by the tab view so "clear filters" can empty the search field.
  final TextEditingController controller;
  final bool hasActiveFilters;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearFilters;

  @override
  State<OpportunitiesListHeader> createState() =>
      _OpportunitiesListHeaderState();
}

class _OpportunitiesListHeaderState extends State<OpportunitiesListHeader> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.controller.text.isNotEmpty;
  }

  void _collapse() {
    final hadText = widget.controller.text.isNotEmpty;
    widget.controller.clear();
    if (hadText) widget.onSearchChanged('');
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.crm.crmOpportunities;
    final hasClear = widget.hasActiveFilters && !_expanded;

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
        child: Row(
          children: [
            Expanded(
              child: AppAnimatedSwitcher(
                child: _expanded
                    ? AppTextField(
                        key: const ValueKey('search'),
                        controller: widget.controller,
                        label: context.t.crm.common.a11y.search,
                        hint: t.searchHint,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: IconButton(
                          tooltip: context.t.crm.common.a11y.clearSearch,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _collapse,
                        ),
                        onChanged: widget.onSearchChanged,
                      )
                    : _Count(
                        key: const ValueKey('count'),
                        totalCount: widget.totalCount,
                        isLoading: widget.isLoading,
                      ),
              ),
            ),
            if (!_expanded)
              IconButton(
                tooltip: context.t.crm.common.a11y.search,
                icon: const Icon(Icons.search_rounded),
                onPressed: () => setState(() => _expanded = true),
              ),
            AnimatedVisibility(
              visible: hasClear,
              axis: Axis.horizontal,
              child: TextButton.icon(
                onPressed: widget.onClearFilters,
                icon: const Icon(Icons.filter_alt_off_rounded),
                label: Text(context.t.crm.common.clearFilters),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({super.key, required this.totalCount, required this.isLoading});

  final int? totalCount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final count = totalCount;
    if (count == null) {
      if (!isLoading) return const SizedBox.shrink();
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: ShimmerScope(
          child: ShimmerBox(
            width: OpportunityLayoutConstants.countSkeletonWidth,
            height: OpportunityLayoutConstants.countSkeletonHeight,
          ),
        ),
      );
    }
    final t = context.t.crm.crmOpportunities;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: AnimatedCounter(
        value: count,
        formatter: (n) => n.round() == 1
            ? t.listOpportunityCountOne
            : t.listOpportunityCountOther(n: n.round()),
        style: context.textStyles.titleMedium,
      ),
    );
  }
}
