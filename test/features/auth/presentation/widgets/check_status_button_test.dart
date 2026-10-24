import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/constants/app_consts.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/utils/api_result.dart';
import 'package:orbit/core/widgets/app_button.dart';
import 'package:orbit/features/auth/domain/entities/employee_status_info_entity.dart';
import 'package:orbit/features/auth/domain/enums/employment_status.dart';
import 'package:orbit/features/auth/domain/usecases/get_employee_status_usecase.dart';
import 'package:orbit/features/auth/presentation/cubits/employee_status/employee_status_cubit.dart';
import 'package:orbit/features/auth/presentation/widgets/check_status_button.dart';

import '../../../../core/widgets/harness.dart';

class MockGetEmployeeStatusUseCase extends Mock
    implements GetEmployeeStatusUseCase {}

void main() {
  late MockGetEmployeeStatusUseCase useCase;

  setUp(() {
    useCase = MockGetEmployeeStatusUseCase();
  });

  Future<void> pumpCheck(WidgetTester tester) async {
    final cubit = EmployeeStatusCubit(useCase);
    addTearDown(cubit.close);
    await pumpApp(
      tester,
      home: BlocProvider<EmployeeStatusCubit>.value(
        value: cubit,
        child: const CheckStatusButton(),
      ),
    );
  }

  Finder checkButton() =>
      find.widgetWithText(AppButton, t.auth.pending.checkStatus);

  group('CheckStatusButton', () {
    testWidgets('should start a status check when tapped', (tester) async {
      when(() => useCase()).thenAnswer(
        (_) async => const Success(
          EmployeeStatusInfo(
            firstName: 'Adam',
            lastName: 'Orbit',
            status: EmploymentStatus.pending,
          ),
        ),
      );
      await pumpCheck(tester);

      await tester.tap(checkButton());
      await tester.pumpAndSettle();

      verify(() => useCase()).called(1);
    });

    testWidgets('should ignore taps while a check is in flight', (
      tester,
    ) async {
      final pending = Completer<ApiResult<EmployeeStatusInfo>>();
      when(() => useCase()).thenAnswer((_) => pending.future);
      await pumpCheck(tester);

      await tester.tap(checkButton());
      await tester.pump();
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      verify(() => useCase()).called(1);

      pending.complete(
        const Success(
          EmployeeStatusInfo(
            firstName: 'Adam',
            lastName: 'Orbit',
            status: EmploymentStatus.pending,
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('should cool down after a check and re-enable after 15 s', (
      tester,
    ) async {
      when(() => useCase()).thenAnswer(
        (_) async => const Success(
          EmployeeStatusInfo(
            firstName: 'Adam',
            lastName: 'Orbit',
            status: EmploymentStatus.pending,
          ),
        ),
      );
      await pumpCheck(tester);

      await tester.tap(checkButton());
      await tester.pumpAndSettle();

      expect(find.text(t.auth.pending.cooldown), findsOneWidget);
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).onPressed,
        isNull,
      );

      await tester.pump(AppConsts.pendingCheckCooldown);
      await tester.pump();

      expect(find.text(t.auth.pending.cooldown), findsNothing);
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).onPressed,
        isNotNull,
      );
    });
  });
}
