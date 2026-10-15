import 'package:flutter/material.dart';

import 'package:orbit/core/theme/app_text_styles.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';

/// The type scale with mode-aware colors, exposed on the theme so widgets
/// read styles via `context.textStyles` instead of hardcoded [TextStyle]s
/// (UI-1). Build one per palette with [forColors] — that is what
/// `app_theme.dart` registers in both themes.
@immutable
class AppTextStylesExtension extends ThemeExtension<AppTextStylesExtension> {
  AppTextStylesExtension.forColors(AppColorsExtension colors)
    : displayLarge = AppTextStyles.displayLarge.copyWith(
        color: colors.textPrimary,
      ),
      displayMedium = AppTextStyles.displayMedium.copyWith(
        color: colors.textPrimary,
      ),
      displaySmall = AppTextStyles.displaySmall.copyWith(
        color: colors.textPrimary,
      ),
      headlineLarge = AppTextStyles.headlineLarge.copyWith(
        color: colors.textPrimary,
      ),
      headlineMedium = AppTextStyles.headlineMedium.copyWith(
        color: colors.textPrimary,
      ),
      headlineSmall = AppTextStyles.headlineSmall.copyWith(
        color: colors.textPrimary,
      ),
      titleLarge = AppTextStyles.titleLarge.copyWith(color: colors.textPrimary),
      titleMedium = AppTextStyles.titleMedium.copyWith(
        color: colors.textPrimary,
      ),
      titleSmall = AppTextStyles.titleSmall.copyWith(color: colors.textPrimary),
      bodyLarge = AppTextStyles.bodyLarge.copyWith(color: colors.textPrimary),
      bodyMedium = AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
      bodySmall = AppTextStyles.bodySmall.copyWith(color: colors.textPrimary),
      labelLarge = AppTextStyles.labelLarge.copyWith(color: colors.textPrimary),
      labelMedium = AppTextStyles.labelMedium.copyWith(
        color: colors.textPrimary,
      ),
      labelSmall = AppTextStyles.labelSmall.copyWith(color: colors.textPrimary);

  const AppTextStylesExtension({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;

  @override
  AppTextStylesExtension copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
  }) {
    return AppTextStylesExtension(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      titleSmall: titleSmall ?? this.titleSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      labelSmall: labelSmall ?? this.labelSmall,
    );
  }

  @override
  AppTextStylesExtension lerp(
    covariant ThemeExtension<AppTextStylesExtension>? other,
    double t,
  ) {
    if (other is! AppTextStylesExtension) return this;
    TextStyle lerpStyle(TextStyle a, TextStyle b) =>
        TextStyle.lerp(a, b, t) ?? a;
    return AppTextStylesExtension(
      displayLarge: lerpStyle(displayLarge, other.displayLarge),
      displayMedium: lerpStyle(displayMedium, other.displayMedium),
      displaySmall: lerpStyle(displaySmall, other.displaySmall),
      headlineLarge: lerpStyle(headlineLarge, other.headlineLarge),
      headlineMedium: lerpStyle(headlineMedium, other.headlineMedium),
      headlineSmall: lerpStyle(headlineSmall, other.headlineSmall),
      titleLarge: lerpStyle(titleLarge, other.titleLarge),
      titleMedium: lerpStyle(titleMedium, other.titleMedium),
      titleSmall: lerpStyle(titleSmall, other.titleSmall),
      bodyLarge: lerpStyle(bodyLarge, other.bodyLarge),
      bodyMedium: lerpStyle(bodyMedium, other.bodyMedium),
      bodySmall: lerpStyle(bodySmall, other.bodySmall),
      labelLarge: lerpStyle(labelLarge, other.labelLarge),
      labelMedium: lerpStyle(labelMedium, other.labelMedium),
      labelSmall: lerpStyle(labelSmall, other.labelSmall),
    );
  }
}

/// Read-only access to the active type scale, e.g.
/// `context.textStyles.bodyLarge`.
extension AppTextStylesContext on BuildContext {
  AppTextStylesExtension get textStyles =>
      Theme.of(this).extension<AppTextStylesExtension>() ??
      AppTextStylesExtension.forColors(colors);
}
