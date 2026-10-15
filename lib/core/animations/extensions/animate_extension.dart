import 'package:flutter/widgets.dart';

import '../entrance/blur_in.dart';
import '../entrance/fade_in.dart';
import '../entrance/fade_slide_in.dart';
import '../entrance/scale_in.dart';
import '../entrance/slide_in.dart';
import '../feedback/app_haptics.dart';
import '../feedback/bounce_widget.dart';
import '../feedback/pulse_widget.dart';
import '../feedback/shake_widget.dart';
import '../feedback/tap_scale.dart';
import '../scroll/reveal_on_scroll.dart';
import '../staggered/staggered_list_item.dart';

/// Fluent entrance and feedback animations on any widget: write
/// `card.fadeSlideIn(...)` instead of `FadeSlideIn(child: card)`.
///
/// Each method is a thin pass-through to the widget of the same name and
/// exposes only the parameters callers usually touch; the defaults live on
/// the widgets themselves, so behaviour is identical either way. Anything
/// beyond that (duration, curve, offset, a different slide edge) is written
/// with the widget directly:
///
/// ```dart
/// OrderCard(order).fadeSlideIn(delay: AppDurations.stagger * index)
///
/// InvoiceRow(invoice).tapScale(onTap: () => open(invoice))
///
/// final shake = ShakeController();
/// // ...
/// LoginForm().shake(shake, haptic: true)
/// ```
extension WidgetAnimations on Widget {
  /// [FadeIn]: fades this widget in once, on its first build.
  ///
  /// [delay] holds the start; pass `AppDurations.stagger * index` for
  /// cascades. Rebuilds never replay it.
  Widget fadeIn({Duration delay = Duration.zero}) =>
      FadeIn(delay: delay, child: this);

  /// [SlideIn.fromBottom]: this widget rises into place once.
  ///
  /// For the other edges use `SlideIn.fromStart(...)` and friends directly —
  /// the leading and trailing variants mirror themselves in RTL.
  Widget slideIn({Duration delay = Duration.zero}) =>
      SlideIn.fromBottom(delay: delay, child: this);

  /// [ScaleIn]: this widget zooms subtly into place once.
  Widget scaleIn({Duration delay = Duration.zero}) =>
      ScaleIn(delay: delay, child: this);

  /// [FadeSlideIn]: this widget fades and rises into place once — the
  /// default entrance for cards and list rows.
  Widget fadeSlideIn({Duration delay = Duration.zero}) =>
      FadeSlideIn(delay: delay, child: this);

  /// [BlurIn]: this widget resolves from blurred to sharp once — the
  /// entrance for dialog and overlay content.
  Widget blurIn({Duration delay = Duration.zero}) =>
      BlurIn(delay: delay, child: this);

  /// [TapScale]: presses this widget down and springs it back —
  /// buttons, tiles, anything tappable.
  ///
  /// Press feedback keeps the child's own gestures untouched; [haptic] plays
  /// on press down ([AppHaptics] is a no-op while globally disabled).
  Widget tapScale({
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool enabled = true,
    HapticType haptic = HapticType.none,
  }) => TapScale(
    onTap: onTap,
    onLongPress: onLongPress,
    enabled: enabled,
    haptic: haptic,
    child: this,
  );

  /// [ShakeWidget]: shakes this widget horizontally as error feedback once
  /// [controller.shake()] is called (e.g. from a `BlocListener`).
  ///
  /// [haptic] adds the error buzz on every shake.
  Widget shake(ShakeController controller, {bool haptic = false}) =>
      ShakeWidget(controller: controller, haptic: haptic, child: this);

  /// [PulseWidget]: breathes this widget in scale and opacity in a loop —
  /// badges and "needs attention" markers.
  ///
  /// Unlike [PulseWidget]'s own default, the loop is on by default here:
  /// `.pulse()` means "start pulsing". Flip [active] off to rest.
  Widget pulse({bool active = true}) =>
      PulseWidget(active: active, child: this);

  /// [BounceWidget]: plays a one-shot scale bounce once [controller.bounce()]
  /// is called (e.g. from a `BlocListener`) — a row landing, a counter
  /// ticking up.
  Widget bounce(BounceController controller) =>
      BounceWidget(controller: controller, child: this);

  /// [StaggeredListItem]: entrance for row [index] of a lazy list — row
  /// `index` starts `index * AppDurations.stagger` later and never replays.
  ///
  /// ```dart
  /// ListView.builder(
  ///   itemBuilder: (context, index) =>
  ///       OrderRow(order: orders[index]).staggered(index: index),
  /// )
  /// ```
  Widget staggered({required int index}) =>
      StaggeredListItem(index: index, child: this);

  /// [RevealOnScroll]: fades this widget in the first time it enters the
  /// viewport of the nearest [Scrollable]; it never hides or replays.
  Widget revealOnScroll() => RevealOnScroll(child: this);
}
