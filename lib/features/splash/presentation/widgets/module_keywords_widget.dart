import 'package:flutter/material.dart';

import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/features/splash/presentation/constants/splash_animation_constants.dart';

/// Sequential module keywords appearing under tagline, synced to nodes.
///
/// A single centered [Wrap]: one line when it fits, a second centered line
/// on narrow screens. Every keyword and separator dot always reserves its
/// size — only opacity and transform animate — so the row never shifts the
/// layout while revealing.
class ModuleKeywordsWidget extends StatelessWidget {
  const ModuleKeywordsWidget({
    super.key,
    required this.controller,
    required this.keywords,
  });

  final AnimationController controller;
  final List<String> keywords;

  @override
  Widget build(BuildContext context) {
    const startMs = SplashAnimationConstants.moduleKeywordsStartMs;
    const endMs = SplashAnimationConstants.moduleKeywordsEndMs;
    const totalMs = SplashAnimationConstants.totalDurationMs;

    final interval = Interval(startMs / totalMs, endMs / totalMs);
    final progress = interval.transform(controller.value);

    final keywordDuration = 1.0 / keywords.length;
    final style = context.textStyles.labelLarge.copyWith(
      color: context.colors.textSecondary,
    );
    final dotColor = context.colors.textSecondary;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        for (int i = 0; i < keywords.length; i++) ...[
          if (i > 0)
            Opacity(
              opacity: _keywordProgress(progress, i, keywordDuration),
              child: _SeparatorDot(color: dotColor),
            ),
          _AnimatedKeyword(
            keyword: keywords[i],
            progress: _keywordProgress(progress, i, keywordDuration),
            style: style,
          ),
        ],
      ],
    );
  }

  double _keywordProgress(double progress, int index, double keywordDuration) {
    final start = index * keywordDuration;
    final end = start + keywordDuration;
    if (progress <= start) return 0.0;
    if (progress >= end) return 1.0;
    return Curves.easeOutCubic.transform((progress - start) / keywordDuration);
  }
}

/// Small dot separating two keywords in the row.
class _SeparatorDot extends StatelessWidget {
  const _SeparatorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final dotSize = AppSpacing.xxs;
    return SizedBox(
      width: dotSize,
      height: dotSize,
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

/// Single keyword with fade + small rise.
class _AnimatedKeyword extends StatelessWidget {
  const _AnimatedKeyword({
    required this.keyword,
    required this.progress,
    required this.style,
  });

  final String keyword;
  final double progress;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: progress.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(
          0,
          SplashAnimationConstants.moduleKeywordRiseOffset * (1 - progress),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
          // Pulse once the keyword is more than half revealed.
          child: AnimatedScale(
            scale: progress > 0.5 ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutBack,
            child: Text(keyword, style: style),
          ),
        ),
      ),
    );
  }
}
