import 'package:flutter/material.dart';
import 'package:orbit/core/di/injection_container.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/services/url_launcher_service.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/utils/formatters.dart';
import 'package:orbit/core/widgets/app_card.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// Overview tab showing Customer card and Details card.
class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        // Customer card
        _CustomerCard(opportunity: opportunity),
        SizedBox(height: AppSpacing.lg),

        // Details card
        _DetailsCard(opportunity: opportunity),
      ],
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final c = opportunity.customer;
    final colors = context.colors;
    final textStyles = context.textStyles;
    final t = context.t.crm.crmOpportunities.detail;

    return AppCard(
      padding: EdgeInsets.all(OpportunityLayoutConstants.overviewCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Name + Company + Customer code tag
          Row(
            children: [
              CircleAvatar(
                radius: OpportunityLayoutConstants.contactAvatarSize / 2,
                backgroundColor: colors.primaryContainer,
                child: Text(
                  _initials(c.firstName, c.lastName),
                  style: textStyles.titleMedium.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${c.firstName} ${c.lastName}',
                      style: textStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (c.companyName.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        c.companyName,
                        style: textStyles.bodyMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              _CustomerCodeTag(code: c.customerCode),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // Contact rows
          _ContactRow(
            icon: Icons.phone_rounded,
            label: t.facts.phone,
            value: c.phone,
            onTap: c.phone.isNotEmpty
                ? () => _launchPhone(context, c.phone)
                : null,
          ),
          SizedBox(height: OpportunityLayoutConstants.overviewRowGap),
          _ContactRow(
            icon: Icons.email_rounded,
            label: t.facts.email,
            value: c.email,
            onTap: c.email.isNotEmpty
                ? () => _launchEmail(context, c.email)
                : null,
          ),
          SizedBox(height: OpportunityLayoutConstants.overviewRowGap),
          _ContactRow(
            icon: Icons.location_on_rounded,
            label: t.facts.address,
            value: c.address,
            onTap: null,
          ),
          if (c.leadSource != null && c.leadSource!.isNotEmpty) ...[
            SizedBox(height: OpportunityLayoutConstants.overviewRowGap),
            _ContactRow(
              icon: Icons.source_rounded,
              label: t.facts.leadSource,
              value: c.leadSource!,
              onTap: null,
            ),
          ],
        ],
      ),
    );
  }

  String _initials(String first, String last) =>
      '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}'
          .toUpperCase();

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final launcher = getIt<UrlLauncherService>();
    final uri = Uri.parse('tel:$phone');
    final launched = await launcher.launchUrl(uri);
    if (!launched && context.mounted) {
      // Snackbar handled by caller or launcher
    }
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    final launcher = getIt<UrlLauncherService>();
    final uri = Uri.parse('mailto:$email');
    final launched = await launcher.launchUrl(uri);
    if (!launched && context.mounted) {
      // Snackbar handled by caller or launcher
    }
  }
}

class _CustomerCodeTag extends StatelessWidget {
  const _CustomerCodeTag({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: AppRadius.borderSm,
      ),
      child: Text(
        code,
        style: context.textStyles.labelSmall.copyWith(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final isAction = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderSm,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        child: Row(
          children: [
            Icon(
              icon,
              size: OpportunityLayoutConstants.overviewIconSize,
              color: colors.textSecondary,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: textStyles.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: textStyles.bodyMedium.copyWith(
                      color: isAction ? colors.primary : colors.textPrimary,
                      decoration: isAction
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isAction)
              Icon(Icons.open_in_new_rounded, size: 18, color: colors.primary),
          ],
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final t = context.t.crm.crmOpportunities.detail;
    final c = opportunity.customer;

    return AppCard(
      padding: EdgeInsets.all(OpportunityLayoutConstants.overviewCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.facts.created,
            style: textStyles.labelLarge.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: AppSpacing.md),
          _DetailRow(
            label: t.facts.expectedClose,
            value: Formatters.crmDate(opportunity.expectedCloseDate),
          ),
          SizedBox(height: OpportunityLayoutConstants.overviewRowGap),
          _DetailRow(
            label: t.facts.created,
            value: Formatters.crmDate(opportunity.createdAt),
          ),
          if (opportunity.closedAt != null) ...[
            SizedBox(height: OpportunityLayoutConstants.overviewRowGap),
            _DetailRow(
              label: t.facts.closedAt,
              value: Formatters.crmDate(opportunity.closedAt!),
            ),
          ],
          SizedBox(height: OpportunityLayoutConstants.overviewRowGap),
          _DetailRow(
            label: t.facts.owner,
            value: opportunity.employee.employeeName,
          ),
          if (c.leadSource != null && c.leadSource!.isNotEmpty) ...[
            SizedBox(height: OpportunityLayoutConstants.overviewRowGap),
            _DetailRow(label: t.facts.leadSource, value: c.leadSource!),
          ],
          SizedBox(height: OpportunityLayoutConstants.overviewRowGap),
          _DetailRow(label: t.facts.customerCode, value: c.customerCode),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: textStyles.labelMedium.copyWith(color: colors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: textStyles.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
