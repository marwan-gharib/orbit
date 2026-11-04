import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/interaction_context.dart';
import '../../../domain/usecases/delete_interaction_usecase.dart';
import 'interaction_delete_state.dart';

/// Drives one interaction delete: the owning context is passed directly
/// (never serialized — it only feeds the change signal).
class InteractionDeleteCubit extends Cubit<InteractionDeleteState> {
  InteractionDeleteCubit(this._deleteInteraction)
      : super(const InteractionDeleteInitial());

  final DeleteInteractionUseCase _deleteInteraction;

  Future<void> delete({
    required int interactionId,
    required int customerId,
    int? opportunityId,
  }) async {
    if (state is InteractionDeleteInProgress) return;
    emit(InteractionDeleteInProgress(interactionId));

    final result = await _deleteInteraction(
      interactionId,
      context: InteractionContext(
        customerId: customerId,
        opportunityId: opportunityId,
      ),
    );
    if (isClosed) return;

    result.fold(
      (failure) =>
          emit(InteractionDeleteFailure(interactionId, failure)),
      (_) => emit(InteractionDeleteSuccess(interactionId)),
    );
  }
}