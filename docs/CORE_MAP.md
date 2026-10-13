# Core Map

Check this before writing anything reusable (ARCH-4, UI-2). Keep it short: name, path, one-line use.
Update it whenever `core/` gains, loses, or changes a reusable piece (DOC-6).

## Network

- `BaseApiClient` — core/network/base_api_client.dart — abstract HTTP client.
- `DioApiClient` — core/network/dio_api_client.dart — the concrete client.
- Interceptors — core/network/interceptors/ — auth token, locale, error mapping, logging.
- `dio` import scope (amended ARCH-5/DATA-1): only `core/network/**` and the
  `Dio` error classifier at core/errors/dio_error_handler.dart.

## Error

- `Failure` hierarchy (Network, Cancelled, Unauthorized, Forbidden, NotFound, Validation,
  Request, Server, RateLimit, Parsing, Cache, Storage, Unknown) — core/errors/failures.dart
- `Exception` hierarchy — core/errors/exceptions.dart
- `ErrorMapper` (exception → `Failure`) — core/errors/error_mapper.dart
- Dio error translation — core/errors/dio_error_handler.dart

## Utils

- `AppConsts` (base URL for every request) — core/constants/app_consts.dart
- `ApiResult<T>` (+ `fold`) — core/utils/api_result.dart
- `PagedResult<T>` — core/utils/paged_result.dart
- `Validators` — core/utils/validators.dart
- `Logger` — core/utils/logger.dart

## Local storage

- `SecureStorageClient` (abstraction) / `SecureStorageImpl` — core/local/secure/
- `CacheService` (abstraction) / `SharedPreferencesService` — core/local/cache/

## Shared widgets

- None yet. Add `AppButton`, `AppTextField`, `AppLoader`, `AppSnackBar` to core/widgets/
  when a second feature needs them (UI-2).

## Extensions / helpers

- `BuildContext` extensions — core/extensions/context_extensions.dart

## Responsive

- `Responsive` (facade) + `ResponsiveScaler` / `IdentityResponsiveScaler` / `ScreenUtilScaler`
  — core/responsive/. NOT yet mounted: `main()` does not call `Responsive.ensureInitialized()`
  and no `ResponsiveScope` sits above the app, so the engine is the identity transform
  (values pass through unchanged). Mount both when the first screen uses scaling.

## Localization

- slang source of truth — `assets/i18n/<locale>.i18n.json`; regenerate with `dart run slang`.
- Generated translations — lib/core/i18n/ (never edit by hand).
- Config — `slang.yaml` (`string_interpolation: braces`).

## Theme / router / DI

- `AppColorsExtension` — core/theme/extensions/colors_extension.dart
- `AppColors` (raw palette, theme-only) — core/theme/app_colors.dart
- `AppTheme` (light/dark) — core/theme/app_theme.dart
- `AppRouter` + `AppRouterRoutes` — core/router/app_router.dart, core/router/app_router_routes.dart
- Route constants — core/router/route_names.dart, core/router/route_paths.dart
- `RouteGuards` — core/router/route_guards.dart (empty stub, no guards yet)
- Injection container — core/di/injection_container.dart (`initDependencies` → `initCoreModule`)
- Core module registrations — core/di/core_module.dart — secure storage, cache (SharedPreferences), `BaseApiClient` (`DioApiClient.configured` with `AppConsts.baseUrl`)
- Feature-module pattern — core/di/feature_module_registry.md
