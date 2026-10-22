import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/params/signup_params.dart';
import '../../../domain/usecases/signup_usecase.dart';
import 'signup_state.dart';

/// Drives the sign-up flow: one usecase call per submission, data/failure
/// only in states.
class SignupCubit extends Cubit<SignupState> {
  SignupCubit(this._signupUseCase) : super(const SignupInitial());

  final SignupUseCase _signupUseCase;

  Future<void> signup({
    required String firstName,
    required String lastName,
    required String workEmail,
    required String password,
  }) async {
    if (state is SignupLoading) return;
    emit(const SignupLoading());

    final result = await _signupUseCase(
      SignupParams(
        firstName: firstName,
        lastName: lastName,
        workEmail: workEmail,
        password: password,
      ),
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(SignupError(failure)),
      (result) => emit(SignupSuccess(result)),
    );
  }
}
