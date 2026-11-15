import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/widgets/app_text_field.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_bloc.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_event.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_state.dart';

/// Search field + type filter chips for the interactions feed.
///
/// Owns the search controller so "clear filters" (from anywhere) can empty
/// the field: when the bloc's search text becomes empty while the field still
/// shows text the user did not just type, the field is cleared.
class InteractionsFeedHeader extends StatefulWidget {
  const InteractionsFeedHeader({super.key});

  @override
  State<InteractionsFeedHeader> createState() => _InteractionsFeedHeaderState();
}

class _InteractionsFeedHeaderState extends State<InteractionsFeedHeader> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<InteractionsListBloc>();

    return BlocConsumer<InteractionsListBloc, InteractionsListState>(
      // Only a clear-all (criteria without text and type) empties the field.
      listenWhen: (previous, current) =>
          previous.criteria != current.criteria &&
          current.criteria.searchText == null &&
          current.criteria.type == null,
      listener: (context, state) => _controller.clear(),
      builder: (context, state) {
        final criteria = state.criteria;
        final hasActiveFilters =
            criteria.searchText?.isNotEmpty == true || criteria.type != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SearchField(
              controller: _controller,
              onChanged: (text) =>
                  bloc.add(InteractionsListSearchChanged(text)),
              showProgress: state is InteractionsListLoading,
            ),
            SizedBox(height: AppSpacing.md),
            _TypeChipRow(
              selectedType: criteria.type,
              onChanged: (type) => bloc.add(
                InteractionsListFiltersChanged(
                  type: type,
                  customerId: criteria.customerId,
                  contactId: criteria.contactId,
                  opportunityId: criteria.opportunityId,
                ),
              ),
              hasActiveFilters: hasActiveFilters,
              onClearFilters: hasActiveFilters
                  ? () => bloc.add(const InteractionsListFiltersCleared())
                  : null,
            ),
          ],
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.showProgress,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => AppTextField(
            controller: controller,
            label: context.t.crm.crmInteractions.searchHint,
            hint: context.t.crm.crmInteractions.searchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
                    tooltip: context.t.crm.common.a11y.clearSearch,
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
            onChanged: onChanged,
          ),
        ),
        // Thin progress line instead of a spinner squeezed beside the field.
        AnimatedVisibility(
          visible: showProgress,
          child: Padding(
            padding: EdgeInsetsDirectional.only(top: AppSpacing.xs),
            child: const AnimatedProgressBar(),
          ),
        ),
      ],
    );
  }
}

class _TypeChipRow extends StatelessWidget {
  const _TypeChipRow({
    required this.selectedType,
    required this.onChanged,
    required this.hasActiveFilters,
    this.onClearFilters,
  });

  final InteractionType? selectedType;
  final void Function(InteractionType?) onChanged;
  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    final labels = context.t.crm.crmInteractions;

    return AnimatedChipSelector<InteractionType?>(
      items: [
        ChipItem<InteractionType?>(value: null, label: labels.type.all),
        ChipItem<InteractionType?>(
          value: InteractionType.call,
          label: labels.type.call,
          icon: Icons.call_rounded,
        ),
        ChipItem<InteractionType?>(
          value: InteractionType.email,
          label: labels.type.email,
          icon: Icons.email_rounded,
        ),
        ChipItem<InteractionType?>(
          value: InteractionType.meeting,
          label: labels.type.meeting,
          icon: Icons.meeting_room_rounded,
        ),
      ],
      selectedValue: selectedType,
      onChanged: onChanged,
      scrollable: true,
    );
  }
}
