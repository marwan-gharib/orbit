# Core Map

Check this before writing anything reusable (ARCH-4, UI-2). Keep it short: name, path, one-line use.
Update it whenever `core/` gains, loses, or changes a reusable piece (DOC-6).

## Constants (ARCH-10: the ONLY place string keys, paths, routes, assets live)
- `ApiKeys` — core/constants/api_keys.dart — JSON / request / header field names.
- `Endpoints` — core/constants/endpoints.dart — API paths.
- `AppRoutes` — core/constants/app_routes.dart — route names and paths.
- `Assets` — core/constants/assets.dart — asset paths.
- `AppConsts` — core/constants/app_consts.dart — other shared constants (storage keys, env names, durations...).

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

## Extensions / helpers
- `BuildContext` extensions — core/extensions/…
- Failure → localized message — core/extensions/…

## Theme / router / DI
- `AppColorsExtension` — core/theme/…
- go_router configuration — core/router/…
- Injection container — core/di/… (read `lib/core/di/feature_module_registry.md` first, DI-1)

<!-- Fill the paths. Run a one-off session: "scan core/ and fill docs/CORE_MAP.md" (docs only). -->
