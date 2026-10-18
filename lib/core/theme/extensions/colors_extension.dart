import 'package:flutter/material.dart';

import 'package:orbit/core/theme/app_colors.dart';

/// Semantic color tokens exposed on the theme so widgets read colors via
/// `context.colors` instead of raw `AppColors` constants or hex values (UI-1).
/// [light] and [dark] are deliberately designed per mode, not inverted:
/// dark surfaces step through the Secondary Dark ramp and every text pair
/// clears WCAG AA on its own background.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.hint,
    required this.border,
    required this.borderStrong,
    required this.primary,
    required this.primaryHover,
    required this.primaryActive,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.primarySoft,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.successSoft,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.inversePrimary,
    required this.scrim,
    required this.shadow,
  });

  // Surfaces: scaffold → base surface → muted fill → elevated (dialog/sheet).
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceElevated;

  // Text and lines.
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color hint;
  final Color border;
  final Color borderStrong;

  // Brand. `primary` is the text-safe interactive blue; hover/active ramp one
  // step brighter/darker in light mode and one step lighter in dark mode.
  final Color primary;
  final Color primaryHover;
  final Color primaryActive;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  /// Decorative brand tint: a pale accent fill in light mode, a mid-tone
  /// accent fill in dark mode. Graphic-only, never used behind text.
  final Color primarySoft;

  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;

  // Status. Each status ships a solid color, a tinted container, and the
  // text color that clears AA on that container.
  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;

  /// Success sibling of [primarySoft]; same graphic-only treatment.
  final Color successSoft;

  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;

  /// Primary-family color that reads on [textPrimary]-colored inverse
  /// surfaces (snackbars, tooltips).
  final Color inversePrimary;

  final Color scrim;
  final Color shadow;

  static const AppColorsExtension light = AppColorsExtension(
    background: AppColors.neutralNormal,
    surface: AppColors.neutralLight,
    surfaceVariant: AppColors.neutralNormalHover,
    surfaceElevated: AppColors.neutralLight,
    textPrimary: AppColors.secondaryDarker,
    textSecondary: AppColors.neutralDarker,
    textDisabled: AppColors.neutralDarkHover,
    hint: AppColors.neutralDarkActive,
    border: AppColors.neutralNormalHover,
    // #6f7070 clears 3:1 against background, surface, AND the fill — #949595
    // fell to 2.86:1 on the scaffold background.
    borderStrong: AppColors.neutralDarkActive,
    primary: AppColors.primaryNormalHover,
    primaryHover: AppColors.primaryNormal,
    primaryActive: AppColors.primaryNormalActive,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDarker,
    primarySoft: AppColors.primaryLightActive,
    secondary: AppColors.secondaryNormal,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.secondaryLight,
    onSecondaryContainer: AppColors.secondaryDarker,
    success: AppColors.successNormalActive,
    successContainer: AppColors.successLight,
    onSuccessContainer: AppColors.successDarker,
    successSoft: AppColors.successLightActive,
    warning: AppColors.warningDark,
    warningContainer: AppColors.warningLight,
    onWarningContainer: AppColors.warningDarker,
    error: AppColors.errorNormal,
    onError: AppColors.white,
    errorContainer: AppColors.errorLight,
    onErrorContainer: AppColors.errorDarker,
    inversePrimary: AppColors.primaryLightActive,
    scrim: AppColors.scrim,
    shadow: AppColors.black,
  );

  static const AppColorsExtension dark = AppColorsExtension(
    background: AppColors.secondaryDarker,
    surface: AppColors.secondaryDarkActive,
    surfaceVariant: AppColors.secondaryDarkHover,
    surfaceElevated: AppColors.secondaryDark,
    textPrimary: AppColors.neutralLight,
    textSecondary: AppColors.neutralNormalActive,
    textDisabled: AppColors.neutralDarkActive,
    hint: AppColors.neutralDarkHover,
    border: AppColors.secondaryDark,
    borderStrong: AppColors.neutralDarkActive,
    primary: AppColors.primaryLightActive,
    primaryHover: AppColors.primaryLightHover,
    primaryActive: AppColors.primaryLight,
    onPrimary: AppColors.primaryDarker,
    primaryContainer: AppColors.primaryDarkHover,
    onPrimaryContainer: AppColors.primaryLight,
    primarySoft: AppColors.primarySoftDark,
    secondary: AppColors.secondaryLightActive,
    onSecondary: AppColors.secondaryDarker,
    secondaryContainer: AppColors.secondaryDark,
    onSecondaryContainer: AppColors.secondaryLight,
    success: AppColors.successNormal,
    successContainer: AppColors.successDarker,
    onSuccessContainer: AppColors.successLightActive,
    successSoft: AppColors.successSoftDark,
    warning: AppColors.warningNormal,
    warningContainer: AppColors.warningDarker,
    onWarningContainer: AppColors.warningLightActive,
    error: AppColors.errorLightActive,
    onError: AppColors.errorDarker,
    errorContainer: AppColors.errorDarker,
    onErrorContainer: AppColors.errorLight,
    inversePrimary: AppColors.secondaryNormal,
    scrim: AppColors.scrim,
    shadow: AppColors.black,
  );

  @override
  AppColorsExtension copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? hint,
    Color? border,
    Color? borderStrong,
    Color? primary,
    Color? primaryHover,
    Color? primaryActive,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? primarySoft,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? successSoft,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? inversePrimary,
    Color? scrim,
    Color? shadow,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      hint: hint ?? this.hint,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryActive: primaryActive ?? this.primaryActive,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      primarySoft: primarySoft ?? this.primarySoft,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      successSoft: successSoft ?? this.successSoft,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      inversePrimary: inversePrimary ?? this.inversePrimary,
      scrim: scrim ?? this.scrim,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColorsExtension lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceVariant:
          Color.lerp(surfaceVariant, other.surfaceVariant, t) ?? surfaceVariant,
      surfaceElevated:
          Color.lerp(surfaceElevated, other.surfaceElevated, t) ??
          surfaceElevated,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textDisabled:
          Color.lerp(textDisabled, other.textDisabled, t) ?? textDisabled,
      hint: Color.lerp(hint, other.hint, t) ?? hint,
      border: Color.lerp(border, other.border, t) ?? border,
      borderStrong:
          Color.lerp(borderStrong, other.borderStrong, t) ?? borderStrong,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primaryHover:
          Color.lerp(primaryHover, other.primaryHover, t) ?? primaryHover,
      primaryActive:
          Color.lerp(primaryActive, other.primaryActive, t) ?? primaryActive,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t) ?? onPrimary,
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t) ??
          primaryContainer,
      onPrimaryContainer:
          Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t) ??
          onPrimaryContainer,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t) ?? primarySoft,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t) ?? onSecondary,
      secondaryContainer:
          Color.lerp(secondaryContainer, other.secondaryContainer, t) ??
          secondaryContainer,
      onSecondaryContainer:
          Color.lerp(onSecondaryContainer, other.onSecondaryContainer, t) ??
          onSecondaryContainer,
      success: Color.lerp(success, other.success, t) ?? success,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t) ??
          successContainer,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t) ??
          onSuccessContainer,
      successSoft: Color.lerp(successSoft, other.successSoft, t) ?? successSoft,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t) ??
          warningContainer,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t) ??
          onWarningContainer,
      error: Color.lerp(error, other.error, t) ?? error,
      onError: Color.lerp(onError, other.onError, t) ?? onError,
      errorContainer:
          Color.lerp(errorContainer, other.errorContainer, t) ?? errorContainer,
      onErrorContainer:
          Color.lerp(onErrorContainer, other.onErrorContainer, t) ??
          onErrorContainer,
      inversePrimary:
          Color.lerp(inversePrimary, other.inversePrimary, t) ?? inversePrimary,
      scrim: Color.lerp(scrim, other.scrim, t) ?? scrim,
      shadow: Color.lerp(shadow, other.shadow, t) ?? shadow,
    );
  }
}

/// Read-only access to the active palette, e.g. `context.colors.primary`.
extension AppColorsContext on BuildContext {
  AppColorsExtension get colors {
    final theme = Theme.of(this);
    return theme.extension<AppColorsExtension>() ??
        (theme.brightness == Brightness.dark
            ? AppColorsExtension.dark
            : AppColorsExtension.light);
  }
}
