import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit/core/animations/animations.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/router/route_names.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/widgets/error_state.dart';
import 'package:orbit/features/onboarding/presentation/constants/onboarding_layout_constants.dart';
import 'package:orbit/features/onboarding/presentation/cubit/onboarding_constants.dart';
import 'package:orbit/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:orbit/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:orbit/features/onboarding/presentation/mappers/onboarding_page_mapper.dart';
import 'package:orbit/features/onboarding/presentation/view_models/onboarding_page_view_model.dart';
import 'package:orbit/features/onboarding/presentation/widgets/background/onboarding_background.dart';
import 'package:orbit/features/onboarding/presentation/widgets/onboarding_nav_buttons.dart';
import 'package:orbit/features/onboarding/presentation/widgets/onboarding_page_view.dart';
import 'package:orbit/features/onboarding/presentation/widgets/onboarding_skip_button.dart';

/// Onboarding screen — 4 slides with swipe navigation, animated transitions,
/// skip button, page indicator, and morphing next/get-started button.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingCubit _cubit;
  late final PageController _pageController;

  /// Guards rapid taps while a programmatic page animation is running.
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<OnboardingCubit>();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int? _indexOf(OnboardingState state) => switch (state) {
    OnboardingSuccess(:final currentIndex) => currentIndex,
    OnboardingLoading() || OnboardingError() || OnboardingCompleted() => null,
  };

  /// React to completion and to actual page changes (not the initial load).
  bool _shouldReact(OnboardingState previous, OnboardingState current) {
    final previousIndex = _indexOf(previous);
    return switch (current) {
      OnboardingCompleted() => true,
      OnboardingSuccess(:final currentIndex) =>
        previousIndex != null && previousIndex != currentIndex,
      OnboardingLoading() || OnboardingError() => false,
    };
  }

  void _onStateEffect(BuildContext context, OnboardingState state) {
    switch (state) {
      case OnboardingCompleted():
        // Replaces the route stack so back never returns to onboarding.
        context.goNamed(RouteNames.login);
      case OnboardingSuccess(:final currentIndex, :final pages):
        AppHaptics.selection();
        SemanticsService.sendAnnouncement(
          View.of(context),
          context.t.onboarding.a11y.pageIndicator(
            current: currentIndex + 1,
            total: pages.length,
          ),
          Directionality.of(context),
        );
      case OnboardingLoading():
      case OnboardingError():
        break;
    }
  }

  Future<void> _animateToPage(int index) async {
    if (_isAnimating) return;
    _isAnimating = true;
    await _pageController.animateToPage(
      index,
      duration: OnboardingAnimationTimings.entranceTotal,
      curve: OnboardingAnimationTimings.entranceCurve,
    );
    _isAnimating = false;
  }

  void _handleNext() {
    if (_isAnimating) return;
    switch (_cubit.state) {
      case OnboardingSuccess(isLastPage: true):
        _cubit.complete();
      case OnboardingSuccess(:final currentIndex):
        _animateToPage(currentIndex + 1);
      case OnboardingLoading():
      case OnboardingError():
      case OnboardingCompleted():
        break;
    }
  }

  void _handleBack() {
    if (_isAnimating) return;
    switch (_cubit.state) {
      case OnboardingSuccess(:final currentIndex) when currentIndex > 0:
        _animateToPage(currentIndex - 1);
      case OnboardingSuccess():
      case OnboardingLoading():
      case OnboardingError():
      case OnboardingCompleted():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listenWhen: _shouldReact,
      listener: _onStateEffect,
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (context, state) => PopScope(
          // Standard Android back: on the first slide the pop bubbles up and
          // exits the app; on later slides it is intercepted into a step back.
          // State-driven (inside the builder) so canPop follows the page.
          canPop: switch (_indexOf(state)) {
            null || 0 => true,
            _ => false,
          },
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              _handleBack();
            }
          },
          child: switch (state) {
            OnboardingLoading() => const _OnboardingLoadingView(),
            OnboardingError(:final failure) => _OnboardingErrorView(
              failure: failure,
            ),
            OnboardingSuccess(:final pages, :final currentIndex) =>
              _OnboardingBody(
                viewModels: [
                  for (final page in pages) page.toViewModel(context.t),
                ],
                currentIndex: currentIndex,
                isLastPage: currentIndex == pages.length - 1,
                pageController: _pageController,
                onPageChanged: _cubit.onPageChanged,
                onNext: _handleNext,
                onBack: _handleBack,
                onSkip: _cubit.complete,
                onIndicatorTap: _animateToPage,
              ),
            OnboardingCompleted() =>
              const SizedBox.shrink(), // navigation handled in the listener
          },
        ),
      ),
    );
  }
}

/// Loading placeholder while the static page list resolves.
class _OnboardingLoadingView extends StatelessWidget {
  const _OnboardingLoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: const SizedBox.shrink(),
    );
  }
}

/// Page list failed to load — shows the localized failure text (ERR-4).
class _OnboardingErrorView extends StatelessWidget {
  const _OnboardingErrorView({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: ErrorState(message: context.failureText(failure)),
    );
  }
}

/// Single layout root: background, then top bar / page area / indicator +
/// controls bands, all proportional to the SafeArea size.
class _OnboardingBody extends StatelessWidget {
  const _OnboardingBody({
    required this.viewModels,
    required this.currentIndex,
    required this.isLastPage,
    required this.pageController,
    required this.onPageChanged,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    required this.onIndicatorTap,
  });

  final List<OnboardingPageViewModel> viewModels;
  final int currentIndex;
  final bool isLastPage;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final ValueChanged<int> onIndicatorTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Stack(
        children: [
          // Layer 0: animated background blobs, clipped to the screen.
          Positioned.fill(
            child: RepaintBoundary(
              child: ClipRect(
                child: OnboardingBackground(pageValue: currentIndex.toDouble()),
              ),
            ),
          ),

          // Layer 1: single layout root inside the SafeArea.
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final layout = OnboardingLayout.fromSize(constraints.biggest);
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: layout.pagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: layout.topPadding),
                      _TopBar(
                        layout: layout,
                        isLastPage: isLastPage,
                        onSkip: onSkip,
                      ),
                      _PageContent(
                        layout: layout,
                        viewModels: viewModels,
                        pageController: pageController,
                        onPageChanged: onPageChanged,
                      ),
                      _BottomBlock(
                        layout: layout,
                        pageCount: viewModels.length,
                        currentIndex: currentIndex,
                        isLastPage: isLastPage,
                        onIndicatorTap: onIndicatorTap,
                        onNext: onNext,
                        onBack: onBack,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Top bar: fixed height so hiding Skip never shifts the layout.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.layout,
    required this.isLastPage,
    required this.onSkip,
  });

  final OnboardingLayout layout;
  final bool isLastPage;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: OnboardingLayoutKeys.topBar,
      height: layout.topBarHeight,
      child: FadeSlideIn(
        delay: OnboardingAnimationTimings.topBarDelay,
        duration: AppDurations.normal,
        curve: AppCurves.enter,
        offset: AppAnimationConstants.slideFromTop * 0.5,
        child: FadeSlideIn(
          delay: OnboardingAnimationTimings.topBarInnerDelay,
          duration: OnboardingAnimationTimings.topBarInnerDuration,
          curve: AppCurves.enter,
          offset: const Offset(
            0,
            -OnboardingLayoutRatios.barInnerSlideOfBarHeight,
          ),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: OnboardingSkipButton(
              isLastPage: isLastPage,
              onPressed: onSkip,
            ),
          ),
        ),
      ),
    );
  }
}

/// Page area: the swipeable PageView, clipped to the band.
class _PageContent extends StatelessWidget {
  const _PageContent({
    required this.layout,
    required this.viewModels,
    required this.pageController,
    required this.onPageChanged,
  });

  final OnboardingLayout layout;
  final List<OnboardingPageViewModel> viewModels;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      key: OnboardingLayoutKeys.pageArea,
      child: ClipRect(
        child: OnboardingPageView(
          pages: viewModels,
          pageController: pageController,
          onPageChanged: onPageChanged,
          layout: layout,
        ),
      ),
    );
  }
}

/// Indicator + controls with the vertical rhythm below the page area.
class _BottomBlock extends StatelessWidget {
  const _BottomBlock({
    required this.layout,
    required this.pageCount,
    required this.currentIndex,
    required this.isLastPage,
    required this.onIndicatorTap,
    required this.onNext,
    required this.onBack,
  });

  final OnboardingLayout layout;
  final int pageCount;
  final int currentIndex;
  final bool isLastPage;
  final ValueChanged<int> onIndicatorTap;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      delay: OnboardingAnimationTimings.bottomBarDelay,
      duration: AppDurations.normal,
      curve: AppCurves.enter,
      offset: AppAnimationConstants.slideFromBottom * 0.5,
      child: FadeSlideIn(
        delay: OnboardingAnimationTimings.bottomBarInnerDelay,
        duration: OnboardingAnimationTimings.bottomBarInnerDuration,
        curve: AppCurves.enter,
        offset: const Offset(
          0,
          OnboardingLayoutRatios.barInnerSlideOfBarHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: layout.indicatorAbove),
            _IndicatorRow(
              layout: layout,
              currentIndex: currentIndex,
              pageCount: pageCount,
              onTap: onIndicatorTap,
            ),
            SizedBox(height: layout.indicatorBelow),
            SizedBox(
              key: OnboardingLayoutKeys.controls,
              height: layout.controlsHeight,
              child: OnboardingNavButtons(
                isFirstPage: currentIndex == 0,
                isLastPage: isLastPage,
                onNext: onNext,
                onBack: onBack,
              ),
            ),
            SizedBox(height: layout.bottomPadding),
          ],
        ),
      ),
    );
  }
}

/// Tappable page indicator inside its fixed-height band.
class _IndicatorRow extends StatelessWidget {
  const _IndicatorRow({
    required this.layout,
    required this.currentIndex,
    required this.pageCount,
    required this.onTap,
  });

  final OnboardingLayout layout;
  final int currentIndex;
  final int pageCount;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return SizedBox(
      key: OnboardingLayoutKeys.indicator,
      height: layout.indicatorHeight,
      child: Center(
        child: PageIndicator(
          currentIndex: currentIndex,
          pageCount: pageCount,
          onTap: onTap,
          duration: OnboardingAnimationTimings.indicatorMorph,
          curve: OnboardingAnimationTimings.springCurve,
          semanticsLabel: (current, total) =>
              t.onboarding.a11y.pageIndicator(current: current, total: total),
        ),
      ),
    );
  }
}
