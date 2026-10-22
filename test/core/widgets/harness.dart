import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/responsive/responsive_scaler.dart';
import 'package:orbit/core/theme/app_theme.dart';

/// Binds a test scaler with configurable axis factors so tests can assert
/// which responsive axis a value reads.
class AxisTestScaler extends ResponsiveScaler {
  const AxisTestScaler({
    this.widthFactor = 1,
    this.heightFactor = 1,
    this.adaptiveFactor = 1,
  });

  final double widthFactor;
  final double heightFactor;
  final double adaptiveFactor;

  @override
  double width(double value) => value * widthFactor;

  @override
  double height(double value) => value * heightFactor;

  @override
  double radius(double value) => value * adaptiveFactor;

  @override
  double font(double value) => value * adaptiveFactor;

  @override
  double adapt(double value) => value * adaptiveFactor;

  @override
  bool get isInitialized => true;

  @override
  void configure(MediaQueryData metrics, {required Size designSize}) {}

  @override
  Future<void> ensureInitialized() async {}
}

/// Pumps [widget] inside a [MaterialApp] with [AppTheme.light] and the
/// given [scaler]. Use [textScaleFactor] to test large-text accessibility.
/// If [settle] is true (default), waits for all animations to complete.
Future<void> pumpWidget(
  WidgetTester tester,
  Widget widget, {
  AxisTestScaler? scaler,
  double textScaleFactor = 1.0,
  TextDirection textDirection = TextDirection.ltr,
  ThemeMode themeMode = ThemeMode.light,
  bool settle = true,
}) async {
  final effectiveScaler = scaler ?? const AxisTestScaler();
  effectiveScaler.configure(
    const MediaQueryData(),
    designSize: const Size(412, 917),
  );

  await tester.pumpWidget(
    Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScaleFactor),
          disableAnimations: true,
        ),
        child: Directionality(
          textDirection: textDirection,
          child: TranslationProvider(
            child: MaterialApp(
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              home: Scaffold(body: widget),
            ),
          ),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  }
}
