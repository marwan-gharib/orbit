import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/interaction_context.dart';
import '../../../domain/entities/interaction_entity.dart';
import '../../../domain/usecases/delete_interaction_usecase.dart';
import 'interaction_delete_state.dart';

/// Drives one interaction delete: the owning context is built from the
/// entity (never serialized — it only feeds the change signal).
class InteractionDeleteCubit extends Cubit<InteractionDeleteState> {
  InteractionDeleteCubit(this._deleteInteraction)
    : super(const InteractionDeleteInitial());

  final DeleteInteractionUseCase _deleteInteraction;

  Future<void> delete(Interaction interaction) async {
    if (state is InteractionDeleteInProgress) return;
    emit(InteractionDeleteInProgress(interaction.interactionId));

    final result = await _deleteInteraction(
      interaction.interactionId,
      context: InteractionContext(
        customerId: interaction.customerId,
        opportunityId: interaction.opportunityId,
      ),
    );
    if (isClosed) return;

    result.fold(
      (failure) =>
          emit(InteractionDeleteFailure(interaction.interactionId, failure)),
      (_) => emit(InteractionDeleteSuccess(interaction.interactionId)),
    );
  }
}
