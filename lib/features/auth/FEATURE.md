# Auth Feature

> Last verified: 2026-10-24
> Path: `lib/features/auth/`

## 1 Purpose
Authentication end to end: sign in with a persisted session, sign in / sign up with
Google SSO ("Continue with Google"), create a pending account that survives a restart,
the three auth screens (login, signup, waiting for approval), and the approval check
with its cooldown and terminal moment. The router uses the local session snapshot and
the process-wide pending session to keep `/login`, `/signup` and `/pending` consistent.

## 2 Screens & routes
| Screen | Route | Entry | Exit |
|--------|-------|-------|------|
| `LoginScreen` | `/login` (`RouteNames.login`) | splash when signed out with no pending signup; footer link from signup; approved pending exit | password/Google success → `home`; Google new user → `pending`; footer → signup |
| `SignupScreen` | `/signup` (`RouteNames.signup`) | footer link from login; rejected pending exit | success → `pending`; footer → login |
| `PendingScreen` | `/pending` (`RouteNames.pending`) | signup/Google new user success; splash when a pending email is persisted; guard redirect | approved → login, rejected → signup, both after a 2 s moment |

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
| presentation | screens/login_screen.dart | Sign-in form, password login & Google SSO buttons, mutual loading guard, listeners (home/pending/error shake) |
| presentation | screens/signup_screen.dart | Five-field form, live password checklist/strength, server field errors, success → pending |
| presentation | screens/pending_screen.dart | Email/Google badge + status card, manual check, last-checked time, error/unchanged notices, terminal moment |
| presentation | widgets/auth_page_scaffold.dart, auth_brand_header.dart, auth_error_banner.dart, auth_navigation_link.dart | Shared auth chrome: scroll-safe centered column, brand header, inline failure banner, footer link |
| presentation | widgets/login_or_divider.dart, google_sign_in_button.dart | Animated "or continue with" divider and custom elevated Google SSO button |
| presentation | widgets/pending_status_card.dart | Displays unmasked email or "Registered with Google" badge based on registration mode |
| presentation | cubits/login/, cubits/google_sign_in/, cubits/signup/, cubits/employee_status/ | Flow states, double-submit guards, mutual disabling |
| domain | entities/*.dart, google_sign_in_result.dart, enums/*.dart | User, Permission, AuthSession, SignupResult, GoogleSignInResult (LoggedIn/Registered) |
| domain | params/login_params.dart, params/signup_params.dart, params/google_payload.dart | Request inputs and decoded Google JWT claims |
| domain | repositories/auth_repository.dart | Repository contract including `signInWithGoogle` |
| domain | usecases/*.dart (6) | Thin use cases over the repository |
| data | datasources/google/google_auth_client.dart | GoogleSignIn v7 plugin isolation, token retrieval, cancellation mapping |
| data | datasources/remote/auth_remote_data_source.dart | The whole auth API: login, signup, logout, employee status, Google SSO mobile |
| data | datasources/local/auth_local_data_source.dart | Token persistence (secure storage), cached user, pending email + Google flag, rollback, implements core SessionCleaner, resets SessionExpiredNotifier on login, increments session generation on clearSession |
| data | models/*.dart (7) | Hand-written JSON mapping: login, signup, employee status, session info, GoogleSsoResponseModel |
| data | repositories/auth_repository_impl.dart | Orchestration: login/Google persistence, pending signup flag, rollback, session cleanup |

## 4 Entities & models
| Entity | Key fields | Model (data) | Notes |
|--------|------------|--------------|-------|
| User | firstName, lastName, code, email, role, roleName, permissions | UserModel (+ PermissionModel) | Typed role enum; unknown role id falls back to `unknown` |
| AuthSession | accessToken, refreshToken, user | LoginResponseModel | Tokens stored strictly in secure storage |
| SignupResult | firstName, lastName, email | SignupResponseModel | Echo only; no tokens, account starts implicitly `pending` |
| GoogleSignInResult | LoggedIn(session) / Registered(signupResult) | GoogleSsoResponseModel | Discriminated union parsed by presence of `access_token` |
| EmployeeStatusInfo | firstName, lastName, status | EmployeeStatusResponseModel | `status` mapped through `EmploymentStatus.fromValue` |
| SessionInfo | isAuthenticated, user? | SessionInfoModel | Local-only routing snapshot |

## 5 Use cases
| UseCase | Input | Output | Business rule (if any) |
|---------|-------|--------|------------------------|
| LoginUseCase | LoginParams | ApiResult<AuthSession> | Repository persists session; rollback on storage failure |
| SignInWithGoogleUseCase | GooglePayload | ApiResult<GoogleSignInResult> | Persists session on login; persists email + google flag on signup |
| SignupUseCase | SignupParams | ApiResult<SignupResult> | Repository persists email as pending signup |
| LogoutUseCase | — | ApiResult<void> | Remote revocation never blocks local clear; clears tokens and pending |
| GetEmployeeStatusUseCase | — | ApiResult<EmployeeStatusInfo> | Terminal decision clears persisted pending email |
| GetSessionInfoUseCase | — | ApiResult<SessionInfo> | Never fails for missing data; missing means "signed out" |

## 6 API & storage
Wire keys in `core/constants/api_keys.dart`, endpoints in `core/constants/endpoints.dart`,
storage keys in `core/constants/app_consts.dart`:

| Call | Method | Notes |
|------|--------|-------|
| `/api/auth/login/` | POST | body `email` + `password`; 401 becomes `InvalidCredentialsFailure` (B4) |
| `/api/auth/sso_mobile/` | POST | body `iss`, `sub`, `email`, `given_name`, `family_name`, `id_token` (`sendIdToken=false` omits `id_token` from body) |
| `/api/auth/signup/` | POST | body `first_name`, `last_name`, `work_email`, `password` |
| `/api/auth/logout/` | POST | body `refresh`; called with stored refresh token |
| `/api/auth/get_employee_status/` | GET with body | `email` in body; isolated in `AuthRemoteDataSource` |

Storage: `access_token` + `refresh_token` in secure storage ONLY; cached user under
`auth_cached_user` in cache; pending email under `pending_signup_email` and Google flag
under `pending_signup_google`. Local data source mirrors them into `PendingSignupSession`.

## 7 State
Sealed Equatable states across all Cubits.
- `GoogleSignInCubit`: `GoogleSignInIdle`, `GoogleSignInLoading`, `GoogleSignInAuthenticated`,
  `GoogleSignInPending`, `GoogleSignInError`. Handles Google client cancellations gracefully (returns to Idle).
- Mutual loading guard on `LoginScreen`: submit button and Google button are both disabled while
  either `LoginCubit` or `GoogleSignInCubit` is loading.
- Inline `AuthErrorBanner` and `ShakeWidget` surface both password and Google SSO failures.

## 8 DI
`core/di/auth_injection.dart` — `initAuthModule`: data sources and repository
(lazy singleton), `GoogleAuthClient` (lazy singleton), use cases (lazy singleton),
cubits (factory). Initializes GoogleSignIn with `serverClientId` from `AppEnv`. Restores
pending signup session email and `registeredWithGoogle` flag at startup.

## 9 i18n
All user-facing text goes through slang (`assets/i18n/en.i18n.json`).
Added keys for `orDivider`, `googleSignIn`, `googleSignInLoading`, `googleSignInError`,
`a11y.googleSignIn`, and `registeredWithGoogle`. No hardcoded strings.

## 10 Tests
`test/features/auth/` (mocktail + bloc_test):
- **Core / Utils**: `jwt_payload_decoder_test.dart` (12), `pending_signup_session_test.dart` (6), `app_env_test.dart` (7).
- **Models**: `google_sso_response_model_test.dart` (6), permission, user, login, signup, status.
- **Use cases**: `sign_in_with_google_usecase_test.dart` (3), login, signup, logout, status.
- **Repository**: `auth_repository_impl_google_test.dart` (5) testing Google login persistence, signup pending persistence, failure propagation.
- **Cubits**: `google_sign_in_cubit_test.dart` (7) covering idle, cancellation, client failure, login success, signup success, backend error, token decode error.
- **Widgets**: `google_sign_in_button_test.dart` (3), `pending_status_card_test.dart` (5) covering Google badge vs email display.
- **Screens**: `login_screen_test.dart` (7), `login_screen_google_test.dart` (6) covering divider/button rendering, tap action, mutual loading disabling, authenticated navigation, pending navigation, error banner. `login_screen_validation_test.dart` (7) across small phone, tablet, large text scale.

## 11 Known issues
- Google SSO is configured for Android only at this stage; iOS requires client ID and URL schemes.
- A terminal status clear of the persisted pending email is best-effort.
- `assets/animations/` is empty, so terminal moments use core entrance widgets (`FadeIn` + `ScaleIn`).

## 12 Changelog
- 2026-10-24: Google SSO ("Continue with Google") shipped for Android — `google_sign_in` v7 integration, JWT payload decoder, Google SSO mobile endpoint, GoogleSsoResponseModel discriminated union, GoogleSignInCubit, GoogleSignInButton, LoginOrDivider, mutual disabling, registeredWithGoogle badge on pending screen, full test suite.
- 2026-10-23: Test pass — screen validation tests re-anchored to validator-on-submit; unit tests for pending widget cluster, password rules, status view mapper.
- 2026-10-22: Auth UI shipped — login, signup and pending-approval screens; shared auth widgets; validators and password rules; pending signup persistence; auth route guard.
- 2026-10-21: Feature created — domain, models, remote + local data sources, repository impl, three Cubits, DI module.
