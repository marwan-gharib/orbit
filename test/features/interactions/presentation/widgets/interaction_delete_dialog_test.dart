import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocProvider;
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/core/widgets/app_dialog.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_delete/interaction_delete_cubit.dart';
import 'package:orbit/features/interactions/presentation/cubits/interaction_delete/interaction_delete_state.dart';
import 'package:orbit/features/interactions/presentation/widgets/interaction_delete_dialog.dart';

import '../../test_helpers.dart';

class _MockDeleteCubit extends MockBloc<void, InteractionDeleteState>
    implements InteractionDeleteCubit {
  @override
  Future<void> delete({
    required int interactionId,
    required int customerId,
    int? opportunityId,
  }) async {
    return Future<void>.value();
  }
}

void main() {
  group('InteractionDeleteDialog', () {
    late _MockDeleteCubit deleteCubit;

    setUp(() {
      deleteCubit = _MockDeleteCubit();
      registerFallbackValue(InteractionDeleteInProgress(1));
      registerFallbackValue(const InteractionDeleteInitial());
      registerFallbackValue(InteractionDeleteSuccess(1));
      registerFallbackValue(InteractionDeleteFailure(1, ServerFailure(message: 'error')));
    });

    Future<void> pumpDialog(WidgetTester tester, {
      required InteractionDeleteState initialState,
    }) async {
      whenListen(
        deleteCubit,
        Stream.value(initialState),
        initialState: initialState,
      );

      await pumpWidget(
        tester,
        BlocProvider<InteractionDeleteCubit>.value(
          value: deleteCubit,
          child: InteractionDeleteDialog(
            interactionId: 1,
            customerId: 1,
            opportunityId: 2,
          ),
        ),
      );
    }

    testWidgets('shows confirmation dialog with title and body',
        (WidgetTester tester) async {
      await pumpDialog(tester, initialState: const InteractionDeleteInitial());

      expect(find.byType(AppDialog), findsOneWidget);
      expect(find.text('Delete interaction?'), findsOneWidget);
      expect(find.text('This interaction will be removed permanently.'), findsOneWidget);
    });

    testWidgets('confirm button shows delete label and is destructive',
        (WidgetTester tester) async {
      await pumpDialog(tester, initialState: const InteractionDeleteInitial());

      expect(find.widgetWithText(AppButton, 'Delete'), findsOneWidget);
      final deleteButton = tester.widget<AppButton>(find.widgetWithText(AppButton, 'Delete'));
      expect(deleteButton.destructive, isTrue);
    });

    testWidgets('cancel button closes dialog',
        (WidgetTester tester) async {
      await pumpDialog(tester, initialState: const InteractionDeleteInitial());

      await tester.tap(find.widgetWithText(AppButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.byType(AppDialog), findsNothing);
    });
  });
}