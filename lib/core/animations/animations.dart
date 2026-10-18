/// Orbit's reusable animation foundation.
///
/// Every feature draws its motion from these tokens and widgets:
///
/// ```dart
/// import 'package:orbit/core/animations/animations.dart';
///
/// FadeSlideIn(
///   delay: AppDurations.stagger * index,
///   child: const OrderRow(),
/// )
/// ```
///
/// Groups: `tokens/` (durations, curves, numeric constants), `entrance/`
/// (widgets that play once on first build), `extensions/` (the
/// `WidgetAnimations` facade: `card.fadeSlideIn(delay: ...)` on any widget),
/// `staggered/` (index-delayed
/// entrances for lists, grids and columns that never replay on scroll-back),
/// `feedback/` (interaction motion: press, shake, pulse, bounce, plus the
/// `AppHaptics` gateway),
/// `loading/` (skeletons, shimmer and pulsing placeholders, progress bars),
/// `overlays/` (dialogs, bottom sheets, snackbars and popup menus that share
/// one motion profile),
/// `state/` (transitions between loading, content, error, empty, expanded
/// and visible states), `scroll/` (widgets driven by the nearest scroll
/// position: reveal, parallax, collapsing header, app bar fade),
/// `lottie/` (`AppLottie`, the single wrapper around the `lottie` package,
/// plus the `AppLottieAssets` path constants it plays),
/// `navigation/` (route page transitions, the `AppRoute` helper that applies
/// the app-wide default, `AppHero` flights and the card-to-details container
/// transform). Every motion widget in these groups honours
/// `MediaQuery.disableAnimations` and RTL; `AppHaptics` is gated by its own
/// `enabled` switch instead.
library;

export '../constants/app_lottie_assets.dart';
export 'entrance/blur_in.dart';
export 'entrance/assembly_layer.dart';
export 'entrance/clip_reveal.dart';
export 'entrance/entrance.dart';
export 'entrance/fade_in.dart';
export 'entrance/fade_slide_in.dart';
export 'entrance/scale_in.dart';
export 'entrance/slide_in.dart';
export 'extensions/animate_extension.dart';
export 'feedback/app_haptics.dart';
export 'feedback/bounce_widget.dart';
export 'feedback/pulse_widget.dart';
export 'feedback/shake_widget.dart';
export 'feedback/tap_scale.dart';
export 'loading/animated_progress_bar.dart';
export 'loading/placeholder_colors.dart';
export 'loading/pulsing_placeholder.dart';
export 'loading/shimmer_box.dart';
export 'loading/shimmer_scope.dart';
export 'loading/skeletons.dart';
export 'lottie/app_lottie.dart';
export 'navigation/app_container_transform.dart';
export 'navigation/app_hero.dart';
export 'navigation/app_page_transitions.dart';
export 'navigation/app_route.dart';
export 'overlays/overlays.dart';
export 'scroll/app_bar_fade_on_scroll.dart';
export 'scroll/collapsing_header.dart';
export 'scroll/parallax_widget.dart';
export 'scroll/reveal_on_scroll.dart';
export 'staggered/staggered_column.dart';
export 'staggered/staggered_grid_item.dart';
export 'staggered/staggered_item.dart';
export 'staggered/staggered_list_item.dart';
export 'state/animated_counter.dart';
export 'state/animated_size_wrapper.dart';
export 'state/animated_visibility.dart';
export 'state/app_animated_switcher.dart';
export 'state/expandable_section.dart';
export 'state/idle_loop.dart';
export 'state/page_indicator.dart';
export 'state/progress_driver.dart';
export 'tokens/app_animation_constants.dart';
export 'tokens/app_curves.dart';
export 'tokens/app_durations.dart';
