import 'package:flutter/material.dart';
import 'package:orbit/core/animations/entrance/scale_in.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/core/widgets/app_card.dart';
import 'package:orbit/features/opportunities/domain/entities/customer_contact_entity.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// One contact: avatar, name (+ primary badge), job title, Call / Email.
/// Actions with no phone / email on the contact are not shown.
class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.contact,
    required this.onCall,
    required this.onEmail,
  });

  final CustomerContact contact;
  final VoidCallback onCall;
  final VoidCallback onEmail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final buttonSize = Size(0, OpportunityLayoutConstants.contactButtonSize);

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.md),
      child: AppCard(
        padding: EdgeInsetsDirectional.all(
          OpportunityLayoutConstants.contactCardPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: OpportunityLayoutConstants.contactAvatarSize / 2,
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    _initials(contact.name),
                    style: textStyles.titleSmall.copyWith(
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
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              contact.name,
                              style: textStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (contact.isPrimary) ...[
                            SizedBox(width: AppSpacing.xs),
                            const _PrimaryBadge(),
                          ],
                        ],
                      ),
                      if (contact.jobTitle.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          contact.jobTitle,
                          style: textStyles.bodySmall.copyWith(
                            color: colors.textSecondary,
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
            if (contact.phone.isNotEmpty || contact.email.isNotEmpty) ...[
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (contact.phone.isNotEmpty)
                    Expanded(
                      child: AppButton.outlined(
                        label: context.t.crm.common.call,
                        icon: const Icon(Icons.phone_rounded),
                        onPressed: onCall,
                        minimumSize: buttonSize,
                      ),
                    ),
                  if (contact.phone.isNotEmpty && contact.email.isNotEmpty)
                    SizedBox(width: AppSpacing.sm),
                  if (contact.email.isNotEmpty)
                    Expanded(
                      child: AppButton.outlined(
                        label: context.t.crm.common.email,
                        icon: const Icon(Icons.email_rounded),
                        onPressed: onEmail,
                        minimumSize: buttonSize,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }
}

class _PrimaryBadge extends StatelessWidget {
  const _PrimaryBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final t = context.t.crm.crmOpportunities.detail;

    return ScaleIn(
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: AppRadius.borderSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_rounded,
              size: OpportunityLayoutConstants.overviewIconSize / 2,
              color: colors.onPrimaryContainer,
            ),
            SizedBox(width: AppSpacing.xxs),
            Text(
              t.contacts.primary,
              style: context.textStyles.labelSmall.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the customer has no contacts.
class EmptyContacts extends StatelessWidget {
  const EmptyContacts({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsetsDirectional.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: OpportunityLayoutConstants.contactAvatarSize,
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
