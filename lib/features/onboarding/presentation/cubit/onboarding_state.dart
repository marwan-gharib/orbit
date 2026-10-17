import 'package:equatable/equatable.dart';
import 'package:orbit/core/errors/failures.dart';

import '../../domain/entities/onboarding_page.dart';

/// Sealed state hierarchy for the onboarding flow.
sealed class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// Initial state — the page list is being loaded.
final class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

/// Pages loaded; [currentIndex] is the visible slide.
final class OnboardingSuccess extends OnboardingState {
  const OnboardingSuccess({required this.pages, required this.currentIndex});

  final List<OnboardingPage> pages;
  final int currentIndex;

  bool get isLastPage => pages.isNotEmpty && currentIndex == pages.length - 1;

  @override
  List<Object?> get props => [pages, currentIndex];
}

/// The page list failed to load; the screen renders the localized failure
/// text (ERR-4).
final class OnboardingError extends OnboardingState {
  const OnboardingError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Onboarding completed (Get started or Skip) — triggers navigation via
/// BlocListener.
final class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();

  @override
  List<Object?> get props => [];
}
