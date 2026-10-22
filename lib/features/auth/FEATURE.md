# Auth Feature

> Last verified: 2026-10-22
> Path: `lib/features/auth/`

## 1 Purpose
Authentication data + business logic for the Orbit app: sign in (tokens + cached
profile persisted), create a pending account, sign out (remote revocation plus an
always-clearing local session), check a person's employment status, and expose the
local session snapshot for the router. No screens/widgets yet — presentation ships
as Cubits only, ready for future screens to consume.

## 2 Screens & routes
None yet. Cubits are registered in DI and ready to be consumed by future
login/signup/status screens; no routes are defined by this feature.

## 3 File map
| Layer | Key files (relative to feature root) | Responsibility |
|-------|--------------------------------------|----------------|
| presentation | cubits/login/login_cubit.dart + login_state.dart | Sign-in flow states (initial/loading/success/error), double-submit guard |
| presentation | cubits/signup/signup_cubit.dart + signup_state.dart | Sign-up flow states |
| presentation | cubits/employee_status/employee_status_cubit.dart + employee_status_state.dart | Employment-status check states |
| domain | entities/*.dart, enums/user_role.dart, enums/employment_status.dart | User, Permission, AuthSession, SignupResult, EmployeeStatusInfo, SessionInfo; typed wire-backed enums |
| domain | params/login_params.dart, params/signup_params.dart | Request inputs |
| domain | repositories/auth_repository.dart | Repository contract |
| domain | usecases/*.dart (5) | Thin use cases over the repository |
| data | datasources/remote/auth_remote_data_source.dart | The whole auth API: endpoints, verbs, wire bodies, GET-with-body, failure mapping |
| data | datasources/local/auth_local_data_source.dart | Token persistence (secure storage only), cached user, session snapshot, rollback |
| data | models/*.dart (6) | Hand-written JSON mapping with `ApiKeys` field names: `fromJson` where the payload arrives, `toJson` where it is persisted (user, permission), `toEntity()` everywhere |
| data | repositories/auth_repository_impl.dart | Orchestration: login persists, logout clears regardless, error flow |

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
| SignupUseCase | SignupParams | ApiResult<SignupResult> | Nothing persisted |
| LogoutUseCase | — | ApiResult<void> | Remote revocation never blocks the local clear |
| GetEmployeeStatusUseCase | String email | ApiResult<EmployeeStatusInfo> | — |
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
fields) under `auth_cached_user` via `CacheService.writeJsonMap`.

## 7 State
Cubit — reason: each flow is one usecase call per submission, no event
transformation (STATE-1). Sealed Equatable states `LoginInitial/LoginLoading/
LoginSuccess/LoginError` (same shape for signup and employee status). Each
submission call is re-entrancy guarded (in-flight submissions are ignored; a new
attempt is allowed after a failure). `isClosed` is checked before post-result emits.

## 8 DI
`core/di/auth_injection.dart` — `initAuthModule`: data sources and repository
(lazy singleton), five use cases (lazy singleton), three cubits (factory).

## 9 i18n
No feature copy yet. Error copy comes from `context.failureText` (core); login 401
renders `errors.invalidCredentials`.

## 10 Tests
`test/features/auth/` (mocktail + bloc_test):
- **Enums**: `user_role_test.dart` (ids, unknown fallback), `employment_status_test.dart` (values, normalization, fallback).
- **Models**: permission (round-trip), user (role mapping incl. B9 non-int, round-trip, toEntity), login (tokens + user, missing pieces throw), signup echo, employee status (nested user, unknown/missing status), session info snapshot.
- **Use cases** ×5: repository passthrough (params identity, failures untouched).
- **Remote datasource**: login test file (wire body + public extra, B4 reclass with serverMessage, network/validation passthrough, parsing failure) and main test file (signup wire keys + no-reclass, logout body, GET-with-body + nested parse, transport failures).
- **Local datasource**: write order, no-token-keys-in-cache pin, rollback on every write stage (B6), clear, refresh-token read, session snapshot incl. corrupt-user degradation (B5).
- **Repository impl**: login persists then returns entity; save failure propagates (B6); remote failures pass through without persisting; signup never persists (login/signup file); logout B10 semantics — remote skipped without token or when the token read fails, cleared even on remote failure, clear failure returned; status/session mapping (main file).
- **Cubits** ×3: initial state, [Loading, Success/Error], re-entrancy guard (completer-driven), post-failure resubmission, login carries `InvalidCredentialsFailure`.
- **Core tests covering this feature's wiring**: `test/core/di/injection_container_test.dart` (auth registrations + factory scopes), splash datasource test pins the shared token key, `test/core/config/app_env_test.dart` covers `.env` loading/fail-fast.

## 11 Known issues
- Backend wire shapes (keys, statuses, GET-with-body) are as agreed with the backend;
  `None` assumptions: signup response is expected to echo `first_name`/`last_name`/`email`.

## 12 Changelog
- 2026-10-21: Feature created — domain (entities/enums/params/repository/5 use cases), models, remote + local data sources, repository impl, three Cubits, DI module; core additions: error-body parser, `InvalidCredentialsFailure`, token log redaction, `AppEnv` (.env BASE_URL), `get(data)` seam + `X-Client-Type` header, first-of-name constants.
- 2026-10-22: Review pass — states renamed to the STATE-5 naming, logout folds the token read instead of unwrapping (ERR-3), core `AppEnv`/`ErrorBodyParser` as `abstract final`, request header/extra names moved to `ApiKeys` and the log tag to `LogTags`.
