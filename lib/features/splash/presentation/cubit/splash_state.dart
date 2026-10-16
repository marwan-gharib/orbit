import 'package:equatable/equatable.dart';

import 'package:orbit/core/errors/failures.dart';

import '../view_models/splash_view_model.dart';

/// Sealed state hierarchy for the splash screen.
sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// Initial state — animation running, startup checks in progress.
final class SplashLoading extends SplashState {
  const SplashLoading();
}

/// Startup checks complete, animation may still be running or done.
/// Holds the view model with routing decision.
final class SplashReady extends SplashState {
  const SplashReady(this.viewModel);

  final SplashViewModel viewModel;

  @override
  List<Object?> get props => [viewModel];
}

/// Startup checks failed; the screen renders the localized failure text.
final class SplashError extends SplashState {
  const SplashError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
