import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orbit/core/animations/overlays/app_bottom_sheet.dart';
import 'package:orbit/core/animations/overlays/app_dialog_route.dart';
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_form/interaction_form_cubit.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_delete/interaction_delete_cubit.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_add_edit_sheet.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_delete_dialog.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart';

/// Opens the add-interaction bottom sheet.
/// Creates a fresh InteractionFormCubit per invocation.
/// Works without an interactions Bloc in the host context.
Future<void> showAddInteractionSheet(
  BuildContext context, {
  required int customerId,
  required int opportunityId,
  required List<InteractionContactOption> contacts,
  int? initialContactId,
  InteractionType? initialType,
  DateTime? initialDate,
  String? contextLabel,
}) async {
  final formCubit = InteractionFormCubit(context.read(), context.read());

  formCubit.startAdd();

  await _showAddSheet(
    context: context,
    formCubit: formCubit,
    customerId: customerId,
    opportunityId: opportunityId,
    contacts: contacts,
    initialContactId: initialContactId,
    initialType: initialType,
    initialDate: initialDate,
    contextLabel: contextLabel,
  );
}

/// Opens the edit-interaction bottom sheet.
/// Creates a fresh InteractionFormCubit per invocation.
Future<void> showEditInteractionSheet(
  BuildContext context, {
  required InteractionEditData data,
}) async {
  final formCubit = InteractionFormCubit(context.read(), context.read());

  formCubit.startEditWithContext(
    customerId: data.customerId ?? 0,
    opportunityId: data.opportunityId,
  );

  await _showEditSheet(
    context: context,
    formCubit: formCubit,
    editData: data,
  );
}

/// Opens the delete-interaction confirmation dialog.
/// Creates a fresh InteractionDeleteCubit per invocation.
Future<void> showDeleteInteractionDialog(
  BuildContext context, {
  required int interactionId,
  int? customerId,
  int? opportunityId,
}) async {
  final deleteCubit = InteractionDeleteCubit(context.read());

  return showAppDialog<void>(
    context: context,
    builder: (context) => BlocProvider.value(
      value: deleteCubit,
      child: InteractionDeleteDialog(
        interactionId: interactionId,
        customerId: customerId,
        opportunityId: opportunityId,
      ),
    ),
  );
}

Future<void> _showAddSheet({
  required BuildContext context,
  required InteractionFormCubit formCubit,
  required int customerId,
  required int opportunityId,
  required List<InteractionContactOption> contacts,
  int? initialContactId,
  InteractionType? initialType,
  DateTime? initialDate,
  String? contextLabel,
}) async {
  await AppBottomSheet.show(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => BlocProvider.value(
      value: formCubit,
      child: InteractionAddEditSheet(
        mode: SheetMode.add,
        customerId: customerId,
        opportunityId: opportunityId,
        contacts: contacts,
        initialContactId: initialContactId,
        initialType: initialType,
        initialDate: initialDate,
        contextLabel: contextLabel,
        onSubmit: (params) => formCubit.submitNew(params),
      ),
    ),
  );
}

Future<void> _showEditSheet({
  required BuildContext context,
  required InteractionFormCubit formCubit,
  required InteractionEditData editData,
}) async {
  await AppBottomSheet.show(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => BlocProvider.value(
      value: formCubit,
      child: InteractionAddEditSheet(
        mode: SheetMode.edit,
        customerId: editData.customerId,
        opportunityId: editData.opportunityId,
        editData: editData,
        onSubmit: (params) => formCubit.submitUpdate(params),
      ),
    ),
  );
}