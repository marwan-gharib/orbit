import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:orbit/core/constants/fonts.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  /// System status/navigation-bar style for [brightness]. Applied to the
  /// AppBar theme and wrapped around the whole app in `MaterialApp.builder`,
  /// so screens without an AppBar get the same treatment. No contrast scrim:
  /// icon brightness already follows the mode's background.
  static SystemUiOverlayStyle overlayStyle(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    );
  }

  // Material 3 state-layer alphas: hover/focus tints, pressed tints, and the
  // text-selection highlight.
  static const double _hoverOverlayAlpha = 0.08;
  static const double _pressedOverlayAlpha = 0.12;
  static const double _selectionOverlayAlpha = 0.30;

  static ThemeData _build(Brightness brightness) {
    final colors = brightness == Brightness.dark
        ? AppColorsExtension.dark
        : AppColorsExtension.light;
    final textStyles = AppTextStylesExtension.forColors(colors);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: _colorScheme(brightness, colors),
      fontFamily: Fonts.family,
      textTheme: _textTheme(textStyles),
      extensions: <ThemeExtension<dynamic>>[colors, textStyles],
      // App chrome.
      scaffoldBackgroundColor: colors.background,
      dividerColor: colors.border,
      disabledColor: colors.textDisabled,
      shadowColor: colors.shadow,
      hoverColor: colors.primary.withValues(alpha: _hoverOverlayAlpha),
      focusColor: colors.primary.withValues(alpha: _pressedOverlayAlpha),
      splashColor: colors.primary.withValues(alpha: _pressedOverlayAlpha),
      textSelectionTheme: _textSelection(colors),
      // Component themes.
      appBarTheme: _appBar(colors, textStyles, brightness),
      elevatedButtonTheme: _elevatedButton(colors, textStyles),
      filledButtonTheme: _filledButton(colors, textStyles),
      outlinedButtonTheme: _outlinedButton(colors, textStyles),
      textButtonTheme: _textButton(colors, textStyles),
      iconButtonTheme: _iconButton(colors),
      inputDecorationTheme: _inputDecoration(colors, textStyles),
      cardTheme: _card(colors),
      dialogTheme: _dialog(colors, textStyles),
      bottomSheetTheme: _bottomSheet(colors),
      navigationBarTheme: _navigationBar(colors, textStyles),
      bottomNavigationBarTheme: _bottomNavigationBar(colors),
      tabBarTheme: _tabBar(colors),
      chipTheme: _chip(colors, textStyles),
      switchTheme: _switch(colors),
      checkboxTheme: _checkbox(colors),
      radioTheme: _radio(colors),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
      snackBarTheme: _snackBar(colors, textStyles),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.surfaceVariant,
        circularTrackColor: colors.surfaceVariant,
      ),
      listTileTheme: _listTile(colors, textStyles),
      tooltipTheme: _tooltip(colors, textStyles),
      floatingActionButtonTheme: _fab(colors),
      datePickerTheme: _datePicker(colors),
      timePickerTheme: _timePicker(colors),
    );
  }

  static ColorScheme _colorScheme(Brightness brightness, AppColorsExtension c) {
    final isDark = brightness == Brightness.dark;
    return ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primaryContainer,
      onPrimaryContainer: c.onPrimaryContainer,
      secondary: c.secondary,
      onSecondary: c.onSecondary,
      secondaryContainer: c.secondaryContainer,
      onSecondaryContainer: c.onSecondaryContainer,
      error: c.error,
      onError: c.onError,
      errorContainer: c.errorContainer,
      onErrorContainer: c.onErrorContainer,
      surface: c.surface,
      onSurface: c.textPrimary,
      surfaceDim: c.background,
      surfaceBright: isDark ? c.surfaceElevated : c.surface,
      surfaceContainerLowest: isDark ? c.background : c.surface,
      surfaceContainerLow: c.surface,
      surfaceContainer: isDark ? c.surfaceVariant : c.surface,
      surfaceContainerHigh: isDark ? c.surfaceElevated : c.surfaceVariant,
      surfaceContainerHighest: isDark ? c.surfaceElevated : c.surfaceVariant,
      onSurfaceVariant: c.textSecondary,
      outline: c.borderStrong,
      outlineVariant: c.border,
      shadow: c.shadow,
      scrim: c.scrim,
      inverseSurface: c.textPrimary,
      onInverseSurface: c.background,
      inversePrimary: c.inversePrimary,
    );
  }

  static TextTheme _textTheme(AppTextStylesExtension s) => TextTheme(
    displayLarge: s.displayLarge,
    displayMedium: s.displayMedium,
    displaySmall: s.displaySmall,
    headlineLarge: s.headlineLarge,
    headlineMedium: s.headlineMedium,
    headlineSmall: s.headlineSmall,
    titleLarge: s.titleLarge,
    titleMedium: s.titleMedium,
    titleSmall: s.titleSmall,
    bodyLarge: s.bodyLarge,
    bodyMedium: s.bodyMedium,
    bodySmall: s.bodySmall,
    labelLarge: s.labelLarge,
    labelMedium: s.labelMedium,
    labelSmall: s.labelSmall,
  );

  static TextSelectionThemeData _textSelection(AppColorsExtension c) =>
      TextSelectionThemeData(
        cursorColor: c.primary,
        selectionColor: c.primary.withValues(alpha: _selectionOverlayAlpha),
        selectionHandleColor: c.primary,
      );

  static AppBarThemeData _appBar(
    AppColorsExtension c,
    AppTextStylesExtension t,
    Brightness brightness,
  ) => AppBarThemeData(
    backgroundColor: c.background,
    foregroundColor: c.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: c.textPrimary),
    actionsIconTheme: IconThemeData(color: c.textPrimary),
    titleTextStyle: t.titleLarge,
    systemOverlayStyle: overlayStyle(brightness),
  );

  // Shared shape/padding/label for every button; per-button themes copyWith
  // their own colors on top.
  static ButtonStyle _buttonBase(AppTextStylesExtension t) => ButtonStyle(
    textStyle: WidgetStatePropertyAll(t.labelLarge),
    padding: WidgetStatePropertyAll(AppSpacing.button),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
    ),
    elevation: const WidgetStatePropertyAll(0),
  );

  static WidgetStateProperty<Color> _stateOverlay(Color tint) =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return tint.withValues(alpha: _pressedOverlayAlpha);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return tint.withValues(alpha: _hoverOverlayAlpha);
        }
        return Colors.transparent;
      });

  static FilledButtonThemeData _filledButton(
    AppColorsExtension c,
    AppTextStylesExtension t,
  ) => FilledButtonThemeData(
    style: _buttonBase(t).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return c.surfaceVariant;
        }
        if (states.contains(WidgetState.pressed)) return c.primaryActive;
        if (states.contains(WidgetState.hovered)) return c.primaryHover;
        return c.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? c.textDisabled
            : c.onPrimary,
      ),
      overlayColor: _stateOverlay(c.onPrimary),
    ),
  );

  static ElevatedButtonThemeData _elevatedButton(
    AppColorsExtension c,
    AppTextStylesExtension t,
  ) => ElevatedButtonThemeData(
    style: _buttonBase(t).copyWith(
      elevation: const WidgetStatePropertyAll(1),
      backgroundColor: WidgetStatePropertyAll(c.surface),
      foregroundColor: WidgetStatePropertyAll(c.primary),
      overlayColor: _stateOverlay(c.primary),
    ),
  );

  static OutlinedButtonThemeData _outlinedButton(
    AppColorsExtension c,
    AppTextStylesExtension t,
  ) => OutlinedButtonThemeData(
    style: _buttonBase(t).copyWith(
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.disabled) ? c.textDisabled : c.primary,
      ),
      overlayColor: _stateOverlay(c.primary),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: c.border);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed)) {
          return BorderSide(color: c.primary);
        }
        return BorderSide(color: c.borderStrong);
      }),
    ),
  );

  static TextButtonThemeData _textButton(
    AppColorsExtension c,
    AppTextStylesExtension t,
  ) => TextButtonThemeData(
    style: _buttonBase(t).copyWith(
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.disabled) ? c.textDisabled : c.primary,
      ),
      overlayColor: _stateOverlay(c.primary),
    ),
  );

  static IconButtonThemeData _iconButton(AppColorsExtension c) =>
      IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(c.textPrimary),
          overlayColor: _stateOverlay(c.primary),
          // UI-7: every icon button gets at least a 48x48 tap target.
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          shape: const WidgetStatePropertyAll(CircleBorder()),
        ),
      );

  static InputDecorationThemeData _inputDecoration(
    AppColorsExtension c,
    AppTextStylesExtension t,
  ) {
    OutlineInputBorder border(BorderSide side) =>
        OutlineInputBorder(borderRadius: AppRadius.borderSm, borderSide: side);
    return InputDecorationThemeData(
      filled: true,
      fillColor: c.surfaceVariant,
      labelStyle: t.bodyMedium.copyWith(color: c.textSecondary),
      hintStyle: t.bodyMedium.copyWith(color: c.textDisabled),
      errorStyle: t.labelSmall.copyWith(color: c.error),
      floatingLabelStyle: t.bodyMedium.copyWith(color: c.primary),
      // Width stays 1px except focus/error (2px) so only those states shift
      // content, and the primary/error border wins over the grey one.
      border: border(BorderSide(color: c.borderStrong)),
      enabledBorder: border(BorderSide(color: c.borderStrong)),
      disabledBorder: border(BorderSide(color: c.border)),
      focusedBorder: border(BorderSide(color: c.primary, width: 2)),
      errorBorder: border(BorderSide(color: c.error)),
      focusedErrorBorder: border(BorderSide(color: c.error, width: 2)),
    );
  }

  static CardThemeData _card(AppColorsExtension c) => CardThemeData(
    color: c.surface,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderLg,
      side: BorderSide(color: c.border),
    ),
  );

  static DialogThemeData _dialog(
    AppColorsExtension c,
    AppTextStylesExtension t,
  ) => DialogThemeData(
    backgroundColor: c.surfaceElevated,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
    titleTextStyle: t.headlineSmall,
    contentTextStyle: t.bodyMedium,
  );

  static BottomSheetThemeData _bottomSheet(AppColorsExtension c) =>
      BottomSheetThemeData(
        backgroundColor: c.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: c.borderStrong,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(AppRadius.xl),
            topEnd: Radius.circular(AppRadius.xl),
          ),
        ),
      );

  static NavigationBarThemeData _navigationBar(
    AppColorsExtension c,
    AppTextStylesExtension t,
  ) => NavigationBarThemeData(
    backgroundColor: c.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    indicatorColor: c.primaryContainer,
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        color: states.contains(WidgetState.selected)
            ? c.primary
            : c.textSecondary,
      ),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => t.labelMedium.copyWith(
        color: states.contains(WidgetState.selected)
            ? c.primary
            : c.textSecondary,
      ),
    ),
  );

  static BottomNavigationBarThemeData _bottomNavigationBar(
    AppColorsExtension c,
  ) => BottomNavigationBarThemeData(
    backgroundColor: c.surface,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: c.primary,
    unselectedItemColor: c.textSecondary,
    selectedIconTheme: IconThemeData(color: c.primary),
    unselectedIconTheme: IconThemeData(color: c.textSecondary),
  );

  static TabBarThemeData _tabBar(AppColorsExtension c) => TabBarThemeData(
    labelColor: c.primary,
    unselectedLabelColor: c.textSecondary,
    indicatorColor: c.primary,
    dividerColor: c.border,
  );

  static ChipThemeData _chip(AppColorsExtension c, AppTextStylesExtension t) =>
      ChipThemeData(
        backgroundColor: c.surfaceVariant,
        selectedColor: c.primaryContainer,
        side: BorderSide(color: c.border),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
        labelStyle: t.labelMedium,
        checkmarkColor: c.primary,
        deleteIconColor: c.textSecondary,
        elevation: 0,
      );

  static SwitchThemeData _switch(AppColorsExtension c) => SwitchThemeData(
    trackColor: WidgetStateProperty.resolveWith<Color?>(
      (states) =>
          states.contains(WidgetState.selected) ? c.primary : c.surfaceVariant,
    ),
    thumbColor: WidgetStateProperty.resolveWith<Color?>(
      (states) =>
          states.contains(WidgetState.selected) ? c.onPrimary : c.borderStrong,
    ),
    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
      (states) => states.contains(WidgetState.selected) ? null : c.borderStrong,
    ),
  );

  static CheckboxThemeData _checkbox(AppColorsExtension c) => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color?>(
      (states) => states.contains(WidgetState.selected) ? c.primary : c.surface,
    ),
    checkColor: WidgetStatePropertyAll(c.onPrimary),
    side: BorderSide(color: c.borderStrong),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXs),
  );

  static RadioThemeData _radio(AppColorsExtension c) => RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color?>(
      (states) =>
          states.contains(WidgetState.selected) ? c.primary : c.borderStrong,
    ),
  );

  static SnackBarThemeData _snackBar(
    AppColorsExtension c,
    AppTextStylesExtension t,
  ) => SnackBarThemeData(
    // Inverted surface: dark navy on light themes, near-white on dark
    // themes — reads as an overlay on any background.
    backgroundColor: c.textPrimary,
    contentTextStyle: t.bodyMedium.copyWith(color: c.background),
    actionTextColor: c.inversePrimary,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
  );

  static ListTileThemeData _listTile(
    AppColorsExtension c,
    AppTextStylesExtension t,
  ) => ListTileThemeData(
    iconColor: c.textSecondary,
    textColor: c.textPrimary,
    titleTextStyle: t.bodyLarge,
    subtitleTextStyle: t.bodyMedium.copyWith(color: c.textSecondary),
    contentPadding: AppSpacing.pageHorizontal,
  );

  static TooltipThemeData _tooltip(
    AppColorsExtension c,
    AppTextStylesExtension t,
  ) => TooltipThemeData(
    decoration: BoxDecoration(
      color: c.textPrimary,
      borderRadius: AppRadius.borderSm,
    ),
    textStyle: t.labelSmall.copyWith(color: c.background),
  );

  static FloatingActionButtonThemeData _fab(AppColorsExtension c) =>
      FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
      );

  static DatePickerThemeData _datePicker(AppColorsExtension c) =>
      DatePickerThemeData(
        backgroundColor: c.surfaceElevated,
        headerBackgroundColor: c.primaryContainer,
        headerForegroundColor: c.onPrimaryContainer,
        dayForegroundColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected)
              ? c.onPrimary
              : c.textPrimary,
        ),
        dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected) ? c.primary : null,
        ),
        todayForegroundColor: WidgetStatePropertyAll<Color?>(c.primary),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      );

  static TimePickerThemeData _timePicker(AppColorsExtension c) =>
      TimePickerThemeData(
        backgroundColor: c.surfaceElevated,
        hourMinuteColor: c.surfaceVariant,
        hourMinuteTextColor: c.textPrimary,
        dayPeriodColor: c.surfaceVariant,
        dayPeriodTextColor: c.textPrimary,
        dialBackgroundColor: c.surfaceVariant,
        dialHandColor: c.primary,
        dialTextColor: c.textPrimary,
        entryModeIconColor: c.textSecondary,
      );
}
