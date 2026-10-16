import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit/core/constants/assets.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/widgets/error_state.dart';
import 'package:orbit/features/splash/presentation/constants/splash_animation_constants.dart';
import 'package:orbit/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:orbit/features/splash/presentation/cubit/splash_state.dart';
import 'package:orbit/features/splash/presentation/widgets/splash_composition.dart';

/// Splash screen — runs 4000ms animation in parallel with startup checks.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  late final SplashCubit _cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _cubit = context.read<SplashCubit>();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: SplashAnimationConstants.totalDurationMs,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Precache logo to avoid pop-in on first frame
      precacheImage(const AssetImage(Assets.splashLogo), context);
    });

    // Start animation and initialization in parallel
    _controller.forward();
    _cubit.initialize();

    // Listen for animation completion
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _cubit.onAnimationComplete();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller.value < 1.0) {
        _controller.forward();
      }
    }
  }

  void _navigateWhenReady(BuildContext context, SplashState state) {
    switch (state) {
      case SplashReady(:final viewModel):
        context.goNamed(viewModel.nextRoute);
      case SplashLoading():
      case SplashError():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<SplashCubit, SplashState>(
        listenWhen: (previous, current) => switch (current) {
          SplashReady() => true,
          SplashLoading() || SplashError() => false,
        },
        listener: _navigateWhenReady,
        child: BlocBuilder<SplashCubit, SplashState>(
          builder: (context, state) => switch (state) {
            SplashLoading() || SplashReady() => _SplashBody(
              controller: _controller,
              cubit: _cubit,
              tagline: t.splash.tagline,
              taglineWords: t.splash.taglineWords,
              moduleKeywords: [
                t.splash.modules.projects,
                t.splash.modules.people,
                t.splash.modules.finance,
                t.splash.modules.clients,
                t.splash.modules.insights,
              ],
              accessibilityLabel: t.splash.accessibilityLabel,
            ),
            SplashError(:final failure) => _SplashErrorView(failure: failure),
          },
        ),
      ),
    );
  }
}

/// Loading and ready stage: the animated composition, or the static final
/// frame when the platform requests reduced motion.
class _SplashBody extends StatelessWidget {
  const _SplashBody({
    required this.controller,
    required this.cubit,
    required this.tagline,
    required this.taglineWords,
    required this.moduleKeywords,
    required this.accessibilityLabel,
  });

  final AnimationController controller;
  final SplashCubit cubit;
  final String tagline;
  final List<String> taglineWords;
  final List<String> moduleKeywords;
  final String accessibilityLabel;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return _ReducedMotionSplash(
        cubit: cubit,
        tagline: tagline,
        accessibilityLabel: accessibilityLabel,
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Semantics(
        label: accessibilityLabel,
        child: SplashComposition(
          controller: controller,
          logoAsset: Assets.splashLogo,
          taglineWords: taglineWords,
          moduleKeywords: moduleKeywords,
        ),
      ),
    );
  }
}

/// Startup checks failed — shows the localized failure text (ERR-4).
class _SplashErrorView extends StatelessWidget {
  const _SplashErrorView({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: ErrorState(message: context.failureText(failure)),
    );
  }
}

/// Static fallback when animations are disabled.
class _ReducedMotionSplash extends StatefulWidget {
  const _ReducedMotionSplash({
    required this.cubit,
    required this.tagline,
    required this.accessibilityLabel,
  });

  final SplashCubit cubit;
  final String tagline;
  final String accessibilityLabel;

  @override
  State<_ReducedMotionSplash> createState() => _ReducedMotionSplashState();
}

class _ReducedMotionSplashState extends State<_ReducedMotionSplash> {
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    // Hold the static frame briefly, then let the cubit complete the splash;
    // cancelled on dispose so no callback outlives the screen (UI-9).
    _holdTimer = Timer(
      const Duration(
        milliseconds: SplashAnimationConstants.reducedMotionHoldMs,
      ),
      widget.cubit.onAnimationComplete,
    );
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Semantics(
        label: widget.accessibilityLabel,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(Assets.splashLogo, width: Responsive.width(120)),
              SizedBox(height: Responsive.height(24)),
              Text(
                widget.tagline,
                style: context.textStyles.headlineMedium.copyWith(
                  color: context.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
