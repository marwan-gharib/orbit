import 'package:flutter/material.dart';
import 'package:orbit/core/animations/overlays/app_bottom_sheet.dart';
import 'package:orbit/core/animations/overlays/app_snackbar.dart';
import 'package:orbit/core/animations/staggered/staggered_list_item.dart';
import 'package:orbit/core/di/injection_container.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/services/url_launcher_service.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/presentation/widgets/helpers.dart';
import 'package:orbit/features/opportunities/domain/entities/customer_contact_entity.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/presentation/pure/contact_to_interaction_option.dart';
import 'package:orbit/features/opportunities/presentation/widgets/contact_card.dart';
import 'package:orbit/features/opportunities/presentation/widgets/log_it_prompt_sheet.dart';

/// Contacts of the opportunity's customer, primary contact first, with Call
/// and Email actions.
///
/// After a call/email is launched and the user returns to the app, a
/// dismissible "Log it?" sheet offers to open the add-interaction form
/// pre-filled with that type, contact and today's date.
class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab>
    with WidgetsBindingObserver {
  ({CustomerContact contact, InteractionType type})? _pending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _pending != null) {
      _promptToLog();
    }
  }

  Future<void> _launch(
    CustomerContact contact,
    InteractionType type,
    Uri uri,
  ) async {
    final appLabel = type == InteractionType.call
        ? context.t.crm.common.call
        : context.t.crm.common.email;
    final failureMessage = context.t.crm.common.launchFailed(app: appLabel);
    final launched = await getIt<UrlLauncherService>().launchUrl(uri);
    if (!mounted) return;
    if (launched) {
      _pending = (contact: contact, type: type);
    } else {
      AppSnackbar.show(
        context,
        message: failureMessage,
        type: AppSnackbarType.error,
      );
    }
  }

  Future<void> _promptToLog() async {
    final pending = _pending;
    _pending = null;
    if (pending == null || !mounted) return;

    final shouldLog = await AppBottomSheet.show<bool>(
      context: context,
      builder: (_) => LogItPromptSheet(type: pending.type),
    );
    if (shouldLog != true || !mounted) return;

    final opportunity = widget.opportunity;
    final customer = opportunity.customer;
    await showAddInteractionSheet(
      context,
      customerId: customer.customerId,
      opportunityId: opportunity.opportunityId,
      contacts: contactsToInteractionOptions(customer.contacts),
      initialContactId: pending.contact.contactId,
      initialType: pending.type,
      initialDate: DateTime.now(),
      contextLabel:
          '${opportunity.title} \u00b7 ${customer.firstName} ${customer.lastName}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final contacts = widget.opportunity.customer.contacts;
    if (contacts.isEmpty) {
      return EmptyContacts(
        message: context.t.crm.crmOpportunities.detail.contactsEmpty,
      );
    }

    final sorted = [
      ...contacts.where((c) => c.isPrimary),
      ...contacts.where((c) => !c.isPrimary),
    ];

    return Padding(
      padding: EdgeInsetsDirectional.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, contact) in sorted.indexed)
            StaggeredListItem(
              index: i,
              child: ContactCard(
                contact: contact,
                onCall: () => _launch(
                  contact,
                  InteractionType.call,
                  Uri(scheme: 'tel', path: contact.phone),
                ),
                onEmail: () => _launch(
                  contact,
                  InteractionType.email,
                  Uri(scheme: 'mailto', path: contact.email),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
