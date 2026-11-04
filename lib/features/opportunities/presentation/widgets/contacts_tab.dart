import 'package:flutter/material.dart';
import 'package:orbit/core/di/injection_container.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/services/url_launcher_service.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/core/widgets/app_card.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// Contacts tab showing customer contacts with call/email actions.
class ContactsTab extends StatelessWidget {
  const ContactsTab({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final contacts = opportunity.customer.contacts;
    final t = context.t.crm.crmOpportunities.detail;

    if (contacts.isEmpty) {
      return _EmptyContacts(message: t.contactsEmpty);
    }

    // Sort: primary first (true > false)
    final sortedContacts = contacts.toList()
      ..sort((a, b) => b.isPrimary ? 1 : -1);

    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: sortedContacts
          .map(
            (contact) =>
                _ContactCard(contact: contact, isPrimary: contact.isPrimary),
          )
          .toList(),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.contact, required this.isPrimary});

  final dynamic contact;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        padding: EdgeInsets.all(OpportunityLayoutConstants.contactCardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: OpportunityLayoutConstants.contactAvatarSize / 2,
                  backgroundColor: context.colors.primaryContainer,
                  child: Text(
                    _initials(contact.name),
                    style: textStyles.titleSmall.copyWith(
                      color: context.colors.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            contact.name,
                            style: textStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isPrimary) ...[
                            SizedBox(width: AppSpacing.xs),
                            _PrimaryBadge(),
                          ],
                        ],
                      ),
                      if (contact.jobTitle.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          contact.jobTitle,
                          style: textStyles.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (contact.phone.isNotEmpty) ...[
                  Expanded(
                    child: AppButton.outlined(
                      label: context.t.crm.common.call,
                      icon: const Icon(Icons.phone_rounded),
                      onPressed: () => _launchPhone(context, contact.phone),
                      minimumSize: Size(
                        double.infinity,
                        OpportunityLayoutConstants.contactButtonSize,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                ],
                if (contact.email.isNotEmpty) ...[
                  Expanded(
                    child: AppButton.outlined(
                      label: context.t.crm.common.email,
                      icon: const Icon(Icons.email_rounded),
                      onPressed: () => _launchEmail(context, contact.email),
                      minimumSize: Size(
                        double.infinity,
                        OpportunityLayoutConstants.contactButtonSize,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final launcher = getIt<UrlLauncherService>();
    final uri = Uri.parse('tel:$phone');
    await launcher.launchUrl(uri);
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    final launcher = getIt<UrlLauncherService>();
    final uri = Uri.parse('mailto:$email');
    await launcher.launchUrl(uri);
  }
}

class _PrimaryBadge extends StatelessWidget {
  const _PrimaryBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final t = context.t.crm.crmOpportunities.detail;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: AppRadius.borderSm,
      ),
      child: Text(
        t.contacts.primary,
        style: context.textStyles.labelSmall.copyWith(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyContacts extends StatelessWidget {
  const _EmptyContacts({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 64,
              color: colors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: context.textStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
