import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary. Normal #2373f4 is the brand accent for states and graphics:
  // white on it measures 4.35:1, under WCAG AA for labels, so text-bearing
  // surfaces use Normal:hover #2068dc (5.1:1 with white, 4.9:1 on the light
  // background) — see the `primary` token.
  static const Color primaryLight = Color(0xFFE9F1FE); // Light
  static const Color primaryLightHover = Color(0xFFDEEAFD); // Light:hover
  static const Color primaryLightActive = Color(0xFFBBD4FC); // Light:active
  static const Color primaryNormal = Color(0xFF2373F4); // Normal
  static const Color primaryNormalHover = Color(0xFF2068DC); // Normal:hover
  static const Color primaryNormalActive = Color(0xFF1C5CC3); // Normal:active
  static const Color primaryDarkHover = Color(0xFF154592); // Dark:hover
  static const Color primaryDarker = Color(0xFF0C2855); // Darker

  // Secondary. The Dark ramp doubles as the dark-mode surface ladder
  // (Darker → Dark:active → Dark:hover → Dark) so elevation reads as
  // "slightly lighter than the background" without inventing colors.
  static const Color secondaryLight = Color(0xFFE7EAF2); // Light
  static const Color secondaryLightActive = Color(0xFFB5BED8); // Light:active
  static const Color secondaryNormal = Color(0xFF112E81); // Normal
  static const Color secondaryDark = Color(0xFF0D2361); // Dark
  static const Color secondaryDarkHover = Color(0xFF0A1C4D); // Dark:hover
  static const Color secondaryDarkActive = Color(0xFF08153A); // Dark:active
  static const Color secondaryDarker = Color(0xFF06102D); // Darker

  // Success. Normal reads as text only in dark mode (5.7:1); light text uses
  // the darker Normal:active shade so both directions clear AA (4.9:1).
  static const Color successLight = Color(0xFFE8F6ED); // Light
  static const Color successLightActive = Color(0xFFB7E2C7); // Light:active
  static const Color successNormal = Color(0xFF16A34A); // Normal
  static const Color successNormalActive = Color(0xFF12823B); // Normal:active
  static const Color successDarker = Color(0xFF08391A); // Darker

  // Warning. Same text-safety swap: Dark carries text in light mode (5.0:1),
  // Normal carries it in dark mode (5.9:1).
  static const Color warningLight = Color(0xFFFBF1E6); // Light
  static const Color warningLightActive = Color(0xFFF3D5B2); // Light:active
  static const Color warningNormal = Color(0xFFD97706); // Normal
  static const Color warningDark = Color(0xFFA35905); // Dark
  static const Color warningDarker = Color(0xFF4C2A02); // Darker

  // Error. Normal is AA-safe on white and with white text (4.8:1) in light
  // mode; the Light:active pink replaces it in dark mode (11.4:1 on the
  // dark background — Normal would only reach 3.9:1).
  static const Color errorLight = Color(0xFFFCE9E9); // Light
  static const Color errorLightActive = Color(0xFFF4BCBC); // Light:active
  static const Color errorNormal = Color(0xFFDC2626); // Normal
  static const Color errorDarker = Color(0xFF4D0D0D); // Darker

  // Neutral. The ramp stops at Darker #565757 (7:1 on white), so pure text
  // and dark surfaces come from Secondary/Additional below.
  static const Color neutralLight = Color(0xFFFEFEFE); // Light
  static const Color neutralNormal = Color(0xFFF7F8F9); // Normal
  static const Color neutralNormalHover = Color(0xFFDEDFE0); // Normal:hover
  static const Color neutralNormalActive = Color(0xFFC6C6C7); // Normal:active
  static const Color neutralDarkHover = Color(0xFF949595); // Dark:hover
  static const Color neutralDarkActive = Color(0xFF6F7070); // Dark:active
  static const Color neutralDarker = Color(0xFF565757); // Darker

  // --- Additional colors (not in the palette) -----------------------------
  // The palette has no pure white/black and no overlay shade; kept minimal so
  // nothing else in the app ever hardcodes a color.
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  /// Modal barrier behind dialogs and bottom sheets.
  static const Color scrim = Color(0x80000000);

  // Dark-mode-only accent fills for the `primarySoft` / `successSoft` tokens.
  // Each ramp has no step between its Dark:hover container and its Light:active
  // tint, so these are purpose-built mid-tones, not ramp positions.
  static const Color primarySoftDark = Color(0xFF3E7BE0);
  static const Color successSoftDark = Color(0xFF0F6E32);
}
