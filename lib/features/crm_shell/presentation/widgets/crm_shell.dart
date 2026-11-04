import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:orbit/core/animations/selection/selection.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/features/interactions/presentation/widgets/interactions_feed_view.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunities_tab_view.dart';

/// The CRM shell screen with tab bar and preserved tab state.
class CrmShell extends StatefulWidget {
  const CrmShell({super.key});

  @override
  State<CrmShell> createState() => _CrmShellState();
}

class _CrmShellState extends State<CrmShell>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _pushDetail(int opportunityId) {
    context.push('/crm/opportunities/$opportunityId');
  }

  @override
  Widget build(BuildContext context) {
    final labels = context.t.crm;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: context.colors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(labels.title),
        elevation: 0,
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.textPrimary,
      ),
      body: Column(
        children: [
          _TabBar(controller: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OpportunitiesTabView(onOpenOpportunity: _pushDetail),
                InteractionsFeedView(onOpenOpportunity: _pushDetail),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Segmented tab bar with sliding pill indicator using [AnimatedChipSelector].
class _TabBar extends StatelessWidget {
  const _TabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final labels = context.t.crm.tabs;

    return AnimatedChipSelector<int>(
      items: [
        ChipItem<int>(value: 0, label: labels.opportunities),
        ChipItem<int>(value: 1, label: labels.interactions),
      ],
      selectedValue: controller.index,
      onChanged: (value) => controller.animateTo(value),
      scrollable: false,
    );
  }
}
