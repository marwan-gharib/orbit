# Core Map

Read this before writing any code, in every layer (BASE-1), and before writing anything reusable (ARCH-4, UI-2). Keep it short: name, path, one-line use.
Update it whenever `core/` gains, loses, or changes a reusable piece (DOC-6).

## Constants (ARCH-10: the ONLY place string keys, paths, routes, assets live)
- `ApiKeys` — core/constants/api_keys.dart — JSON / request / header field names.
- `Endpoints` — core/constants/endpoints.dart — API paths.
- `Assets` — core/constants/assets.dart — asset paths (`OnboardingSvgs` holds the layered onboarding illustration SVGs).
- `AppLottieAssets` — core/constants/app_lottie_assets.dart — Lottie file paths (`assets/animations/`), consumed by `AppLottie`.
- `AppConsts` — core/constants/app_consts.dart — other shared constants (storage keys, env names, durations...).
- `HeroTags` — core/constants/hero_tags.dart — the prefix that namespaces every `AppHero` flight tag.
- `LogTags` — core/constants/log_tags.dart — `AppLogger` tags (`auth`), so a tag is never a literal at the call site.

## Network
- `BaseApiClient` — core/network/… — abstract HTTP client; its implementation and interceptors are the only `dio` importers. GET accepts a request body (`data`) for GET-with-body APIs; every verb takes typed `extra` (interceptor opt-outs).
- `DioApiClient.buildDio` — core/network/dio_api_client.dart (@visibleForTesting) — the single static stack builder (JSON defaults, `X-Client-Type: Flutter` header, interceptor chain, timeouts).
- Interceptors — core/network/interceptors/… — auth token (reads `AppConsts.accessTokenKey`, `requiresAuthExtra` opt-out — flag and header names in `ApiKeys`), logging (masks token values before logging), error mapping, locale.

## Errors
- `Failure` hierarchy — core/errors/failures.dart — list subtypes here (`InvalidCredentialsFailure` for a sign-in 401 vs. `UnauthorizedFailure` for other 401s).
- Dio error classifier — core/errors/error_mapper.dart — maps exceptions to `Failure`.
- `ErrorBodyParser` — core/errors/error_body_parser.dart — the one place an error body becomes (serverMessage, fieldErrors, errorCode); the Dio classifier delegates here; tested in `test/core/errors/error_body_parser_test.dart`.
- `NetworkExceptionFactory` — core/errors/network_exception_factory.dart — builds `NetworkException`s (the only place the request-timeout 408 status is set) and resolves `NetworkErrorReason` from a wrapped cause chain; extracted from the Dio classifier, tested in `test/core/errors/network_exception_factory_test.dart`.

## Config
- `AppEnv` — core/config/app_env.dart — typed `.env` accessor (`BASE_URL`), loaded once in `main()` before DI; fail-fast when missing/empty; `debugSeed` is the test seam. `flutter_dotenv` is imported only here. `.env` is gitignored but bundled as an asset, so every build host must create it from `.env.example` first (a missing file fails the asset step); tests never need it.

## Utils
- `ApiResult<T>` (with `fold`) — core/utils/api_result.dart
- `PagedResult<T>` — core/utils/paged_result.dart
- `Logger` — core/utils/logger.dart
- `Validators` — core/utils/validators.dart

## Local storage
- Secure storage abstraction — core/local/secure/secure_storage_client.dart (+ impl)
- Cache abstraction — core/local/cache/cache_service.dart (+ shared_preferences impl)

## Shared widgets
- `AppButton` (variants: filled/elevated/outlined/text, loading, icon, destructive) — core/widgets/app_button.dart
- `AppTextField` (label/hint/helper/prefix/suffix, validator, obscure toggle) — core/widgets/app_text_field.dart
- `AppCard` (tappable, custom padding) — core/widgets/app_card.dart
- `StatusBadge` (success/warning/error/info/neutral, custom icon) — core/widgets/status_badge.dart
- `EmptyState` (title/message/icon, primary action button) — core/widgets/empty_state.dart
- `ErrorState` (title/message/icon, retry action button) — core/widgets/error_state.dart
- `AppDialog` (styled AlertDialog using theme tokens) — core/widgets/app_dialog.dart
- `ConfirmDialog` (confirmation dialog using AppDialog + showAppDialog) — core/widgets/confirm_dialog.dart
- Barrel: `core/widgets/widgets.dart`

## Animations (`core/animations/`, barrel `animations.dart`, cheat sheet `core/animations/README.md`, dev gallery `lib/dev/animations_showcase_page.dart`)
- Tokens — `AppDurations`, `AppCurves`, `AppAnimationConstants` — core/animations/tokens/… (the only place durations, curves, motion numbers live).
- Engine — `Entrance` — core/animations/entrance/entrance.dart — plays once on first build, Interval-based delay (no timers), honours `disableAnimations`.
- Entrances — `FadeIn`, `SlideIn`, `ScaleIn`, `FadeSlideIn`, `BlurIn` — core/animations/entrance/… (RTL-aware, generic over `child`).
- Progress-driven entrance layers (no controller; the caller supplies a progress window) — `AssemblyLayer`, `ClipReveal` — core/animations/entrance/… (used by the onboarding slide artwork assembly).
- Facade — `WidgetAnimations` (extension on `Widget`: `.fadeIn()`, `.slideIn()`, `.scaleIn()`, `.fadeSlideIn(delay:)`, `.blurIn()`, `.tapScale(onTap:)`, `.shake(controller)`, `.pulse()`, `.bounce(controller)`, `.staggered(index:)`, `.revealOnScroll()`) — core/animations/extensions/animate_extension.dart — thin pass-through to the widget of the same name; defaults stay on the widgets.
- Staggered — `StaggeredItem` (engine), `StaggeredListItem`, `StaggeredGridItem`, `StaggeredColumn` — core/animations/staggered/… — `index × stagger` delay, past-cap items render immediately; keep-alive so entrances never replay on scroll-back (bounded by `maxStaggerIndex`, not list length).
- Feedback — `TapScale`, `ShakeWidget`/`ShakeController`, `PulseWidget`, `BounceWidget`/`BounceController` — core/animations/feedback/… (press scale, error shake, breathing loop, one-shot pop; Shake/Bounce fire from a Cubit `trigger` counter or a controller, and every motion honours `disableAnimations`).
- Haptics — `AppHaptics` (+ `HapticType`) — core/animations/feedback/app_haptics.dart — the only caller of `HapticFeedback`; global `enabled` switch.
- State transitions — `AppAnimatedSwitcher`, `AnimatedSizeWrapper`, `AnimatedCounter`, `ExpandableSection`, `AnimatedVisibility` — core/animations/state/… — cross-fade between loading/content/error/empty (one key per state type), animated size, tabular-figure number counts, accordions and show/hide; hidden subtrees unmount unless `maintainState`, all honour `disableAnimations`.
- Idle / progress drivers — `IdleLoop` (breathing / float / travel loops that hold the settled frame when off), `PageIndicator` (morphing dots→pill, tappable), `ProgressDriver` (replay/toggle 0..1 timeline for slide entrances) — core/animations/state/… — all honour `disableAnimations`.
- Loading — `ShimmerScope` (one sweep controller + one ShaderMask per skeleton screen), `ShimmerBox` (rectangle/circle/text-line), `SkeletonListTile`/`SkeletonCard`/`SkeletonTextBlock`, `PulsingPlaceholder` (cheap opacity pulse for long lists), `AnimatedProgressBar` (determinate + indeterminate, RTL-aware) — core/animations/loading/… (theme-derived placeholder colors via `PlaceholderColors`; `disableAnimations` renders static placeholder colors; shimmer vs pulse guidance in the doc comments).
- Lottie — `AppLottie` (success/error/empty/loading named constructors + generic `.asset()`) — core/animations/lottie/… — the only `package:lottie` importer (features never import the package); composition-driven playback, `disableAnimations` freezes on the final frame (loading rests on the first) and still delivers `onCompleted` once, fallback icon/widget on a failed load, optional RTL mirroring; parent rebuilds never restart playback.
- Overlays — `showAppDialog` (focus-pull entrance with blurred barrier, in `app_dialog_route.dart`), `AppBottomSheet`, `AppSnackbar` (+ `AppSnackbarType`/`AppSnackbarResult`), `AppPopupMenu`, `AppOverlayMotion` — core/animations/overlays/ — token-driven modal motion (blurred dialog barrier, drag-handled sheet, replace-don't-queue snackbar, anchor-positioned menu); every entry point reads `disableAnimations` through `AppOverlayMotion`. Barrel: `core/animations/overlays/overlays.dart`.
- Scroll-based — `RevealOnScroll` (one-shot viewport reveal, listener detaches after firing), `ParallaxWidget` (scroll-position-driven background, RTL-aware, no user controller needed), `CollapsingHeader` (SliverAppBar + FlexibleSpaceBar large title with a fading/zooming background slot), `AppBarFadeOnScroll` + `FadeOnScrollBar` (scroll-offset-driven bar background/elevation; controller or notification fed) — core/animations/scroll/… (geometry via the nearest viewport's render object; scroll-linked mappings are instantaneous, `disableAnimations` pins reveal/parallax/bar to their final state).
- Navigation — `AppPageTransitions` + `AppPageTransition` (fadeThrough, shared axis H/V, slide, scale, containerTransform, none), `AppRoute.create` (applies the app-wide default when a route names no transition), `AppHero`/`AppHeroTag` (card flights with the namespaced tag and the cross-fading shuttle), `AppContainerTransform.page` (card → details) — core/animations/navigation/… (`CustomTransitionPage` builders on token durations/curves, both routes animate, RTL- and `disableAnimations`-aware, iOS back-swipe via `_BackSwipeHost`).

## Extensions / helpers
- `BuildContext` extensions — core/extensions/context_extensions.dart (colors, textStyles, strings, responsive, navigation)
- `context.failureText(Failure)` — core/extensions/context_extensions.dart — the single Failure → localized screen copy (ERR-4; mirrors `ErrorMapper` wait phrasing); tested in `test/core/extensions/context_extensions_test.dart`

## Responsive
- `Responsive` facade — core/responsive/responsive.dart — width/height/radius/font/adapt scaling, binds engine via `ResponsiveScope`
- Scalers — `ResponsiveScaler`, `ScreenUtilScaler`, `IdentityResponsiveScaler` — core/responsive/…

## Theme / router / DI
- `AppTheme.light/dark` — core/theme/app_theme.dart (Material 3; registers `AppColorsExtension` + `AppTextStylesExtension`, full component themes, per-mode system overlay style; every font size, spacing and radius goes through `Responsive`, so `ResponsiveScope` must wrap `MaterialApp` — see main.dart)
- `context.colors` / `context.textStyles` — core/theme/extensions/…; raw palette `AppColors`, type scale `AppTextStyles`, `AppSpacing`, `AppRadius` — core/theme/…; font-family switch `Fonts.family` — core/constants/fonts.dart (placeholder, pubspec registers no font yet)
- go_router configuration — core/router/… (route table in `app_router_routes.dart`, route names in `route_names.dart`, paths in `route_paths.dart`, auth guard `RouteGuards.authRedirect` in `route_guards.dart`, in-memory pending flow in `pending_signup_session.dart`)
- Injection container — core/di/injection_container.dart (`initCoreModule` + one module file per feature: `splash_injection.dart`, `onboarding_injection.dart`, `auth_injection.dart`; the pattern is described in `feature_module_registry.md`)

## i18n
- slang generated strings — core/i18n/strings.g.dart, strings_en.g.dart (keys in assets/i18n/…; run `dart run slang` to regenerate)

<!-- Fill the paths. Run a one-off session: "scan core/ and fill docs/CORE_MAP.md" (docs only). -->