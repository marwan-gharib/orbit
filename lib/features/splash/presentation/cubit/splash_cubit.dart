import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit/core/utils/api_result.dart';

import '../../domain/usecases/check_startup_status_usecase.dart';
import '../../domain/entities/splash_state_entity.dart';
import '../view_models/splash_view_model.dart';
import '../mappers/splash_mapper.dart';
import 'splash_state.dart';

/// Cubit managing splash screen state.
/// Runs startup checks in parallel with the 4000ms animation.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._checkStartupStatus) : super(const SplashLoading());

  final CheckStartupStatusUseCase _checkStartupStatus;

  bool _animationCompleted = false;
  bool _initCompleted = false;
  SplashViewModel? _pendingViewModel;

  /// Called when the 4000ms animation completes.
  void onAnimationComplete() {
    _animationCompleted = true;
    _tryNavigate();
  }

  /// Initializes startup checks (auth token + onboarding flag).
  Future<void> initialize() async {
    final result = await _checkStartupStatus();
    if (isClosed) return;

    switch (result) {
      case Success<SplashStateEntity>():
        _pendingViewModel = result.data.toViewModel();
        _initCompleted = true;
        _tryNavigate();
      case ResultFailure<SplashStateEntity>():
        emit(SplashError(result.failure));
    }
  }

  /// Emits SplashReady when both animation and init are done.
  void _tryNavigate() {
    if (isClosed) return;
    if (_animationCompleted && _initCompleted && _pendingViewModel != null) {
      emit(SplashReady(_pendingViewModel!));
    }
  }
}
