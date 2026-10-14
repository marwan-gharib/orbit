import 'package:flutter/widgets.dart';
import 'package:orbit/core/responsive/responsive_scaler.dart';
import 'package:orbit/core/responsive/screen_util_scaler.dart'
    show createResponsiveScaler;

/// App-wide facade for responsive values; feature/widget/theme code talks
/// only to this class, never a specific scaling engine. Before
/// [ResponsiveScope] binds the engine — in unit tests and any widget test
/// that does not pump it — the scaler is an identity transform: inputs pass
/// through unchanged and nothing throws.
abstract final class Responsive {
  /// Design baseline in logical pixels (width x height, portrait phone).
  static const Size designSize = Size(412, 917);

  // Deliberate exception to ARCH-9: [ResponsiveScope] must swap the engine on
  // mount/unmount, so this cannot be final without turning the facade into an
  // injected instance — a much larger change than this task allows (H-7).
  static ResponsiveScaler _scaler = createResponsiveScaler();

  /// Binds the app's scaling engine (called by [ResponsiveScope] on mount).
  static void bindDefault() => _scaler = createResponsiveScaler();

  /// Restores the identity scaler so tests outside the scope keep the
  /// pre-scale behaviour.
  static void unbind() => _scaler = const IdentityResponsiveScaler();

  /// Binds an arbitrary implementation (fakes in tests, a future backend).
  static void bind(ResponsiveScaler scaler) => _scaler = scaler;

  /// Whether the bound engine has real screen metrics yet.
  static bool get isInitialized => _scaler.isInitialized;

  static double width(double value) => _scaler.width(value);

  static double height(double value) => _scaler.height(value);

  static double radius(double value) => _scaler.radius(value);

  static double font(double value) => _scaler.font(value);

  static double adapt(double value) => _scaler.adapt(value);

  /// Forwards current screen metrics to the bound engine.
  static void configure(MediaQueryData metrics, {required Size designSize}) =>
      _scaler.configure(metrics, designSize: designSize);

  /// Waits for the engine to be usable. Nothing calls it yet: the
  /// `ResponsiveScope` mounted in `main()` binds the engine in `initState`
  /// and configures it in the first `didChangeDependencies`, so the facade is
  /// ready before the app's first frame.
  static Future<void> ensureInitialized() => _scaler.ensureInitialized();
}
