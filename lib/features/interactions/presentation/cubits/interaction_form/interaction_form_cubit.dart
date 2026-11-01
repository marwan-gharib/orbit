import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orbit/core/utils/api_result.dart';

import '../../../domain/entities/interaction_context.dart';
import '../../../domain/entities/interaction_entity.dart';
import '../../../domain/params/add_interaction_params.dart';
import '../../../domain/params/update_interaction_params.dart';
import '../../../domain/usecases/add_interaction_usecase.dart';
import '../../../domain/usecases/update_interaction_usecase.dart';
import 'interaction_form_state.dart';

/// Drives the interaction form: one-shot add or edit submit. The owning
/// context (customer/opportunity) is captured here at [startEdit] and only
/// feeds the change signal — it is never part of the wire payload.
class InteractionFormCubit extends Cubit<InteractionFormState> {
  InteractionFormCubit(this._addInteraction, this._updateInteraction)
    : super(const InteractionFormInitial());

  final AddInteractionUseCase _addInteraction;
  final UpdateInteractionUseCase _updateInteraction;

  /// Set on [startEdit]; the context the edited interaction lives in. A
  /// submit without a started edit does nothing (the UI only opens the form
  /// through [startAdd]/[startEdit]).
  InteractionContext? _editingContext;

  void startAdd() {
    _editingContext = null;
    emit(const InteractionFormReady(existing: null));
  }

  void startEdit(Interaction interaction) {
    _editingContext = InteractionContext(
      customerId: interaction.customerId,
      opportunityId: interaction.opportunityId,
    );
    emit(InteractionFormReady(existing: interaction));
  }

  Future<void> submitNew(AddInteractionParams params) async {
    if (state is InteractionFormSubmitting) return;
    emit(const InteractionFormSubmitting(isEdit: false));

    final result = await _addInteraction(params);
    if (isClosed) return;
    _emitOutcome(result, isEdit: false);
  }

  Future<void> submitUpdate(UpdateInteractionParams params) async {
    final context = _editingContext;
    if (context == null || state is InteractionFormSubmitting) return;
    emit(const InteractionFormSubmitting(isEdit: true));

    final result = await _updateInteraction(params, context: context);
    if (isClosed) return;
    _emitOutcome(result, isEdit: true);
  }

  void _emitOutcome(ApiResult<void> result, {required bool isEdit}) =>
      result.fold(
        (failure) => emit(InteractionFormSubmitError(failure)),
        (_) => emit(InteractionFormSuccess(isEdit: isEdit)),
      );
}
