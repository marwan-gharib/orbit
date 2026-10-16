import 'dart:math' show cos, pi, sin;

import 'package:flutter/material.dart';

import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/features/splash/presentation/constants/splash_animation_constants.dart';
import 'package:orbit/features/splash/presentation/constants/splash_layout_constants.dart';
import 'package:orbit/features/splash/presentation/widgets/convergence_widget.dart';
import 'package:orbit/features/splash/presentation/widgets/exit_transition_widget.dart';
import 'package:orbit/features/splash/presentation/widgets/logo_reveal_widget.dart';
import 'package:orbit/features/splash/presentation/widgets/module_keywords_widget.dart';
import 'package:orbit/features/splash/presentation/widgets/module_nodes_painter.dart';
import 'package:orbit/features/splash/presentation/widgets/orbit_rings_painter.dart';
import 'package:orbit/features/splash/presentation/widgets/tagline_reveal_widget.dart';

/// Progress within [startMs, endMs] of the shared timeline; -1 outside.
double _phase(double progress, int startMs, int endMs) {
  final start = startMs / SplashAnimationConstants.totalDurationMs;
  final end = endMs / SplashAnimationConstants.totalDurationMs;
  if (progress <= start || progress >= end) return -1;
  return (progress - start) / (end - start);
}

/// Root composition widget that orchestrates all splash animation layers
/// with a single AnimationController (Interval-based phases).
///
/// ONE layout root positions everything: a [Center] holding a min-size
/// [Column] of stage → gap → tagline → gap → keywords. Animation only
/// animates transforms, opacity, and painter progress on top of that
/// structure — never position or size — so the layout at the end of the
/// timeline is identical to the layout at the hold phase.
class SplashComposition extends StatefulWidget {
  const SplashComposition({
    super.key,
    required this.controller,
    required this.logoAsset,
    required this.taglineWords,
    required this.moduleKeywords,
  });

  final AnimationController controller;
  final String logoAsset;
  final List<String> taglineWords;
  final List<String> moduleKeywords;

  @override
  State<SplashComposition> createState() => _SplashCompositionState();
}

class _SplashCompositionState extends State<SplashComposition> {
  /// Precomputed node positions as fractions of the stage side for 60fps *
  /// 4s = 240 frames; painters scale them by the live stage size.
  static const int _nodeFrameCount = 240;

  late final List<List<Offset>> _nodePositionFractions;

  /// Identifies the stage box so the background glow can be centered on the
  /// stage center (measured after layout, in composition coordinates).
  final GlobalKey _stageKey = GlobalKey();
  Offset? _stageCenter;

  @override
  void initState() {
    super.initState();
    _precomputeNodePositions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleStageCenterMeasurement();
  }

  void _scheduleStageCenterMeasurement() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final stageBox =
          _stageKey.currentContext?.findRenderObject() as RenderBox?;
      final rootBox = context.findRenderObject() as RenderBox?;
      if (stageBox == null ||
          rootBox == null ||
          !stageBox.hasSize ||
          !rootBox.hasSize) {
        return;
      }
      final center = stageBox.localToGlobal(
        stageBox.size.center(Offset.zero),
        ancestor: rootBox,
      );
      if (center != _stageCenter) {
        setState(() => _stageCenter = center);
      }
    });
  }

  void _precomputeNodePositions() {
    const nodeCount = SplashAnimationConstants.moduleNodeCount;

    _nodePositionFractions = List.generate(
      nodeCount,
      (_) => List.filled(_nodeFrameCount, Offset.zero),
    );

    for (int frame = 0; frame < _nodeFrameCount; frame++) {
      final progress = frame / _nodeFrameCount;
      final nodesProgress = _nodesProgress(progress);

      for (int i = 0; i < nodeCount; i++) {
        final nodeProgress = nodesProgress[i];
        if (nodeProgress > 0) {
          _nodePositionFractions[i][frame] = _computeNodePosition(
            i,
            nodeProgress,
          );
        }
      }
    }
  }

  /// Computes progress (0-1) for each node at a given global progress.
  List<double> _nodesProgress(double progress) {
    const start =
        SplashAnimationConstants.moduleNodesStartMs /
        SplashAnimationConstants.totalDurationMs;
    const end =
        SplashAnimationConstants.moduleNodesEndMs /
        SplashAnimationConstants.totalDurationMs;

    if (progress < start) {
      return List.filled(SplashAnimationConstants.moduleNodeCount, 0.0);
    }
    if (progress > end) {
      return List.filled(SplashAnimationConstants.moduleNodeCount, 1.0);
    }

    const duration = end - start;
    final localProgress = (progress - start) / duration;
    // Decelerating: easeOutCubic
    final eased =
        1 - (1 - localProgress) * (1 - localProgress) * (1 - localProgress);

    // Stagger nodes slightly
    return List.generate(SplashAnimationConstants.moduleNodeCount, (i) {
      final nodeStart = i * 0.05; // 5% stagger per node
      final nodeProgress = (eased - nodeStart) / (1 - nodeStart);
      return nodeProgress.clamp(0.0, 1.0);
    });
  }

  /// Node position as a fraction of the stage side (unit-less, so painters
  /// scale it by the live stage size).
  Offset _computeNodePosition(int nodeIndex, double progress) {
    final orbit = SplashLayoutRatios.nodeOrbits[nodeIndex];

    final angle = progress * 2 * pi * 1.5; // 1.5 revolutions
    final radiusProgress = 1.0 - progress; // Spiral inward slightly

    final x = orbit.a * radiusProgress * cos(angle);
    final y = orbit.b * radiusProgress * sin(angle);

    // Apply tilt rotation
    final cosTilt = cos(orbit.tilt);
    final sinTilt = sin(orbit.tilt);
    final rotatedX = x * cosTilt - y * sinTilt;
    final rotatedY = x * sinTilt + y * cosTilt;

    return Offset(rotatedX, rotatedY);
  }

  @override
  Widget build(BuildContext context) {
    final layout = SplashLayout.fromScreen(MediaQuery.sizeOf(context));
    final colors = context.colors;
    final nodeColors = [
      colors.primary,
      colors.secondary,
      colors.primaryContainer,
      colors.secondaryContainer,
      colors.inversePrimary,
    ];

    return SafeArea(
      child: ColoredBox(
        color: colors.surface,
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Layer 1: radial glow (0-500ms), full screen, centered on
              // the stage center.
              _GlowLayer(
                controller: widget.controller,
                color: colors.primary,
                stageCenter: _stageCenter,
              ),

              // Layer 2: content — the single layout root.
              Center(
                child: ExitTransitionWidget(
                  controller: widget.controller,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _SplashContent(
                      controller: widget.controller,
                      layout: layout,
                      logoAsset: widget.logoAsset,
                      taglineWords: widget.taglineWords,
                      moduleKeywords: widget.moduleKeywords,
                      nodeColors: nodeColors,
                      trailColors: [
                        for (final color in nodeColors)
                          color.withValues(alpha: 0.12),
                      ],
                      nodePositionFractions: _nodePositionFractions,
                      stageKey: _stageKey,
                      frameCount: _nodeFrameCount,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen radial glow behind the stage during setup (0-500ms). Owns its
/// own AnimatedBuilder so only this layer rebuilds per frame.
class _GlowLayer extends StatelessWidget {
  const _GlowLayer({
    required this.controller,
    required this.color,
    required this.stageCenter,
  });

  final AnimationController controller;
  final Color color;
  final Offset? stageCenter;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final progress = controller.value.clamp(0.0, 1.0);
        final glowPhase = _phase(
          progress,
          SplashAnimationConstants.radialGlowStartMs,
          SplashAnimationConstants.radialGlowEndMs,
        );
        if (glowPhase < 0) return const SizedBox.shrink();

        return CustomPaint(
          painter: _RadialGlowPainter(
            progress: glowPhase.clamp(0.0, 1.0),
            color: color,
            stageCenter: stageCenter,
          ),
        );
      },
    );
  }
}

/// The single layout root: stage → gap → tagline → gap → keywords.
class _SplashContent extends StatelessWidget {
  const _SplashContent({
    required this.controller,
    required this.layout,
    required this.logoAsset,
    required this.taglineWords,
    required this.moduleKeywords,
    required this.nodeColors,
    required this.trailColors,
    required this.nodePositionFractions,
    required this.stageKey,
    required this.frameCount,
  });

  final AnimationController controller;
  final SplashLayout layout;
  final String logoAsset;
  final List<String> taglineWords;
  final List<String> moduleKeywords;
  final List<Color> nodeColors;
  final List<Color> trailColors;
  final List<List<Offset>> nodePositionFractions;
  final GlobalKey stageKey;
  final int frameCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SplashStage(
          controller: controller,
          layout: layout,
          logoAsset: logoAsset,
          nodeColors: nodeColors,
          trailColors: trailColors,
          nodePositionFractions: nodePositionFractions,
          stageKey: stageKey,
          frameCount: frameCount,
        ),
        SizedBox(height: layout.stageToTaglineGap),
        // Tagline and keywords read the controller per frame in their own
        // build, so each gets a listenable here — scoped so a frame never
        // rebuilds the stage.
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) => ConstrainedBox(
            constraints: BoxConstraints(maxWidth: layout.contentMaxWidth),
            child: TaglineRevealWidget(
              controller: controller,
              words: taglineWords,
              emphasizedWordIndex:
                  SplashAnimationConstants.taglineEmphasizedWordIndex,
            ),
          ),
        ),
        SizedBox(height: layout.taglineToKeywordsGap),
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) => ConstrainedBox(
            constraints: BoxConstraints(maxWidth: layout.contentMaxWidth),
            child: ModuleKeywordsWidget(
              controller: controller,
              keywords: moduleKeywords,
            ),
          ),
        ),
      ],
    );
  }
}

/// The square stage: rings, orbiting nodes, logo, light sweep, convergence.
/// Rebuilds per frame for its phase gates; the logo is passed through as
/// `child` so it never rebuilds here (it drives its own animation).
class _SplashStage extends StatelessWidget {
  const _SplashStage({
    required this.controller,
    required this.layout,
    required this.logoAsset,
    required this.nodeColors,
    required this.trailColors,
    required this.nodePositionFractions,
    required this.stageKey,
    required this.frameCount,
  });

  final AnimationController controller;
  final SplashLayout layout;
  final String logoAsset;
  final List<Color> nodeColors;
  final List<Color> trailColors;
  final List<List<Offset>> nodePositionFractions;
  final GlobalKey stageKey;
  final int frameCount;

  @override
  Widget build(BuildContext context) {
    final stageSide = layout.stageSide;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, logo) {
        final progress = controller.value.clamp(0.0, 1.0);
        final ringsPhase = _phase(
          progress,
          SplashAnimationConstants.orbitRingsDrawStartMs,
          SplashAnimationConstants.orbitRingsDrawEndMs,
        );
        final nodesPhase = _phase(
          progress,
          SplashAnimationConstants.moduleNodesStartMs,
          SplashAnimationConstants.moduleNodesEndMs,
        );
        final sweepPhase = _phase(
          progress,
          SplashAnimationConstants.lightSweepStartMs,
          SplashAnimationConstants.lightSweepEndMs,
        );
        final convergencePhase = _phase(
          progress,
          SplashAnimationConstants.convergenceStartMs,
          SplashAnimationConstants.convergenceEndMs,
        );

        return SizedBox.square(
          key: stageKey,
          dimension: stageSide,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Orbit rings drawing (100-500ms)
              if (ringsPhase >= 0)
                CustomPaint(
                  size: Size.square(stageSide),
                  painter: OrbitRingsPainter(
                    progress: ringsPhase.clamp(0.0, 1.0),
                    ringColor: context.colors.primary.withValues(alpha: 0.12),
                  ),
                ),

              // Module nodes orbiting (500-2600ms)
              if (nodesPhase >= 0)
                CustomPaint(
                  size: Size.square(stageSide),
                  painter: ModuleNodesPainter(
                    nodePositionFractions: nodePositionFractions,
                    frameIndex: (progress * (frameCount - 1))
                        .clamp(0, frameCount - 1)
                        .toInt(),
                    trailHistoryLength:
                        SplashAnimationConstants.trailHistoryLength,
                    nodeColors: nodeColors,
                    trailColors: trailColors,
                  ),
                ),

              // Logo reveal (300-1400ms) with shockwave (800-1000ms)
              logo ?? const SizedBox.shrink(),

              // Light sweep (1400-2200ms)
              if (sweepPhase >= 0)
                _LightSweep(
                  progress: sweepPhase.clamp(0.0, 1.0),
                  logoWidth: layout.logoWidth,
                ),

              // Convergence / lock-in (2600-3300ms)
              if (convergencePhase >= 0)
                ConvergenceWidget(
                  controller: controller,
                  nodeCount: SplashAnimationConstants.moduleNodeCount,
                  stageSide: stageSide,
                  nodeColors: nodeColors,
                ),
            ],
          ),
        );
      },
      child: LogoRevealWidget(
        controller: controller,
        logoAsset: logoAsset,
        stageSide: stageSide,
        shockwaveMaxRadius: layout.shockwaveMaxRadius,
      ),
    );
  }
}

/// Full-screen radial glow behind the stage during setup (0-500ms), drawn at
/// the measured stage center so it stays behind the logo regardless of where
/// the content column sits.
class _RadialGlowPainter extends CustomPainter {
  const _RadialGlowPainter({
    required this.progress,
    required this.color,
    this.stageCenter,
  });

  /// Phase progress within the glow window, clamped 0..1.
  final double progress;
  final Color color;

  /// Stage center in this painter's coordinate space; the screen center is
  /// used until the first measurement lands (never zero).
  final Offset? stageCenter;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = progress.clamp(0.0, 1.0);
    if (phase <= 0) return;

    final center = stageCenter ?? size.center(Offset.zero);
    final maxRadius =
        SplashLayoutRatios.glowRadiusOfShortSide * size.shortestSide;
    final radius = maxRadius * phase;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.08 * phase),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RadialGlowPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.stageCenter != stageCenter;
}

/// Diagonal light sweep across logo.
class _LightSweep extends StatelessWidget {
  const _LightSweep({required this.progress, required this.logoWidth});

  final double progress;
  final double logoWidth;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.primary.withValues(alpha: 0.0),
            context.colors.primary.withValues(alpha: 0.4),
            context.colors.primary.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
          transform: GradientRotation(-0.785 + progress * 1.57), // -45° to +45°
        ).createShader(bounds);
      },
      blendMode: BlendMode.plus,
      child: SizedBox(width: logoWidth * 1.5, height: logoWidth * 1.5),
    );
  }
}
