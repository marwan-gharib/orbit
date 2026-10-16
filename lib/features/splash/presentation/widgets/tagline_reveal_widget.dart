import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/features/splash/presentation/constants/splash_animation_constants.dart';

/// Word-by-word masked slide-up reveal for the tagline.
///
/// Every word always occupies its final text size — only opacity and
/// transform animate — so the tagline reserves its layout from the first
/// frame and never shifts the stage or the keywords while revealing.
class TaglineRevealWidget extends StatelessWidget {
  const TaglineRevealWidget({
    super.key,
    required this.controller,
    required this.words,
    required this.emphasizedWordIndex,
  });

  final AnimationController controller;
  final List<String> words;

  /// Index of the emphasized word ("orbit.") in [words].
  final int emphasizedWordIndex;

  @override
  Widget build(BuildContext context) {
    const startMs = SplashAnimationConstants.taglineStartMs;
    const endMs = SplashAnimationConstants.taglineEndMs;
    const totalMs = SplashAnimationConstants.totalDurationMs;

    final interval = Interval(startMs / totalMs, endMs / totalMs);
    final progress = interval.transform(controller.value);

    final wordDuration = 1.0 / words.length;
    final staggerMs = SplashAnimationConstants.taglineWordStaggerMs / totalMs;
    final baseStyle = context.textStyles.headlineSmall;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      children: [
        for (int i = 0; i < words.length; i++)
          _AnimatedWord(
            word: words[i],
            progress: _wordProgress(progress, i, wordDuration, staggerMs),
            style: i == emphasizedWordIndex
                ? baseStyle.copyWith(color: context.colors.primary)
                : baseStyle,
          ),
      ],
    );
  }

  double _wordProgress(
    double progress,
    int index,
    double wordDuration,
    double stagger,
  ) {
    // Word [index] starts [stagger] after the previous one; the last word
    // (6 words × 140ms stagger + 200ms reveal) completes inside the phase.
    final start = index * stagger;
    final end = start + wordDuration;
    if (progress <= start) return 0.0;
    if (progress >= end) return 1.0;
    return Curves.easeOutCubic.transform((progress - start) / wordDuration);
  }
}

/// Single word with masked slide-up and fade.
class _AnimatedWord extends StatelessWidget {
  const _AnimatedWord({
    required this.word,
    required this.progress,
    required this.style,
  });

  final String word;
  final double progress;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Transform.translate(
        offset: Offset(
          0,
          SplashAnimationConstants.taglineWordRiseOffset * (1 - progress),
        ),
        child: Opacity(
          opacity: progress.clamp(0.0, 1.0),
          child: Text(
            word,
            textAlign: TextAlign.center,
            style: style.copyWith(
              letterSpacing: lerpDouble(1.0, 0.0, progress),
            ),
          ),
        ),
      ),
    );
  }
}
