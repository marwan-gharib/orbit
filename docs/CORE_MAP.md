# Core Map

Check this before writing anything reusable (ARCH-4, UI-2). Keep it short: name, path, one-line use.
Update it whenever `core/` gains, loses, or changes a reusable piece (DOC-6).

## Constants (ARCH-10: the ONLY place string keys, paths, routes, assets live)
- `ApiKeys` — core/constants/api_keys.dart — JSON / request / header field names.
- `Endpoints` — core/constants/endpoints.dart — API paths.
- `AppRoutes` — core/constants/app_routes.dart — route names and paths.
- `Assets` — core/constants/assets.dart — asset paths.
- `AppLottieAssets` — core/constants/app_lottie_assets.dart — Lottie file paths (`assets/animations/`), consumed by `AppLottie`.
- `AppConsts` — core/constants/app_consts.dart — other shared constants (storage keys, env names, durations...).
- `HeroTags` — core/constants/hero_tags.dart — the prefix that namespaces every `AppHero` flight tag.

## Network
- `BaseApiClient` — core/network/… — abstract HTTP client; its implementation and interceptors are the only `dio` importers.
- Interceptors — core/network/… — auth token, logging, error mapping.

## Errors
- `Failure` hierarchy — core/errors/… — list subtypes here.
- Dio error classifier — core/errors/… — maps exceptions to `Failure`.

## Utils
- `ApiResult<T>` (with `fold`) — core/utils/…
- `PagedResult<T>` — core/utils/…

## Local storage
- Secure storage abstraction — core/local/secure/…
- Cache abstraction — core/local/cache/…

## Shared widgets
- `AppButton`, `AppTextField`, `AppLoader`, `AppSnackBar` — core/widgets/…

## Animations (`core/animations/`, barrel `animations.dart`)
- Tokens — `AppDurations`, `AppCurves`, `AppAnimationConstants` — core/animations/tokens/… (the only place durations, curves, motion numbers live).
- Engine — `Entrance` — core/animations/entrance/entrance.dart — plays once on first build, Interval-based delay (no timers), honours `disableAnimations`.
- Entrances — `FadeIn`, `SlideIn`, `ScaleIn`, `FadeSlideIn`, `BlurIn` — core/animations/entrance/… (RTL-aware, generic over `child`).
- Staggered — `StaggeredItem` (engine), `StaggeredListItem`, `StaggeredGridItem`, `StaggeredColumn` — core/animations/staggered/… — `index × stagger` delay, past-cap items render immediately; keep-alive so entrances never replay on scroll-back (bounded by `maxStaggerIndex`, not list length).
- Feedback — `TapScale`, `ShakeWidget`/`ShakeController`, `PulseWidget`, `BounceWidget`/`BounceController` — core/animations/feedback/… (press scale, error shake, breathing loop, one-shot pop; Shake/Bounce fire from a Cubit `trigger` counter or a controller, and every motion honours `disableAnimations`).
- Haptics — `AppHaptics` (+ `HapticType`) — core/animations/feedback/app_haptics.dart — the only caller of `HapticFeedback`; global `enabled` switch.
- State transitions — `AppAnimatedSwitcher`, `AnimatedSizeWrapper`, `AnimatedCounter`, `ExpandableSection`, `AnimatedVisibility` — core/animations/state/… — cross-fade between loading/content/error/empty (one key per state type), animated size, tabular-figure number counts, accordions and show/hide; hidden subtrees unmount unless `maintainState`, all honour `disableAnimations`.
- Loading — `ShimmerScope` (one sweep controller + one ShaderMask per skeleton screen), `ShimmerBox` (rectangle/circle/text-line), `SkeletonListTile`/`SkeletonCard`/`SkeletonTextBlock`, `PulsingPlaceholder` (cheap opacity pulse for long lists), `AnimatedProgressBar` (determinate + indeterminate, RTL-aware) — core/animations/loading/… (theme-derived placeholder colors via `PlaceholderColors`; `disableAnimations` renders static placeholder colors; shimmer vs pulse guidance in the doc comments).
- Lottie — `AppLottie` (success/error/empty/loading named constructors + generic `.asset()`) — core/animations/lottie/… — the only `package:lottie` importer (features never import the package); composition-driven playback, `disableAnimations` freezes on the final frame (loading rests on the first) and still delivers `onCompleted` once, fallback icon/widget on a failed load, optional RTL mirroring; parent rebuilds never restart playback.
- Overlays — `AppDialog`, `AppBottomSheet`, `AppSnackbar` (+ `AppSnackbarType`/`AppSnackbarResult`), `AppPopupMenu`, `AppOverlayMotion` — core/animations/overlays/ — token-driven modal motion (blurred dialog barrier, drag-handled sheet, replace-don't-queue snackbar, anchor-positioned menu); every entry point reads `disableAnimations` through `AppOverlayMotion`.
- Scroll-based — `RevealOnScroll` (one-shot viewport reveal, listener detaches after firing), `ParallaxWidget` (scroll-position-driven background, RTL-aware, no user controller needed), `CollapsingHeader` (SliverAppBar + FlexibleSpaceBar large title with a fading/zooming background slot), `AppBarFadeOnScroll` + `FadeOnScrollBar` (scroll-offset-driven bar background/elevation; controller or notification fed) — core/animations/scroll/… (geometry via the nearest viewport's render object; scroll-linked mappings are instantaneous, `disableAnimations` pins reveal/parallax/bar to their final state).
- Navigation — `AppPageTransitions` + `AppPageTransition` (fadeThrough, shared axis H/V, slide, scale, containerTransform, none), `AppRoute.create` (applies the app-wide default when a route names no transition), `AppHero`/`AppHeroTag` (card flights with the namespaced tag and the cross-fading shuttle), `AppContainerTransform.page` (card → details) — core/animations/navigation/… (`CustomTransitionPage` builders on token durations/curves, both routes animate, RTL- and `disableAnimations`-aware, iOS back-swipe via `_BackSwipeHost`).

## Extensions / helpers
- `BuildContext` extensions — core/extensions/…
- Failure → localized message — core/extensions/…

## Theme / router / DI
- `AppTheme.light/dark` — core/theme/… (Material 3; registers `AppColorsExtension` + `AppTextStylesExtension`, full component themes, per-mode system overlay style; every font size, spacing and radius goes through `Responsive`, so `ResponsiveScope` must wrap `MaterialApp` — see main.dart)
- `context.colors` / `context.textStyles` — core/theme/extensions/…; raw palette `AppColors`, type scale `AppTextStyles`, `AppSpacing`, `AppRadius` — core/theme/…; font-family switch `Fonts.family` — core/constants/fonts.dart (placeholder, pubspec registers no font yet)
- go_router configuration — core/router/…
- Injection container — core/di/… (read `lib/core/di/feature_module_registry.md` first, DI-1)

<!-- Fill the paths. Run a one-off session: "scan core/ and fill docs/CORE_MAP.md" (docs only). -->
