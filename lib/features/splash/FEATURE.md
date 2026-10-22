# Splash Feature

> Last verified: 2026-10-22

## 1 Purpose
Entry-point animation and startup orchestration. Runs a 4000ms “Orbit” animation (logo reveal, 5 module nodes orbiting and converging, tagline + keyword reveals) in parallel with async startup checks (auth token in secure storage, onboarding flag and pending-signup email in cache). Navigates to onboarding / login / pending / home when both animation and checks complete.

## 2 Screens & Routes
| Screen | Route | Transition |
|--------|-------|------------|
| SplashScreen | `splash` (RouteNames.splash) | `AppPageTransition.none` (native splash handles entry) |

Placeholder routes used by the startup decision: `home` (`RouteNames.home`) → `_HomePlaceholder`.
`login` (`RouteNames.login`), `signup` (`RouteNames.signup`) and `pending`
(`RouteNames.pending`) resolve to the real auth screens; `onboarding` resolves to the
real onboarding feature screen. All transitions are `AppPageTransition.fadeThrough`;
the route table resolves the Cubits from GetIt.

## 3 File Map
```
lib/features/splash/
├── domain/
│   ├── entities/
│   │   └── splash_state_entity.dart             # hasAuthToken, onboardingSeen
│   ├── repositories/
│   │   └── splash_repository.dart               # Contract: checkStartupStatus()
│   └── usecases/
│       └── check_startup_status_usecase.dart    # No params
├── data/
│   ├── models/
│   │   └── startup_status_model.dart            # fromJson/toEntity()
│   ├── datasources/
│   │   └── local/
│   │       └── splash_local_data_source.dart    # CacheService + SecureStorageClient
│   └── repositories/
│       └── splash_repository_impl.dart
├── presentation/
│   ├── constants/
│   │   ├── splash_animation_constants.dart      # 4000ms timeline tokens
│   │   └── splash_layout_constants.dart         # Named layout ratios (SplashLayoutRatios + SplashLayout)
│   ├── cubit/
│   │   ├── splash_cubit.dart                    # Parallel init + animation
│   │   └── splash_state.dart                    # Loading / Ready / Error
│   ├── view_models/
│   │   └── splash_view_model.dart               # nextRoute, flags
│   ├── mappers/
│   │   └── splash_mapper.dart                   # Entity → ViewModel
│   ├── screens/
│   │   └── splash_screen.dart                   # Controller, cubit stream listener
│   └── widgets/
│       ├── splash_composition.dart              # Orchestrates the timeline: stage → tagline → keywords; per-frame rebuilds scoped to the animating leaves
│       ├── orbit_rings_painter.dart             # 2 proportional elliptical rings (path trim)
│       ├── module_nodes_painter.dart            # 5 nodes + comet trails, fraction positions × stage side
│       ├── logo_reveal_widget.dart              # Scale+overshoot, blur, rotation, shockwave
│       ├── tagline_reveal_widget.dart           # Word-by-word masked slide-up (centered Wrap)
│       ├── module_keywords_widget.dart          # Sequential fade+rise (centered Wrap, separator dots)
│       ├── convergence_widget.dart              # Spiral-in + micro-pulse
│       └── exit_transition_widget.dart          # Scale-up + fade (whole content, alignment: center)
└── FEATURE.md
```
DI registration lives in `lib/core/di/splash_injection.dart` (feature modules register from `core/di/`).

## 4 Entities & Models
- **SplashStateEntity** (domain): `hasAuthToken: bool`, `onboardingSeen: bool`, computed `nextRoute`
- **StartupStatusModel** (data): mirrors entity, `toEntity()`

## 5 Use Cases
- **CheckStartupStatusUseCase**: `Future<ApiResult<SplashStateEntity>> call()` — reads auth token (secure storage) and onboarding flag (cache) in parallel.

## 6 API & Storage
- No network calls.
- **SecureStorageClient**: reads `AppConsts.accessTokenKey` — the same key the auth feature writes, so startup reflects the real session.
- **CacheService**: reads `AppConsts.onboardingSeenKey` and `AppConsts.pendingSignupEmailKey`.

## 7 State
- **SplashLoading**: animation running, checks in progress.
- **SplashReady(viewModel)**: both done → the screen's `BlocListener` (gated by an exhaustive `listenWhen` switch) calls `goNamed(viewModel.nextRoute)`.
- **SplashError(failure)**: checks failed → the screen renders `ErrorState` with `context.failureText(failure)`; no retry, no navigation.

Navigation decision (in `SplashViewModel.nextRoute`; precedence: real session → pending signup → onboarding → login):
| hasAuthToken | hasPendingSignup | onboardingSeen | Route |
|--------------|------------------|----------------|-------|
| true         | any              | false          | `onboarding` |
| true         | any              | true           | `home` |
| false        | true             | any            | `pending` |
| false        | false            | false          | `onboarding` |
| false        | false            | true           | `login` |

## 8 Dependencies
- **Core**: `CacheService`, `SecureStorageClient`, `Responsive`, `AppColorsExtension`/`AppTextStylesExtension`, `ErrorState`, `context.failureText`, `RouteNames`, `ApiResult`/`Failure`, `go_router`, `flutter_bloc`, `equatable`.
- **Assets**: `Assets.splashLogo` → `assets/images/orbit_logo_whiting_backround.png`.

## 9 Localization
Namespace: `splash`
Keys (in `assets/i18n/en.i18n.json`):
- `splash.tagline`: "Every project. Every team. One orbit."
- `splash.taglineWords`: ["Every", "project.", "Every", "team.", "One", "orbit."]
- `splash.modules.projects`: "Projects"
- `splash.modules.people`: "People"
- `splash.modules.finance`: "Finance"
- `splash.modules.clients`: "Clients"
- `splash.modules.insights`: "Insights"
- `splash.accessibilityLabel`: "Orbit startup screen. Five modules orbit the logo and converge into one unified system. Every project. Every team. One orbit."

RTL-safe: copy reveals animate only opacity/transform inside centered `Wrap`s (no directional offsets).

## 10 Business Rules
- Total splash duration: exactly 4000ms, driven by single `AnimationController`.
- Animation runs in parallel with startup checks.
- If checks finish early → hold final frame (subtle pulse) until 4000ms.
- If checks take longer → keep final frame visible, no spinner.
- If checks fail → localized `ErrorState` text (`context.failureText`); the animation keeps running but never navigates.
- Reduced motion (`MediaQuery.disableAnimations`): show static final frame, navigate after a 500ms hold (stored timer, cancelled on dispose).
- Native splash (`flutter_native_splash.yaml`) uses hardcoded light background `#F7F8F9` (mirrors `AppColors.neutralNormal`).
- A persisted pending signup outranks onboarding/login when there is no session; a real
  session outranks a pending signup.

## 11 Tests
`test/features/splash/` — 44 tests (29 bodies; the layout suite runs 5 bodies × 4 screen sizes),
mocktail + bloc_test, no added packages:
- **Datasource** `data/datasources/local/splash_local_data_source_test.dart`: reads exactly
  `AppConsts.accessTokenKey` (pin), the onboarding key and `AppConsts.pendingSignupEmailKey`; failure path.
- **Model** `data/models/startup_status_model_test.dart`: `toEntity()` field by field.
- **Usecase** `domain/usecases/check_startup_status_usecase_test.dart`: success / failure passthrough.
- **Repository** `data/repositories/splash_repository_impl_test.dart`: datasource success → entity;
  exception → `Failure`.
- **Cubit** `presentation/cubit/splash_cubit_test.dart`: `SplashReady` only after BOTH the animation
  and the checks finish (completer-driven, both orders), `[Loading, Error(failure)]` on check failure.
- **Mapper** `presentation/mappers/splash_mapper_test.dart`: `toViewModel` fields + every
  routing outcome of §7, including pending precedence over login/onboarding and a real
  session winning over a pending signup.
- **Widget** `presentation/screens/splash_screen_test.dart` (7): real `AppRouterRoutes` table with a
  real cubit (registered in GetIt, as the app does) over a mocked usecase — composition visible,
  no navigation before 4000ms, `goNamed` lands on login/home per status, localized error view,
  reduced-motion static frame and 500ms-hold navigation (both cancelled on dispose).
- **Layout** `presentation/widgets/splash_layout_test.dart` (5 bodies × 4 screen sizes, controllable
  clock): logo center X == screen center X across the timeline; logo/tagline/keywords non-overlapping
  and inside the safe area at the hold frame; final frame's position+size identical to the hold
  frame; painted stage elements inside the screen minus page padding.

## 12 Known Issues
- (none) — the former `translate` deprecation note no longer applies: `orbit_rings_painter.dart`
  rotates via `translateByDouble`/`rotateZ` on a `Matrix4`.

## 13 Changelog
- 2026-10-22: Pending-aware startup — the checks now also read the pending-signup email; an unapproved account routes to the real `/pending` screen (session still wins), and the auth routes resolve to the real screens.
- 2026-10-22: Token-key unification — startup checks read `AppConsts.accessTokenKey` (shared with the auth feature); `test/data/datasources/local` gained a datasource test pinning the key.
- 2026-10-16: Synced with code — constants under `presentation/constants/`; storage keys referenced by constant name (ARCH-10).
- 2026-10-16: Hardening after review — exhaustive state switches (`listenWhen` + listener + builder), `SplashError` carries the `Failure` (`ErrorState` + `context.failureText`), stored reduced-motion timer cancelled on dispose, DI moved to `lib/core/di/splash_injection.dart`, onboarding placeholder route removed, per-frame rebuild scoping restored; tests for cubit gating in both orders, failure passthrough, error view, timer cancel.
- 2026-10-16: Fixed layout/positioning/sizing — one layout root with named ratios in `splash_layout_constants.dart`, painters compute from `paint()` size, post-frame stage measurement, reserved final size for tagline/keywords, single whole-content exit scale+fade; 20 layout tests added. (Also regenerated slang output and adapted `splash_screen_test` to the GetIt-resolved route table.)
- 2026-10-15: Initial implementation — animation timeline, orbit rings, module nodes, logo/tagline/keyword reveals, convergence, exit transition, parallel startup checks, routing decision, DI, routes, i18n, tests.
- 2026-10-15: Routing switched from path-based (`context.go()`) to named routes (`context.goNamed()` + `RouteNames`).
- 2026-10-15: Full 20-test suite added; it caught two bugs — `AppRouterRoutes` entries lacked `name:` (so `goNamed` threw), and `ConvergenceWidget._pulseProgress` overflowed the curve's [0,1] range at `progress == 1.0`.