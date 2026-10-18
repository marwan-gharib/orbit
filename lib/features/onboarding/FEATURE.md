# Onboarding

> Last verified: 2026-10-17
> Path: `lib/features/onboarding/`

## 1. Purpose

First-run experience that introduces Orbit's four core modules (Projects, People, Finance & Clients, Insights) through 4 animated slides. Completes by persisting an `onboarding_seen` flag so returning users skip directly to login.

## 2. Screens & routes

| Screen | Route (constant) | Params | Notes |
|--------|------------------|--------|-------|
| OnboardingScreen | `RoutePaths.onboarding` (`/onboarding`, name `RouteNames.onboarding`) | None | Entry point from splash when `onboardingSeen == false`; route builder triggers `loadPages()` |

## 3. File map

| Layer | Key files (feature-relative unless a full path) | Responsibility |
|-------|--------------------------------------|----------------|
| routing | `lib/core/router/app_router_routes.dart` | GoRouter registration for `/onboarding` (fadeThrough) |
| di | `lib/core/di/onboarding_injection.dart` | get_it wiring: datasource → repository → usecases → cubit |
| presentation | `presentation/screens/onboarding_screen.dart` | Root scaffold, single layout root (top bar / page area / indicator / controls bands), PopScope, stream listener navigates on completion |
| presentation | `presentation/constants/onboarding_layout_constants.dart` | Single source of truth: page layout ratios, illustration square bound, widget keys, derived `OnboardingLayout` sizes |
| presentation | `presentation/constants/onboarding_illustration_constants.dart` | Single source of truth for the illustrations: layer keys, per-layer entrance/idle intervals+pivots, text-slot rects |
| presentation | `presentation/constants/onboarding_svg_palette.dart` | The 16 SVG placeholder hex values (feature-local; not a core constant) |
| presentation | `presentation/widgets/onboarding_page_view.dart` | PageView with parallax-driven progress |
| presentation | `presentation/widgets/onboarding_page.dart` | Single page layout + entrance choreography |
| presentation | `presentation/widgets/onboarding_skip_button.dart` | Animated skip (fades out on last slide) |
| presentation | `presentation/widgets/onboarding_nav_buttons.dart` | Back/Next + GetStarted morph |
| presentation | `presentation/widgets/illustrations/onboarding_illustration_factory.dart` | Creates correct illustration per page type |
| presentation | `presentation/widgets/illustrations/layered_illustration.dart` | Shared stage: stacked full-square SVG layers, theme color mapper, single RTL flip of the artwork stack, per-layer entrance/idle pipeline, unflipped text slots |
| presentation | `presentation/widgets/illustrations/illustration_motion.dart` | Sealed entrance/idle motion catalogue (fade, scale, translate, scaleY, rotate, crossfade, clip/sweep reveal, travel; breathe, pulse, float, travel-loop idles) |
| presentation | `presentation/widgets/illustrations/onboarding_svg_color_mapper.dart` | Resolves the 16 placeholder hex values baked into the SVGs to the active theme's tokens (value-equal flutter_svg cache key) |
| presentation | `presentation/widgets/illustrations/slide1_projects_illustration.dart` | Kanban board, moving card, health ring + count-up `75%` text slot |
| presentation | `presentation/widgets/illustrations/slide2_people_illustration.dart` | Check-in button, radar pulse rings, leave card, pending→approved crossfade + approval stamp |
| presentation | `presentation/widgets/illustrations/slide3_finance_illustration.dart` | Deal → project flow (bezier dot), trend badge + `EGP 128K` text slot |
| presentation | `presentation/widgets/illustrations/slide4_insights_illustration.dart` | Dashboard frame, growing bars, line reveal, pulsing alert badge, legend |
| presentation | `presentation/widgets/illustrations/onboarding_illustration.dart` | Legacy abstract illustration base class, unused since the SVG rework (§12) |
| presentation | `presentation/widgets/background/onboarding_background.dart` | 3 interpolating gradient blobs |
| presentation | `presentation/cubit/onboarding_cubit.dart` | Page state + completion trigger; pure Dart — the screen owns the `PageController`, haptics and announcements (STATE-7) |
| presentation | `presentation/cubit/onboarding_state.dart` | Sealed states: Loading, Success(pages, currentIndex, isLastPage), Error(failure), Completed |
| presentation | `presentation/cubit/onboarding_constants.dart` | Animation timing constants |
| presentation | `presentation/view_models/onboarding_page_view_model.dart` | UI-ready page data (re-exports illustration type enum) |
| presentation | `presentation/mappers/onboarding_page_mapper.dart` | Maps `OnboardingPage` entity → view model (slang headline/body) |
| domain | `domain/entities/onboarding_page.dart` | Page entity + `OnboardingIllustrationType` enum |
| domain | `domain/repositories/onboarding_repository.dart` | Contract: getPages(), completeOnboarding() |
| domain | `domain/usecases/get_onboarding_pages_usecase.dart` | Returns static page list |
| domain | `domain/usecases/complete_onboarding_usecase.dart` | Persists onboarding_seen flag |
| data | `data/models/onboarding_page_model.dart` | Model with toEntity() |
| data | `data/datasources/local/onboarding_local_data_source.dart` | CacheService read/write for onboarding_seen |
| data | `data/repositories/onboarding_repository_impl.dart` | Implements contract, holds static page data |

## 4. Entities & models

| Entity | Key fields | Model | Notes |
|--------|------------|-------|-------|
| `OnboardingPage` | `id`, `headlineKey`, `bodyKey`, `illustrationType` | `OnboardingPageModel` | Pure Dart, no Flutter deps |

## 5. Use cases

| UseCase | Input | Output | Business rule |
|---------|-------|--------|---------------|
| `GetOnboardingPagesUseCase` | None | `ApiResult<List<OnboardingPage>>` | Returns 4 static pages |
| `CompleteOnboardingUseCase` | None | `ApiResult<void>` | Writes `onboarding_seen = true` via CacheService |

## 6. API & storage

| Key (constant) | Type | Used by | Cache policy |
|----------------|------|---------|--------------|
| `AppConsts.onboardingSeenKey` (`'onboarding_seen'`) | `bool` (SharedPreferences) | `OnboardingLocalDataSource`, `SplashLocalDataSource` | Write-once on completion; read on splash startup |

## 7. State

- Cubit/Bloc: `OnboardingCubit` — **Cubit** (load → emit → complete; pure Dart, no Flutter UI types — STATE-7)
- States: `OnboardingLoading`, `OnboardingSuccess(pages, currentIndex)` (computed `isLastPage`), `OnboardingError(failure)`, `OnboardingCompleted`
- Transitions:
  - Route builder calls `loadPages()` → `Loading` → `Success(index 0)` or `Error(failure)`
  - `onPageChanged(index)` (swipe or indicator tap) → `Success(index)`; the same index, negative and out-of-range indices are ignored
  - Next on a non-last slide → screen animates the `PageController` (guarded against rapid taps) → `onPageChanged` → `Success(index)`
  - Next on the last slide / Skip → `complete()` → persists the flag (a persist failure still completes, retried next launch) → `Completed`
  - Back → screen animates the `PageController` to the previous slide
- Screen-level effects (not the cubit): haptic tick + localized page announcement on actual page changes only; `Completed` → `context.goNamed(RouteNames.login)`
- Pagination: None (fixed 4 slides)

## 8. Dependencies

- Depends on (core):
  - `CacheService` / `SharedPreferencesService` (persistence; key `AppConsts.onboardingSeenKey`)
  - `AppRoute.create` + `AppPageTransition.fadeThrough` (routing)
  - `AppColorsExtension`, `AppTextStylesExtension` (theming)
  - `AppHaptics`, `TapScale`, `FadeSlideIn`, `Entrance` (motion)
  - `ApiResult`, `Failure` (error handling)
  - `OnboardingSvgs` (core/constants/assets.dart — SVG asset paths), `PageIndicator` (core/animations/state/page_indicator.dart)
- Package: `flutter_svg` (`SvgPicture`) — imported only by the illustration stage and its mapper, never by a screen/widget outside `presentation/widgets/illustrations/`.
- Used by (features): None (entry feature)

## 9. Localization

- Namespace: `context.t.onboarding.*`
- Keys: `skip`, `next`, `back`, `getStarted`, `illustration.profitNumber`, `slide1..4.headline/body`, `a11y.{skipButton,nextButton,backButton,getStartedButton,pageIndicator}` — see `assets/i18n/en.i18n.json` under `onboarding`
- RTL-safe: All layout uses `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`/`end`
- Screen reader: announces actual page changes via `SemanticsService.sendAnnouncement` with the localized `onboarding.a11y.pageIndicator(current:, total:)` string and `Directionality.of(context)`; the initial load does not announce

## 10. Business rules & edge cases

### Layout contract (ratios in `onboarding_layout_constants.dart`)

- One layout root inside `SafeArea`: `topPadding 0.01H` → top bar `0.07H` (clamped 48–56) → Expanded page area → indicator above `0.02H` → fixed indicator band (48) → indicator below `0.025H` → controls band `0.07H` (clamped 48–56) → bottom padding `0.025H`. Chrome bands never move with page state or animation.
- Page: illustration region + `0.025H` gap + headline (maxLines 2, ellipsis) + `0.012H` gap + body (maxLines 3, ellipsis). Illustration side `S = min(0.88 × pageWidth, region height, adapt(375))` — always a square, can never cover the text.
- Skip stays in the fixed-height bar on slides 1–3 (`IgnorePointer` + `ExcludeSemantics` on last slide, removed by the switcher); the switcher's at-rest state is full opacity, no offset, scale 1.0.
- Controls row: Back slot width `0 ↔ buttonHeight + sm` at the start side (zero-width slot on slide 1); Next/Get started end-anchored at `compactNextWidthFactor(remaining width)` (max of 0.6 fraction and `adapt(120)` min) on slides 1–3, full remaining width on the last slide, fixed band height. Labels in `FittedBox`.
- Indicator: fixed 48-high tap boxes; active dot morphs to a `3 × dotSize` pill; row centered.
- Illustrations are the layered SVG set (`assets/svgs/onboarding/…`: one 400×400 element per file, stacked at identical size). Every layer is animated with transform/fade/clip only, and every interval, pivot and text slot is a named constant in `onboarding_illustration_constants.dart` — no motion literal lives in a widget. RTL mirrors the artwork stack once (`Transform.flip`, flipX); the number slots are `PositionedDirectional` overlays outside the flip, so text itself never mirrors. Numbers are Flutter text slots: `NumberFormat.percentPattern` for `75%`, `NumberFormat.compact` + the slang `onboarding.illustration.profitNumber` key for `EGP 128K`, both wrapped in `FittedBox(scaleDown)` with tabular figures. Layer colors come from the 16 placeholder hex values baked into the SVGs through `OnboardingSvgColorMapper`, which resolves each one to the active theme's token at render time (`onboarding_svg_palette.dart` is the only place those placeholders live); `surface` and `onColor` are separate keys so glyphs drawn on colored fills stay legible in dark mode.
- Fit-to-content sizing: Slides 1 and 3 size their visible illustration region to the aspect ratio of `contentBoundsNorm` (union of settled layer bboxes plus text slots, with 0.02 inner margin: slide 1 = (0.0325, 0.1225, 0.935, 0.7375); slide 3 = (0.0575, 0.1525, 0.885, 0.7225)), scaling the 400x400 canvas by `canvasSide = regionWidth / contentBoundsWidthNorm` so settled artwork fills ≥95% of available padded width on phones without overflowing. Slides 2 and 4 maintain square bounds.
- Assembly entrance: Total duration `illustrationEntranceDuration = 1500 ms` with `illustrationEntranceDelayFraction = 0.2` (300 ms). Layers enter from scattered positions with `easeOutCubic` / `easeOutBack`, opacity fading in over first 45% of layer interval, culminating in a subtle settle pulse (1.012 scale) during progress 0.88–1.00.
- No hardcoded hex values in widgets: the SVG placeholders (`onboarding_svg_palette.dart`) map to theme tokens through `OnboardingSvgColorMapper`, and the text slots read `context.colors.*`.

### Behavior

- Skip button visible on slides 1–3, animates out on slide 4, animates back in when swiping back.
- Next button morphs into "Get started" on last slide (animated width, label crossfade, icon swap).
- Back button on slide 1 follows standard Android behavior (exits app); slides 2–4 go to previous slide.
- Completion uses `context.goNamed(RouteNames.login)` which replaces the route stack — back button never returns to onboarding or splash.
- Idle loops (breathe, pulse, float, flow-dot travel) run only while the slide is the active, settled page, animations are enabled and the illustration square side is ≥ 360dp (`lowEndMaxSide`).
- Reduced motion: `MediaQuery.disableAnimations` → instant entrances, no parallax, instant morphs, no idle loops, settled frame immediately without running tickers.

## 11. Tests

| Area | Test files | Covered behaviors |
|------|------------|-------------------|
| domain | `domain/usecases/get_onboarding_pages_usecase_test.dart`, `domain/usecases/complete_onboarding_usecase_test.dart` | success and failure for both usecases |
| data | `data/repositories/onboarding_repository_impl_test.dart` | static page list, `completeOnboarding` forwarding success/failure |
| data | `data/datasources/local/onboarding_local_data_source_test.dart` | cache write/read of `AppConsts.onboardingSeenKey`, failure mapping |
| data | `data/models/onboarding_page_model_test.dart` | `toEntity`, `fromEntity`, round-trip |
| presentation | `presentation/cubit/onboarding_cubit_test.dart` | all state transitions, ignored indices, completion on failure |
| presentation | `presentation/mappers/onboarding_page_mapper_test.dart` | slang headline/body per page, unknown id |
| presentation | `presentation/screens/onboarding_screen_test.dart` | loading, success, error, completed → login, skip/next taps call `complete()` |

## 12. Known issues / TODO

- Dead `OnboardingIllustration` abstract base class remains in `presentation/widgets/illustrations/onboarding_illustration.dart`; nothing references it since the SVG rework.
- Integration test for full splash → onboarding → login flow not yet written.
- No onboarding feature tests exist yet.

## 13. Changelog

- 2026-10-17 — Synced FEATURE.md with code: removed the fictional Tests section (no onboarding tests exist), corrected the file map (indicator is the core `PageIndicator`; added the feature-local `onboarding_svg_palette.dart`), moved `OnboardingSvgPalette` out of core dependencies; set `Last verified` to today.
- 2026-10-16 — Fixed illustration animation and enlarged slides 1 & 3: fixed eager background entrance on neighbor slides, reduced-motion instant settlement sync, removed redundant outer scale/opacity transforms; added fit-to-content for slides 1 & 3 via `contentBoundsNorm`; implemented 1500ms assembly choreography with 300ms delay; updated golden references.
- 2026-10-16 — Review-hardening pass: states consumed via exhaustive switches; cubit reduced to pure Dart; `OnboardingError(failure)` renders the localized `ErrorState` (ERR-4); route builder triggers `loadPages()` at route creation; DI moved to `lib/core/di/onboarding_injection.dart`; system back restored to standard behavior; background blobs use `PositionedDirectional` for RTL.
- 2026-10-16 — Layout rework: single layout root with ratio-driven fixed chrome bands; square bounded illustration; 48 tap targets; layout-driven Next width morph; normalized + RTL-mirrored illustrations with theme colors; added layout widget-test matrix and golden tests.
- 2026-10-16 — Replaced the four CustomPaint illustrations with the layered SVG set (`assets/svgs/onboarding/`): shared `LayeredIllustration` stage, sealed motion catalogue, theme-driven `OnboardingSvgColorMapper` over the 16 placeholder hex values, single RTL flip with unflipped text slots, size-gated idle loops, reduced-motion support.
- 2026-10-17 — Added the full onboarding test suite: usecases, repository impl, datasource, model, cubit, mapper, and widget tests (39 tests).
