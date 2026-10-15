import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../constants/app_lottie_assets.dart';

/// A Lottie animation wrapped in Orbit's motion rules.
///
/// The named constructors point at the shared files in [AppLottieAssets];
/// [AppLottie.asset] plays any other file. Playback length comes from the
/// composition itself, so no duration or curve is hardcoded here — the
/// wrapper only decides whether to play, loop or rest.
///
/// ```dart
/// AppLottie.success(size: 96, onCompleted: () => Navigator.of(context).pop());
/// AppLottie.loading(size: 24);
/// AppLottie.error(size: 64, fallback: const SizedBox.shrink());
/// AppLottie.asset(AppLottieAssets.onboarding(1), repeat: false);
/// ```
///
/// Behaviour:
/// - When `MediaQuery.disableAnimations` is on, the final frame is rendered
///   without playing ([AppLottie.loading] rests on its first frame instead);
///   [onCompleted] still fires once, so reduce-motion users are not left
///   waiting for a transition.
/// - Rebuilding the parent does not restart playback. Only a changed [path]
///   loads a new composition and plays it again.
/// - A file that fails to load renders [fallback] inside the same box, so
///   layout never jumps, and the failure is re-reported to
///   `FlutterError.onError` (an `errorBuilder` suppresses the package's own
///   report).
/// - [mirrorInRtl] flips horizontal motion under an RTL [Directionality].
///
/// Only this file and [AppLottieAssets] stand between features and the
/// `lottie` package: features never import it, so the package can be swapped
/// by rewriting this wrapper alone.
class AppLottie extends StatefulWidget {
  /// Plays the shared success file once, at its end state.
  const AppLottie.success({
    super.key,
    this.size,
    this.repeat = false,
    this.onCompleted,
    this.fit = BoxFit.contain,
    this.mirrorInRtl = false,
    this.fallback,
  }) : path = AppLottieAssets.success,
       _restOnFirstFrame = false;

  /// Plays the shared error file once, at its end state.
  const AppLottie.error({
    super.key,
    this.size,
    this.repeat = false,
    this.onCompleted,
    this.fit = BoxFit.contain,
    this.mirrorInRtl = false,
    this.fallback,
  }) : path = AppLottieAssets.error,
       _restOnFirstFrame = false;

  /// Plays the shared empty-state file once, at its end state.
  const AppLottie.empty({
    super.key,
    this.size,
    this.repeat = false,
    this.onCompleted,
    this.fit = BoxFit.contain,
    this.mirrorInRtl = false,
    this.fallback,
  }) : path = AppLottieAssets.empty,
       _restOnFirstFrame = false;

  /// Plays the shared busy indicator on a loop.
  ///
  /// Under `disableAnimations` it rests on its first frame — the spinner's
  /// neutral position — rather than on the last frame of the cycle.
  const AppLottie.loading({
    super.key,
    this.size,
    this.repeat = true,
    this.onCompleted,
    this.fit = BoxFit.contain,
    this.mirrorInRtl = false,
    this.fallback,
  }) : path = AppLottieAssets.loading,
       _restOnFirstFrame = true;

  /// Plays an arbitrary Lottie file from [path].
  ///
  /// Loops by default like the `lottie` package itself; pass `repeat: false`
  /// for a one-shot, which then fires [onCompleted] at the end.
  const AppLottie.asset(
    this.path, {
    super.key,
    this.size,
    this.repeat = true,
    this.onCompleted,
    this.fit = BoxFit.contain,
    this.mirrorInRtl = false,
    this.fallback,
  }) : _restOnFirstFrame = false;

  /// Asset path of the composition; comes from [AppLottieAssets] or an
  /// equivalent constant, never from a literal at the call site.
  final String path;

  /// Side of the square box the animation (or its fallback) occupies, in
  /// logical pixels. `null` hands sizing to the parent's constraints.
  final double? size;

  /// Whether the animation loops. One-shot constructors default to `false`,
  /// [AppLottie.loading] and [AppLottie.asset] to `true`.
  final bool repeat;

  /// Called once when a non-repeating animation reaches its last frame —
  /// including the instant `disableAnimations` jump to that frame. Never
  /// called for loops; always delivered after the frame, never during build.
  final VoidCallback? onCompleted;

  /// How the composition is inscribed into the box it is given.
  final BoxFit fit;

  /// Flips the animation horizontally when the ambient text direction is
  /// RTL. Off by default: only directional assets (arrows, "next" cues)
  /// want it; mirrored by default a symmetric checkmark would look wrong.
  final bool mirrorInRtl;

  /// Shown instead of the animation when the file cannot be loaded. Defaults
  /// to a neutral icon; pass `const SizedBox.shrink()` to collapse silently.
  final Widget? fallback;

  /// Whether [AppLottie.loading] rests on its first frame when animations
  /// are disabled, instead of the last frame every other constructor shows.
  final bool _restOnFirstFrame;

  @override
  State<AppLottie> createState() => _AppLottieState();
}

class _AppLottieState extends State<AppLottie>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  LottieComposition? _composition;
  bool _disableAnimations = false;
  bool _awaitingCompletion = false;
  bool _completionDelivered = false;
  bool _loadErrorReported = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addStatusListener(_handleStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations == _disableAnimations) return;
    _disableAnimations = disableAnimations;
    _configurePlayback();
  }

  @override
  void didUpdateWidget(covariant AppLottie oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new path reloads through onLoaded; everything else that matters to
    // playback is `repeat`.
    if (widget.path != oldWidget.path) {
      _loadErrorReported = false;
    }
    if (widget.repeat != oldWidget.repeat) {
      _configurePlayback();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCompositionLoaded(LottieComposition composition) {
    _composition = composition;
    _completionDelivered = false;
    _configurePlayback();
  }

  void _configurePlayback() {
    final LottieComposition? composition = _composition;
    if (composition == null) return;
    _awaitingCompletion = false;
    _controller
      ..duration = composition.duration
      ..stop();
    if (_disableAnimations) {
      _showStaticFrame();
      return;
    }
    if (widget.repeat) {
      _controller.repeat();
      return;
    }
    _awaitingCompletion = true;
    _controller.forward();
  }

  void _showStaticFrame() {
    _controller.value = widget._restOnFirstFrame
        ? _controller.lowerBound
        : _controller.upperBound;
    if (!widget._restOnFirstFrame) {
      _deliverCompletion();
    }
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _awaitingCompletion) {
      _awaitingCompletion = false;
      _deliverCompletion();
    }
  }

  void _deliverCompletion() {
    if (_completionDelivered || widget.repeat) return;
    _completionDelivered = true;
    if (widget.onCompleted == null) return;
    // Deferred: delivery can originate in didChangeDependencies, which runs
    // during build, where the callback must not call setState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onCompleted?.call();
    });
  }

  Widget _buildFallback(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    // errorBuilder re-runs on every rebuild and suppresses the package's own
    // report, so report once to keep a missing or broken file visible in the
    // debug console.
    if (!_loadErrorReported) {
      _loadErrorReported = true;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'AppLottie',
          context: ErrorDescription('while loading ${widget.path}'),
        ),
      );
    }
    return widget.fallback ?? const Icon(Icons.animation);
  }

  @override
  Widget build(BuildContext context) {
    Widget result = Lottie.asset(
      widget.path,
      controller: _controller,
      fit: widget.fit,
      addRepaintBoundary: true,
      onLoaded: _handleCompositionLoaded,
      errorBuilder: _buildFallback,
    );
    final double? size = widget.size;
    if (size != null) {
      result = SizedBox(width: size, height: size, child: result);
    }
    if (widget.mirrorInRtl && Directionality.of(context) == TextDirection.rtl) {
      result = Transform.flip(flipX: true, child: result);
    }
    return result;
  }
}
