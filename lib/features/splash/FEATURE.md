# Splash Feature

> Last verified: 2026-10-16

## 1 Purpose
Entry-point animation and startup orchestration. Runs a 4000ms “Orbit” animation (logo reveal, 5 module nodes orbiting and converging, tagline + keyword reveals) in parallel with async startup checks (auth token in secure storage, onboarding flag in cache). Navigates to onboarding / login / home when both animation and checks complete.

## 2 Screens & Routes
| Screen | Route | Transition |
|--------|-------|------------|
| SplashScreen | `splash` (RouteNames.splash) | `AppPageTransition.none` (native splash handles entry) |

Placeholder routes (for routing decision):
| Screen | Route | Transition |
|--------|-------|------------|
| _LoginPlaceholder | `login` (RouteNames.login) | `AppPageTransition.fadeThrough` |
| _HomePlaceholder | `home` (RouteNames.home) | `AppPageTransition.fadeThrough` |

`onboarding` resolves to the real onboarding feature screen (`fadeThrough`). The route table resolves `SplashCubit` / `OnboardingCubit` from GetIt.

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
- **SecureStorageClient**: reads `AppConsts.authTokenKey`.
- **CacheService**: reads `AppConsts.onboardingSeenKey`.

## 7 State
- **SplashLoading**: animation running, checks in progress.
- **SplashReady(viewModel)**: both done → the screen's `BlocListener` (gated by an exhaustive `listenWhen` switch) calls `goNamed(viewModel.nextRoute)`.
- **SplashError(failure)**: checks failed → the screen renders `ErrorState` with `context.failureText(failure)`; no retry, no navigation.

Navigation decision (in `SplashViewModel.nextRoute`):
| hasAuthToken | onboardingSeen | Route |
|--------------|----------------|-------|
| false        | false          | `onboarding` |
| false        | true           | `login` |
| true         | false          | `onboarding` |
| true         | true           | `home` |

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

## 11 Tests
`test/features/splash/` — 41 tests, mocktail + bloc_test, no added packages:
- **Model** `test/features/splash/data/models/startup_status_model_test.dart`: `toEntity()` field by field.
- **Usecase** `test/features/splash/domain/usecases/check_startup_status_usecase_test.dart`: repository
  success / failure passthrough.
- **Repository** `test/features/splash/data/repositories/splash_repository_impl_test.dart`: datasource
  success → entity; exception → `Failure`.
- **Cubit** `test/features/splash/presentation/cubit/splash_cubit_test.dart`: `SplashReady` (with its
  routing decision) only after BOTH the animation and the checks finish — tested with the animation
  completing after and before the checks (completer-driven) — and `[Loading, Error(failure)]` when
  the checks fail, still never ready.
- **Mapper** `test/features/splash/presentation/mappers/splash_mapper_test.dart`: `toViewModel` fields
  + all 4 routing outcomes of §7.
- **Widget** `test/features/splash/presentation/screens/splash_screen_test.dart` (7 tests): pumps the
  real `AppRouterRoutes` table with a real cubit (registered in GetIt, as the app does) over a mocked
  usecase — composition visible when animations enabled, no navigation before the 4000ms animation
  ends, `goNamed` lands on login/home per startup status, localized error view on check failure
  (dispose cancels controller work), reduced-motion static frame, reduced-motion navigation after the
  500ms hold (dispose cancels the hold timer).
- **Layout** `test/features/splash/presentation/widgets/splash_layout_test.dart` (20 tests: 4 screen
  sizes × 5 assertions, controllable clock): logo center X == screen center X at 0/1000/2000/3000/
  3600/4000ms; logo/tagline/keywords non-overlapping and inside the safe area at the hold frame;
  final frame's layout position+size identical to the hold frame; painted stage elements inside the
  screen minus page padding; no content render object at the top-left corner at the final frame.

## 12 Known Issues
- (none) — the former `translate` deprecation note no longer applies: `orbit_rings_painter.dart`
  rotates via `translateByDouble`/`rotateZ` on a `Matrix4`.

## 13 Changelog
- 2026-10-16: Synced FEATURE.md with code — constants listed under `presentation/constants/`; storage keys referenced by constant name (`AppConsts.authTokenKey`, `AppConsts.onboardingSeenKey`) per ARCH-10.
- 2026-10-16: Hardening pass after review. States are consumed via exhaustive switches (`listenWhen` +
  listener + builder); `SplashError` now carries the `Failure` and the screen renders `ErrorState`
  with `context.failureText`; the reduced-motion hold is a stored `Timer` cancelled on dispose; DI
  moved from the feature to `lib/core/di/splash_injection.dart`; the onboarding placeholder route was
  removed (the real onboarding screen is registered). Composition fix: per-frame rebuilds are scoped
  to the animating leaves, with the tagline/keyword `AnimatedBuilder`s restored after the scoping
  left them static at opacity 0 (caught by the layout tests). Tests: cubit gating in both orders,
  failure passthrough, widget error view, reduced-motion timer cancel.
- 2026-10-16: Fixed splash layout/positioning/sizing. Root causes: a loose-constraint root Stack
  (shrink-wrapped and pinned top-start), raw-pixel ring/node/lock-in geometry, and exit-phase
  per-element transforms + layer unmount re-shrinking the tree (collapse to top-left at 4000ms).
  Restructured to one layout root (`SafeArea` → `Center` → min-size `Column`: stage → gap → tagline →
  gap → keywords) with all sizes as named ratios in `splash_layout_constants.dart`; painters compute
  from the `paint()` `Size` with clamped progress; the stage center is measured post-frame so the
  full-screen background glow centers on the stage; tagline/keywords always reserve their final size
  (only transform/opacity animate); the exit scale+fade is applied once to the whole content via a
  single `Transform.scale(alignment: center)` + `Opacity`. Timeline, curves, colors, and slang keys
  are unchanged. Added 20 layout widget tests (4 screen sizes × 5 assertions) — FEATURE.md §11.
  (Also: regenerated slang output and added its missing import in `core/router` so the app compiles,
  and adapted `splash_screen_test` to the new route table which resolves `SplashCubit` from GetIt.)
- 2026-10-15: Initial implementation — animation timeline, orbit rings, module nodes, logo reveal, tagline/keyword reveals, convergence, exit transition, parallel startup checks, routing decision, DI, routes, i18n, tests.
- 2026-10-15: Changed routing from path-based (`context.go()`) to named routes (`context.goNamed()`). Updated `SplashMapper` to use `RouteNames` and `SplashScreen` to call `context.goNamed()`.
- 2026-10-15: Added the full 20-test suite. The widget tests caught two bugs, fixed here: `AppRouterRoutes` entries lacked `name:` (so `goNamed` threw "unknown route name"), and `ConvergenceWidget._pulseProgress` overflowed the curve's [0,1] range at `progress == 1.0`.