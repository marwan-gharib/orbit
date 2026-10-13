import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:orbit/core/responsive/responsive_scaler.dart';

/// THE ONLY file in `lib/` allowed to import `package:flutter_screenutil`.
/// To swap or remove the package, rewrite [createResponsiveScaler] to return
/// another [ResponsiveScaler] (or `const IdentityResponsiveScaler()`) and drop
/// the dependency from `pubspec.yaml` — nothing else references the package.
ResponsiveScaler createResponsiveScaler() => ScreenUtilScaler._();

final class ScreenUtilScaler extends ResponsiveScaler {
  ScreenUtilScaler._();

  // Deliberate exception to ARCH-9, same reasoning as `Responsive._scaler`:
  // `configure()` must record fresh screen metrics at runtime. Four scalar
  // fields are collapsed into one immutable snapshot so there is a single
  // mutation point instead of four.
  _ScaleSnapshot _snapshot = const _ScaleSnapshot.identity();

  @override
  bool get isInitialized => _snapshot.isConfigured;

  @override
  void configure(MediaQueryData metrics, {required Size designSize}) {
    if (metrics.size.isEmpty) {
      _snapshot = const _ScaleSnapshot.identity();
      return;
    }

    // splitScreenMode/minTextAdapt must be passed on the first call: 5.9.3
    // reads those late fields when an argument is null.
    ScreenUtil.configure(
      data: metrics,
      designSize: designSize,
      splitScreenMode: false,
      minTextAdapt: true,
      fontSizeResolver: FontSizeResolvers.width,
    );

    final screen = ScreenUtil();
    _snapshot = _ScaleSnapshot(
      widthScale: _clamp(screen.scaleWidth),
      heightScale: _clamp(screen.scaleHeight),
      adaptiveScale: _clamp(math.min(screen.scaleWidth, screen.scaleHeight)),
    );
  }

  @override
  double width(double value) => _snapshot.width(value);

  @override
  double height(double value) => _snapshot.height(value);

  @override
  double radius(double value) => _snapshot.adaptive(value);

  @override
  double font(double value) => _snapshot.adaptive(value);

  @override
  double adapt(double value) => _snapshot.adaptive(value);

  @override
  Future<void> ensureInitialized() => ScreenUtil.ensureScreenSize();

  static double _clamp(double scale) => scale
      .clamp(ResponsiveScaler.minScaleFactor, ResponsiveScaler.maxScaleFactor)
      .toDouble();
}

/// Immutable screen-ratio snapshot; identity means "not configured yet", so
/// every value passes through unchanged.
@immutable
class _ScaleSnapshot {
  const _ScaleSnapshot({
    required this.widthScale,
    required this.heightScale,
    required this.adaptiveScale,
  }) : isConfigured = true;

  const _ScaleSnapshot.identity()
    : widthScale = 1,
      heightScale = 1,
      adaptiveScale = 1,
      isConfigured = false;

  final double widthScale;
  final double heightScale;
  final double adaptiveScale;
  final bool isConfigured;

  double width(double value) => isConfigured ? value * widthScale : value;

  double height(double value) => isConfigured ? value * heightScale : value;

  double adaptive(double value) => isConfigured ? value * adaptiveScale : value;
}
