import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/widgets/app_text_field.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_bloc.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_event.dart';
import 'package:orbit/features/interactions/presentation/blocs/interactions_list/interactions_list_state.dart';

/// Search field + type filter chips for the interactions feed.
class InteractionsFeedHeader extends StatelessWidget {
  const InteractionsFeedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InteractionsListBloc, InteractionsListState>(
      builder: (context, state) {
        final criteria = state.criteria;
        final hasActiveFilters =
            criteria.searchText?.isNotEmpty == true || criteria.type != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SearchField(
              initialValue: criteria.searchText ?? '',
              hintText: context.t.crm.crmInteractions.searchHint,
              onChanged: (text) => context.read<InteractionsListBloc>().add(
                InteractionsListSearchChanged(text),
              ),
              onClear: () => context.read<InteractionsListBloc>().add(
                const InteractionsListSearchChanged(''),
              ),
              showProgress: state is InteractionsListLoading,
            ),
            SizedBox(height: AppSpacing.md),
            _TypeChipRow(
              selectedType: criteria.type,
              onChanged: (type) => context.read<InteractionsListBloc>().add(
                InteractionsListFiltersChanged(type: type),
              ),
              hasActiveFilters: hasActiveFilters,
              onClearFilters: hasActiveFilters
                  ? () {
                      context.read<InteractionsListBloc>().add(
                        const InteractionsListSearchChanged(''),
                      );
                      context.read<InteractionsListBloc>().add(
                        const InteractionsListFiltersChanged(type: null),
                      );
                    }
                  : null,
            ),
          ],
        );
      },
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.initialValue,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    required this.showProgress,
  });

  final String initialValue;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool showProgress;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: AppTextField(
            controller: _controller,
            hint: widget.hintText,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _controller.clear();
                      widget.onClear();
                      widget.onChanged('');
                    },
                  )
                : null,
            onChanged: widget.onChanged,
            label: context.t.crm.crmInteractions.searchHint,
          ),
        ),
        if (widget.showProgress) ...[
          SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primary,
            ),
          ),
        ],
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
