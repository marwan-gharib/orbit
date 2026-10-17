import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit/core/utils/api_result.dart';

import '../../domain/entities/onboarding_page.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';
import '../../domain/usecases/get_onboarding_pages_usecase.dart';
import 'onboarding_state.dart';

/// Cubit managing onboarding page state and completion. Pure Dart (STATE-7):
/// the screen owns the [PageController], haptics, and screen-reader
/// announcements.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._getPages, this._completeOnboarding)
    : super(const OnboardingLoading());

  final GetOnboardingPagesUseCase _getPages;
  final CompleteOnboardingUseCase _completeOnboarding;

  /// Loads the static page list; called once by the route builder.
  Future<void> loadPages() async {
    final result = await _getPages();
    if (isClosed) return;

    switch (result) {
      case Success<List<OnboardingPage>>():
        emit(OnboardingSuccess(pages: result.data, currentIndex: 0));
      case ResultFailure<List<OnboardingPage>>():
        emit(OnboardingError(result.failure));
    }
  }

  /// Called when the PageView reports a page change (swipe or button).
  void onPageChanged(int index) {
    switch (state) {
      case OnboardingSuccess(:final pages, :final currentIndex):
        if (index == currentIndex || index < 0 || index >= pages.length) {
          return;
        }
        emit(OnboardingSuccess(pages: pages, currentIndex: index));
      case OnboardingLoading():
      case OnboardingError():
      case OnboardingCompleted():
        return;
    }
  }

  /// Completes onboarding: persists the flag, then emits completion.
  Future<void> complete() async {
    await _completeOnboarding();
    // Ignore failure for now — navigation still proceeds (user can retry on
    // next launch).
    if (isClosed) return;
    emit(const OnboardingCompleted());
  }
}
