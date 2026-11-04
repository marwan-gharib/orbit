import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';
import 'package:orbit/features/opportunities/domain/entities/customer_contact_entity.dart';

/// Maps a customer contact to an option for the add-interaction sheet.
InteractionContactOption contactToInteractionOption(CustomerContact contact) =>
    InteractionContactOption(id: contact.contactId, label: contact.name);