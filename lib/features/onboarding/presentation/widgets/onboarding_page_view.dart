import 'package:flutter/material.dart';
import 'package:orbit/features/onboarding/presentation/constants/onboarding_layout_constants.dart';
import 'package:orbit/features/onboarding/presentation/view_models/onboarding_page_view_model.dart';
import 'package:orbit/features/onboarding/presentation/widgets/onboarding_page.dart';

/// PageView that displays onboarding pages with parallax-driven progress values.
/// Listens to PageController for fractional page index and computes per-page progress.
class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({
    required this.pages,
    required this.pageController,
    required this.onPageChanged,
    required this.layout,
    super.key,
  });

  final List<OnboardingPageViewModel> pages;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final OnboardingLayout layout;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      onPageChanged: onPageChanged,
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final page = pages[index];
        return _OnboardingPageWrapper(
          page: page,
          pageController: pageController,
          index: index,
          layout: layout,
        );
      },
    );
  }
}

/// Wrapper that computes the entrance progress for a page based on the
/// PageController's fractional page value.
class _OnboardingPageWrapper extends StatefulWidget {
  const _OnboardingPageWrapper({
    required this.page,
    required this.pageController,
    required this.index,
    required this.layout,
  });

  final OnboardingPageViewModel page;
  final PageController pageController;
  final int index;
  final OnboardingLayout layout;

  @override
  State<_OnboardingPageWrapper> createState() => _OnboardingPageWrapperState();
}

class _OnboardingPageWrapperState extends State<_OnboardingPageWrapper> {
  double _pageValue = 0.0;

  @override
  void initState() {
    super.initState();
    _pageValue = _currentPageValue();
    widget.pageController.addListener(_onPageChange);
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_onPageChange);
    super.dispose();
  }

  double _currentPageValue() {
    if (widget.pageController.hasClients &&
        widget.pageController.page != null) {
      return widget.pageController.page!.toDouble();
    }
    return widget.pageController.initialPage.toDouble();
  }

  void _onPageChange() {
    if (!mounted) return;
    final page = _currentPageValue();
    if (_pageValue != page) {
      setState(() => _pageValue = page);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Compute progress: 1.0 when this page is center, 0.0 when far away
    // Page value is fractional (e.g., 0.0, 0.3, 1.0, 2.0)
    final distance = (_pageValue - widget.index).abs();
    final progress = (1.0 - distance).clamp(0.0, 1.0);
    final isActive = distance < 0.5; // center page

    return OnboardingPage(
      page: widget.page,
      progress: progress,
      isActive: isActive,
      layout: widget.layout,
    );
  }
}
