# Auth Feature

> Last verified: 2026-10-22
> Path: `lib/features/auth/`

## 1 Purpose
Authentication end to end: sign in with a persisted session, create a pending account
that survives a restart, the three auth screens (login, signup, waiting for approval),
and the approval check with its cooldown and terminal moment. The router uses the local
session snapshot and the process-wide pending session to keep `/login`, `/signup` and
`/pending` consistent.

## 2 Screens & routes
| Screen | Route | Entry | Exit |
|--------|-------|-------|------|
| `LoginScreen` | `/login` (`RouteNames.login`) | splash when signed out with no pending signup; footer link from signup; approved pending exit | success → `home` placeholder; footer → signup |
| `SignupScreen` | `/signup` (`RouteNames.signup`) | footer link from login; rejected pending exit | success → `pending`; footer → login |
| `PendingScreen` | `/pending` (`RouteNames.pending`) | signup success; splash when a pending email is persisted; guard redirect | approved → login, rejected → signup, both after a 2 s moment |

All three use `AppPageTransition.fadeThrough` and navigate with `context.goNamed`
(replacement only): no auth screen is pushed, so there is no back stack between them.
`PendingScreen` wraps its content in `PopScope(canPop: false)`.

Guard: `RouteGuards.authRedirect` (core) receives `isPendingSignup`. While a pending
session exists, `/login` and `/signup` redirect to `/pending`; without one, `/pending`
redirects to `/login`. The router listens to `PendingSignupSession`
(`refreshListenable`), so ending the pending flow unlocks the next route immediately.

## 3 File map
| Layer | Key files (relative to feature root) | Responsibility |
|-------|--------------------------------------|----------------|
| presentation | screens/login_screen.dart | Sign-in form, validation, single BlocListener (success → home, failure → shake + haptic), inline banner |
| presentation | screens/signup_screen.dart | Five-field form, live password checklist/strength, server field errors, success → pending |
| presentation | screens/pending_screen.dart | Email + status card, manual check, last-checked time, error/unchanged notices, terminal moment + exit timer |
| presentation | widgets/auth_page_scaffold.dart, auth_brand_header.dart, auth_error_banner.dart, auth_navigation_link.dart | Shared auth chrome: scroll-safe centered column, brand header, inline failure banner, footer link |
| presentation | widgets/password_checklist.dart, password_rule_row.dart, password_rules.dart, password_strength_bar.dart | Id-based password policy drives both validator and live checklist; strength bar follows checklist progress |
| presentation | widgets/pending_hero.dart, pending_stepper.dart, pending_status_card.dart, pending_moment.dart, pending_info_notice.dart, check_status_button.dart | Pending artwork, three-step progress, status/email card, terminal card, unchanged notice, check action with cooldown |
| presentation | mappers/signup_field_errors_mapper.dart | `ValidationFailure` → inline field messages; unknown keys keep the generic banner |
| presentation | mappers/employment_status_view.dart | Localized status label, badge severity and terminal check for `EmploymentStatus` |
| presentation | constants/auth_layout_constants.dart | Responsive auth dimensions (hero, stepper, banner, moment, notice) |
| presentation | cubits/login/, cubits/signup/, cubits/employee_status/ | Flow states (initial/loading/success/error), double-submit guards |
| domain | entities/*.dart, enums/user_role.dart, enums/employment_status.dart | User, Permission, AuthSession, SignupResult, EmployeeStatusInfo, SessionInfo; typed wire-backed enums |
| domain | params/login_params.dart, params/signup_params.dart | Request inputs |
| domain | repositories/auth_repository.dart | Repository contract |
| domain | usecases/*.dart (5) | Thin use cases over the repository |
| data | datasources/remote/auth_remote_data_source.dart | The whole auth API: endpoints, verbs, wire bodies, GET-with-body, failure mapping |
| data | datasources/local/auth_local_data_source.dart | Token persistence (secure storage only), cached user, pending email, session snapshot, rollback |
| data | models/*.dart (6) | Hand-written JSON mapping with `ApiKeys` field names: `fromJson` where the payload arrives, `toJson` where it is persisted, `toEntity()` everywhere |
| data | repositories/auth_repository_impl.dart | Orchestration: login persists, signup persists the pending email, logout clears regardless, status clears the cache on a terminal decision |

## 4 Entities & models
| Entity | Key fields | Model (data) | Notes |
|--------|------------|--------------|-------|
| User | firstName, lastName, code, email, role, roleName, permissions | UserModel (+ PermissionModel) | `role` is the typed enum; raw role ids map through `UserRole.fromId`, unknown falls back to `unknown` |
| AuthSession | accessToken, refreshToken, user | LoginResponseModel | Tokens never land in entities' persistence — the local DS writes them straight to secure storage |
| SignupResult | firstName, lastName, email | SignupResponseModel | Echo only; no tokens, account starts implicitly `pending` |
| EmployeeStatusInfo | firstName, lastName, status | EmployeeStatusResponseModel | `status` maps through `EmploymentStatus.fromValue` (case/whitespace-tolerant, `unknown` fallback) |
| SessionInfo | isAuthenticated, user? | SessionInfoModel | Local-only routing snapshot; corrupt cached user is treated as absent |

## 5 Use cases
| UseCase | Input | Output | Business rule (if any) |
|---------|-------|--------|------------------------|
| LoginUseCase | LoginParams | ApiResult<AuthSession> | Repository persists the session; persistence failure fails the login loudly (rollback already ran) |
| SignupUseCase | SignupParams | ApiResult<SignupResult> | Repository persists the returned email as the pending signup; persistence failure fails signup loudly |
| LogoutUseCase | — | ApiResult<void> | Remote revocation never blocks the local clear; the local clear also ends the pending email/session |
| GetEmployeeStatusUseCase | — (reads the persisted pending email) | ApiResult<EmployeeStatusInfo> | A terminal decision clears the persisted pending email only; the in-memory session survives for the moment |
| GetSessionInfoUseCase | — | ApiResult<SessionInfo> | Never fails for missing data; missing means "signed out" |

## 6 API & storage
Wire keys in `core/constants/api_keys.dart`, paths in `core/constants/endpoints.dart`
(`Endpoints.authLogin/authSignup/authLogout/authEmployeeStatus`), storage keys in
`core/constants/app_consts.dart`:

| Call | Method | Notes |
|------|--------|-------|
| `/api/auth/login/` | POST | body `email` + `password`; request opts out of the bearer token (`AuthInterceptor.requiresAuthExtra`); a 401 becomes `InvalidCredentialsFailure` (B4) |
| `/api/auth/signup/` | POST | body `first_name`, `last_name`, `work_email` (NOT `email`), `password` |
| `/api/auth/logout/` | POST | body `refresh`; called with the stored refresh token only if one exists |
| `/api/auth/get_employee_status/` | GET with JSON body | `email` in the body — the unusual shape is isolated in `AuthRemoteDataSource` via the core `get(data)` seam |

Storage: `access_token` + `refresh_token` in secure storage ONLY (never cache, never
logs — the logging interceptor masks token values); cached user profile (no token
fields) under `auth_cached_user` via `CacheService.writeJsonMap`; pending signup email
under `pending_signup_email` so splash can resume the approval flow after a restart.
The local data source mirrors that email into the core `PendingSignupSession`
(`ChangeNotifier`) and clears both on sign-out; a terminal status check clears only the
persisted copy so the pending screen can still play its moment.

## 7 State
Cubit — reason: each flow is one usecase call per submission, no event
transformation (STATE-1). Sealed Equatable states `LoginInitial/LoginLoading/
LoginSuccess/LoginError` (same shape for signup and employee status). Each
submission call is re-entrancy guarded (in-flight submissions are ignored; a new
attempt is allowed after a failure). `isClosed` is checked before post-result emits.

Presentation rules:
- No screen-level `setState`; scoped `BlocSelector`/`BlocListener` and the password
  controllers' listeners rebuild only the affected subtree. Login/signup side effects
  live in one listener each (navigation, shake, haptics, server field mapping).
- Pending entry performs NO automatic check (D6): it shows the email and "Last
  checked: never" until the person taps Check status. The completion time is captured
  in the screen and formatted with `MaterialLocalizations.formatTimeOfDay`.
- `CheckStatusButton` owns a 15 s in-memory cooldown (`AppConsts.pendingCheckCooldown`)
  that starts when a check completes, success or failure, and resets with the screen
  instance. The Cubit's loading guard is the last defence against double submission.
- A pending success shows the unchanged notice; a failure shows `AuthErrorBanner` with
  `context.failureText` and still starts the cooldown; unknown stays on the screen.
- Approved/rejected shows `PendingMoment` for `AppConsts.pendingMomentHold` (2 s), then
  clears the in-memory session and replaces the route. The exit timer and haptics live
  in the screen listener; the timer is cancelled on dispose. Login success → home;
  signup success → pending.
- Motion (ANIM-2), all from `core/animations`: login failure `ShakeWidget` (one-shot,
  `AppDurations.slow`; skipped under reduced motion) plus the `FadeIn` banner
  (`AppDurations.normal`/`AppCurves.enter`); signup rule markers cross-fade through
  `AppAnimatedSwitcher` and the strength meter uses `AnimatedProgressBar` (core
  defaults, instant under reduced motion); pending hero `IdleLoop` orbit
  (`AppDurations.indeterminate`, linear, repeats, holds the settled frame under
  reduced motion, ticks rebuild only the rotation transform, ticker disposed with the
  route), one-shot `FadeIn`/`ScaleIn` for the terminal moment and `FadeIn` notices,
  `AnimatedVisibility` for the cooldown hint. No feature owns an animation controller.

## 8 DI
`core/di/auth_injection.dart` — `initAuthModule`: data sources and repository
(lazy singleton), five use cases (lazy singleton), three cubits (factory). The core
container also registers the process-wide `PendingSignupSession` singleton; the router
and the auth data source share that one instance. The route table resolves each Cubit
and the session from GetIt.

## 9 i18n
`auth.login.*`, `auth.signup.*`, `auth.pending.*` in `assets/i18n/en.i18n.json`, plus
shared `validators.*`. Validators return localized strings built from those keys; the
password rule ids in `core/utils/field_rules.dart` drive both validation and the live
checklist, so copy and rules cannot drift. English only for now; all copy goes through
slang and no screen contains a user-facing literal.

## 10 Tests
`test/features/auth/` (mocktail + bloc_test):
- **Enums**: `user_role_test.dart` (ids, unknown fallback), `employment_status_test.dart` (values, normalization, fallback).
- **Models**: permission (round-trip), user (role mapping incl. B9 non-int, round-trip, toEntity), login (tokens + user, missing pieces throw), signup echo, employee status (nested user, unknown/missing status), session info snapshot.
- **Use cases** ×5: repository passthrough (params identity, failures untouched).
- **Remote datasource**: login test file (wire body + public extra, B4 reclass with serverMessage, network/validation passthrough, parsing failure) and main test file (signup wire keys + no-reclass, logout body, GET-with-body + nested parse, transport failures).
- **Local datasource**: `auth_local_data_source_test.dart` — write order, no-token-keys-in-cache pin, rollback on every write stage (B6), clear, refresh-token read, session snapshot incl. corrupt-user degradation (B5). `auth_local_data_source_pending_test.dart` — pending email round-trip, write/read failures, cached-only vs full clear, and sign-in ending the pending flow.
- **Repository impl**: login persists then returns entity; save failure propagates (B6); remote failures pass through without persisting; signup persists the pending email; logout B10 semantics — remote skipped without token or when the token read fails, cleared even on remote failure, clear failure returned; status reads the email, clears the cache only on approved/rejected, and maps/session snapshot.
- **Cubits** ×3: initial state, [Loading, Success/Error], re-entrancy guard (completer-driven), post-failure resubmission, login carries `InvalidCredentialsFailure`.
- **Presentation mappers**: `signup_field_errors_mapper_test.dart` (known keys, first message, unknown/empty fallback, banner decision); `employment_status_view` is covered through the pending screen.
- **Shared widgets**: brand header, error banner, navigation link, page scaffold, password checklist/rules/strength bar.
- **Screens**: `login_screen_test.dart` (7) render, required fields, invalid email, inline banner, no duplicate submit while loading, success → home, footer → signup; `signup_screen_test.dart` (9) render, required + name/password policy, mismatch, trimmed submit → pending, mapped field error inline, unmapped banner, loading guard, footer → login; `pending_screen_test.dart` (6) entry state/no auto check/PopScope, check once + unchanged + last-checked + 15 s cooldown, failure banner, approved → login, rejected → signup, unknown stays.
- **Core tests covering this feature's wiring**: `test/core/di/injection_container_test.dart` (auth registrations + factory scopes), splash datasource test pins the shared token/pending keys and mapper covers pending precedence, `test/core/config/app_env_test.dart` covers `.env` loading/fail-fast.

## 11 Known issues
- A terminal status clear of the persisted pending email is best-effort: a cache failure
  is ignored, but the in-memory flow still ends and the screen leaves normally.
- `assets/animations/` is empty, so the terminal moments use core entrance widgets
  (`FadeIn` + `ScaleIn`); the cards are ready to swap in a Lottie skin when assets exist.
- Before the first check the screen knows only the email; the greeting appears once a
  successful check returns the person's first name.

## 12 Changelog
- 2026-10-22: Auth UI shipped — login, signup and pending-approval screens built on
  core widgets/animations/responsive; shared auth widgets; validators and id-based
  password rules; pending signup persistence + `PendingSignupSession`; auth route
  guard and splash pending-aware routing; screen, mapper and widget tests.
- 2026-10-21: Feature created — domain (entities/enums/params/repository/5 use cases), models, remote + local data sources, repository impl, three Cubits, DI module; core additions: error-body parser, `InvalidCredentialsFailure`, token log redaction, `AppEnv` (.env BASE_URL), `get(data)` seam + `X-Client-Type` header, first-of-name constants.
- 2026-10-22: Review pass — states renamed to the STATE-5 naming, logout folds the token read instead of unwrapping (ERR-3), core `AppEnv`/`ErrorBodyParser` as `abstract final`, request header/extra names moved to `ApiKeys` and the log tag to `LogTags`.
