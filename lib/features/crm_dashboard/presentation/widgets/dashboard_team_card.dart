import 'package:flutter/material.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_card.dart';

import '../../domain/entities/dashboard_salesperson_entity.dart';
import '../constants/dashboard_layout_constants.dart';
import '../pure/dashboard_insights.dart';
import 'dashboard_card_header.dart';
import 'dashboard_team_row.dart';

/// Sales team leaderboard, ranked by won revenue.
class DashboardTeamCard extends StatelessWidget {
  const DashboardTeamCard({
    super.key,
    required this.team,
    required this.currency,
  });

  final List<DashboardSalesperson> team;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final t = context.t.crm.dashboard.team;
    final ranked = rankSalesTeam(team);
    final top = ranked.isEmpty ? 0.0 : ranked.first.wonValue;

    return AppCard(
      padding: EdgeInsetsDirectional.all(DashboardLayoutConstants.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardCardHeader(title: t.title, subtitle: t.subtitle),
          SizedBox(height: AppSpacing.sm),
          if (ranked.isEmpty)
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                vertical: AppSpacing.lg,
              ),
              child: Center(
                child: Text(
                  t.empty,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            )
          else
            for (final (i, person) in ranked.indexed)
              DashboardTeamRow(
                rank: i + 1,
                person: person,
                share: shareOf(person.wonValue, top),
                currency: currency,
              ),
        ],
      ),
    );
  }
}
