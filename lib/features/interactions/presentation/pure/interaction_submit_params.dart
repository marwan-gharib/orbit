import '../../domain/enums/interaction_type.dart';
import '../../domain/params/add_interaction_params.dart';
import '../../domain/params/update_interaction_params.dart';
import '../view_models/interaction_tile_data.dart';

/// Builds the params the form cubit expects: [AddInteractionParams] in add
/// mode, [UpdateInteractionParams] in edit mode.
Object buildInteractionSubmitParams({
  required SheetMode mode,
  required InteractionType type,
  required String subject,
  required String description,
  required DateTime date,
  int? customerId,
  int? contactId,
  int? opportunityId,
  InteractionEditData? editData,
}) {
  if (mode == SheetMode.add) {
    return AddInteractionParams(
      type: type,
      subject: subject.trim(),
      description: description.trim(),
      interactionDate: date,
      customerId: customerId!,
      contactId: contactId,
      opportunityId: opportunityId,
    );
  }
  return UpdateInteractionParams(
    interactionId: editData!.interactionId,
    type: type,
    subject: subject.trim(),
    description: description.trim(),
    interactionDate: date,
  );
}
