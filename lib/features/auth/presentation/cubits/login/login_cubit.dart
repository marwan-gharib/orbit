import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/params/login_params.dart';
import '../../../domain/usecases/login_usecase.dart';
import 'login_state.dart';

/// Drives the sign-in flow: one usecase call per submission, data/failure
/// only in states (no UI strings, no navigation — ERR-3/4, NAV-3).
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._loginUseCase) : super(const LoginInitial());

  final LoginUseCase _loginUseCase;

  Future<void> login({required String email, required String password}) async {
    if (state is LoginLoading) return;
    emit(const LoginLoading());

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(LoginError(failure)),
      (session) => emit(LoginSuccess(session)),
    );
  }
}
