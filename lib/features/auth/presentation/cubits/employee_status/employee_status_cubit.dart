import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_employee_status_usecase.dart';
import 'employee_status_state.dart';

/// Drives the employee-status check: one usecase call per lookup.
class EmployeeStatusCubit extends Cubit<EmployeeStatusState> {
  EmployeeStatusCubit(this._getEmployeeStatus)
    : super(const EmployeeStatusInitial());

  final GetEmployeeStatusUseCase _getEmployeeStatus;

  Future<void> check({required String email}) async {
    if (state is EmployeeStatusLoading) return;
    emit(const EmployeeStatusLoading());

    final result = await _getEmployeeStatus(email);
    if (isClosed) return;

    result.fold(
      (failure) => emit(EmployeeStatusError(failure)),
      (info) => emit(EmployeeStatusSuccess(info)),
    );
  }
}
