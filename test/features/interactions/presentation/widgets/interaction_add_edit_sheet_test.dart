import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/widgets/app_text_field.dart' show AppTextField;
import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_form/interaction_form_cubit.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_form/interaction_form_state.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_add_edit_sheet.dart';
import 'package:orbit/features/interactions/presentation/view_models/interaction_tile_data.dart'
    show InteractionTileData, SheetMode, InteractionEditData, InteractionContactOption;

import '../../test_helpers.dart';

class _MockFormCubit extends MockBloc<void, InteractionFormState>
    implements InteractionFormCubit {}

class _MockCallbacks extends Mock {
  void onSubmit(dynamic params);
}

void main() {
  group('InteractionAddEditSheet', () {
    late _MockFormCubit formCubit;
    late _MockCallbacks callbacks;
    final fixedToday = DateTime(2025, 6, 15);

    setUp(() {
      formCubit = _MockFormCubit();
      callbacks = _MockCallbacks();
      registerFallbackValue(InteractionTileData(
        id: 1,
        type: InteractionType.call,
        subject: 'Test',
        description: 'Desc',
        date: fixedToday,
      ));
      registerFallbackValue(SheetMode.add);
    });

    Future<void> pumpAddSheet(WidgetTester tester, {
      required int customerId,
      int? opportunityId,
      List<InteractionContactOption>? contacts,
      int? initialContactId,
      InteractionType? initialType,
      DateTime? initialDate,
      String? contextLabel,
    }) async {
      whenListen(
        formCubit,
        Stream.value(const InteractionFormReady(existing: null)),
        initialState: const InteractionFormReady(existing: null),
      );

      await pumpWidget(
        tester,
        BlocProvider<InteractionFormCubit>.value(
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
            onSubmit: callbacks.onSubmit,
          ),
        ),
      );
    }

    Future<void> pumpEditSheet(WidgetTester tester, {
      required InteractionEditData editData,
    }) async {
      whenListen(
        formCubit,
        Stream.value(const InteractionFormReady(existing: null)),
        initialState: const InteractionFormReady(existing: null),
      );

      await pumpWidget(
        tester,
        BlocProvider<InteractionFormCubit>.value(
          value: formCubit,
          child: InteractionAddEditSheet(
            mode: SheetMode.edit,
            customerId: editData.customerId,
            opportunityId: editData.opportunityId,
            editData: editData,
            onSubmit: callbacks.onSubmit,
          ),
        ),
      );
    }

    group('ADD mode', () {
      testWidgets('shows contact selector only in ADD mode',
          (WidgetTester tester) async {
        await pumpAddSheet(
          tester,
          customerId: 1,
          contacts: [
            InteractionContactOption(id: 1, label: 'Contact 1'),
            InteractionContactOption(id: 2, label: 'Contact 2'),
          ],
        );

        expect(find.text('Contact (optional)'), findsOneWidget);
        expect(find.byType(FilterChip), findsNWidgets(3)); // None + 2 contacts
      });

      testWidgets('contact selector NOT shown in EDIT mode',
          (WidgetTester tester) async {
        final editData = InteractionEditData(
          interactionId: 42,
          type: InteractionType.call,
          subject: 'Test',
          description: 'Desc',
          date: fixedToday,
          customerId: 1,
        );

        await pumpEditSheet(tester, editData: editData);

        // Contact selector should not be present
        expect(find.text('Contact (optional)'), findsNothing);
        expect(find.byType(FilterChip), findsNothing);
      });
    });

    group('EDIT mode', () {
      testWidgets('prefills fields with editData',
          (WidgetTester tester) async {
        final editData = InteractionEditData(
          interactionId: 42,
          type: InteractionType.email,
          subject: 'Original Subject',
          description: 'Original Description',
          date: fixedToday,
          customerId: 1,
          opportunityId: 2,
        );

        await pumpEditSheet(tester, editData: editData);

        // Subject should be prefilled
        final subjectField = tester.widget<AppTextField>(find.byType(AppTextField).first);
        expect(subjectField.controller?.text, equals('Original Subject'));

        // Description should be prefilled
        final descField = tester.widget<AppTextField>(find.byType(AppTextField).last);
        expect(descField.controller?.text, equals('Original Description'));
      });

      testWidgets('contact selector NOT shown in EDIT mode',
          (WidgetTester tester) async {
        final editData = InteractionEditData(
          interactionId: 42,
          type: InteractionType.call,
          subject: 'Test',
          description: 'Desc',
          date: fixedToday,
          customerId: 1,
        );

        await pumpEditSheet(tester, editData: editData);

        // Contact selector should not be present
        expect(find.text('Contact (optional)'), findsNothing);
        expect(find.byType(FilterChip), findsNothing);
      });
    });
  });
}