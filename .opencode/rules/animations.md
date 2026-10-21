# Animations — all motion comes from `core/animations/`

`core/animations/` (barrel `animations.dart`, cheat sheet `README.md`, dev gallery
`lib/dev/animations_showcase_page.dart`) is the only source of motion in the app: tokens,
entrances, staggered lists, feedback, state transitions, loading placeholders, Lottie, overlays,
scroll effects, and page transitions. Every piece honours `disableAnimations`.

- ANIM-1  Before adding any motion, read `core/animations/README.md` and the "Animations" section of
          `docs/CORE_MAP.md`, then use what is there: the `WidgetAnimations` facade on `Widget`
          (`.fadeIn()`, `.slideIn()`, `.scaleIn()`, `.fadeSlideIn()`, `.tapScale()`,
          `.staggered()`, `.revealOnScroll()`; the README has the full list), the entrance,
          staggered, feedback, state, loading, lottie, and scroll widgets, `AppRoute.create` and
          `AppPageTransitions` for routes, `AppHero` for shared elements. Durations, curves, and
          motion numbers come only from `AppDurations`, `AppCurves`, `AppAnimationConstants`.
- ANIM-2  Outside `core/animations/` (and `lib/dev/`) these are forbidden:

  | Forbidden in features                                                              | Use instead                                              |
  |------------------------------------------------------------------------------------|----------------------------------------------------------|
  | `AnimationController`, `Tween`, `CurvedAnimation`, `AnimatedBuilder`, `TweenAnimationBuilder`, `*Transition` widgets | the facade or the entrance / feedback / state widgets |
  | `AnimatedContainer`, `AnimatedOpacity`, `AnimatedSwitcher`, `AnimatedSize`, `AnimatedCrossFade`, `AnimatedPositioned` | `AppAnimatedSwitcher`, `AnimatedSizeWrapper`, `AnimatedVisibility`, `ExpandableSection` |
  | `Hero`, `PageRouteBuilder`, `MaterialPageRoute`, `CustomTransitionPage`            | `AppHero`, `AppRoute.create`, `AppPageTransitions`, `AppContainerTransform.page` |
  | `showDialog`, `showModalBottomSheet`, `showMenu`, `ScaffoldMessenger` snackbars, `AlertDialog` | `showAppDialog` / `AppDialog` / `ConfirmDialog`, `AppBottomSheet`, `AppPopupMenu`, `AppSnackbar` |
  | `HapticFeedback`                                                                   | `AppHaptics`                                             |
  | `package:lottie`, shimmer packages, `CircularProgressIndicator`, `LinearProgressIndicator` | `AppLottie`, `ShimmerScope` + skeletons, `AnimatedProgressBar` |
  | `Curves.*`, a raw `Duration` for motion                                            | `AppCurves`, `AppDurations`                              |

- ANIM-3  No custom animation, ever. When no core animation fits, first compose the existing ones
          (they combine, e.g. `.fadeSlideIn()` then `.tapScale()`). If that still cannot do it,
          STOP and ask. Never write a one-off animation inside a feature, not even a small one.
- ANIM-4  A screen that switches between loading, content, empty, and error shows the change through
          `AppAnimatedSwitcher` with one key per state type; the exhaustive `switch` (STATE-3) builds
          its child. Loading placeholders: `ShimmerScope` skeletons for screens, `PulsingPlaceholder`
          for long lists.
- ANIM-5  Lists and grids that animate in use `StaggeredListItem`, `StaggeredGridItem`, or
          `StaggeredColumn`. Never wrap each item in its own entrance with a manual delay.
- ANIM-6  Adding a primitive or a token to `core/animations/` needs explicit approval. When approved,
          in the same task: update the barrel, the README cheat sheet,
          `lib/dev/animations_showcase_page.dart`, `docs/CORE_MAP.md`, and add tests under
          `test/core/animations/`. Additive options on an existing piece follow BASE-5.
- ANIM-7  Route transitions and shared elements: every route is created through `AppRoute.create`
          and may name a transition from `AppPageTransition`, never a custom builder. Hero tags
          are `HeroTags` constants (ARCH-10).
