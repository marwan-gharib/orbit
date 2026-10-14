# Architecture

## Folder structure

```text
lib/
  core/
    constants/    # ALL constants (ARCH-10): ApiKeys, Endpoints, AppRoutes, Assets, AppConsts... one file per purpose
    di/           # get_it setup + one injection file per feature
    errors/       # Failure hierarchy (+ the Dio error classifier)
    extensions/   # BuildContext and other extensions
    helpers/      # formatting, validation, small generic helpers
    local/
      secure/     # abstraction + impl for tokens / sensitive data
      cache/      # abstraction + impl for non-sensitive data
    network/      # BaseApiClient (abstract) + implementation + interceptors
    router/       # go_router config (route names and paths come from core/constants/)
    services/
    theme/        # ThemeExtension colors, text theme
    utils/        # ApiResult (with fold only), PagedResult, generic helpers
    widgets/      # shared UI: AppButton, AppTextField, AppLoader, AppSnackBar...
  features/<feature_name>/
    FEATURE.md                       # see feature-docs.md
    presentation/
      screens/
      widgets/
      cubits/<cubit_or_bloc_name>/   # cubit/bloc + sealed state
      view_models/                   # created with the first view model
      mappers/                       # entity -> view model (created with the first mapper)
    domain/
      entities/
      repositories/                  # abstract contracts only
      usecases/
      params/                        # one *Params class per usecase with >1 input
    data/
      datasources/
        remote/                      # concrete classes, no interface
        local/                       # concrete classes, no interface
      models/                        # any model can contain toEntity() to map to domain entity
      repositories/                  # *RepositoryImpl
docs/
  FEATURES_INDEX.md
  CORE_MAP.md
test/                                # mirrors lib/ exactly
```

## Rules

- ARCH-1  Layer flow is one-directional and never bypassed: Presentation → Domain → Data.

  | Layer        | Allowed                                    | Forbidden                              |
  |--------------|--------------------------------------------|----------------------------------------|
  | Presentation | Widgets, Cubit/Bloc, UI state, view models | Business logic, direct API/DB calls    |
  | Domain       | Usecases, entities, params, repo contracts | Any `package:flutter/...` import       |
  | Data         | API/DB calls, models, repo implementations | `BuildContext`, UI logic               |

  A feature may use another feature only through `core/` or through a domain
  usecase exposed for that purpose. It never imports another feature's data or presentation layer.

- ARCH-2  Business logic never lives in `initState`, `build()`, or a widget callback.
          Widgets call a Cubit method; the Cubit calls a usecase.
- ARCH-3  Domain entities are never used directly in widgets. Map them to a view model
          (`presentation/view_models/`, plain immutable Dart class) with a mapper in
          `presentation/mappers/`.
- ARCH-4  Code used by 2+ features belongs in `core/`. Before writing anything that
          looks reusable, read `docs/CORE_MAP.md`, then search `core/`. Reuse; do not duplicate.
- ARCH-5  Everything in `core/` is built on an abstraction (api client, secure storage,
          cache storage, logger, analytics...). Only the implementation inside `core/network/`
          and its interceptors may import `dio` (plus the `Dio` error classifier in
          `core/errors/`); every other package (shared_preferences, flutter_secure_storage...)
          is imported by its single implementation class only.
          Each implementation owns its error handling so no caller can forget it.
- ARCH-6  Datasources have NO abstract interface. `RemoteDataSource` / `LocalDataSource`
          are plain concrete classes. The only abstraction boundary is the repository
          contract in `domain/repositories/`; `RepositoryImpl` calls datasources directly.
- ARCH-7  Constructors:
          - Class with only static members → `abstract final class Name {}`.
          - Concrete class that must never be instantiated → private constructor
            `const Name._();`.
- ARCH-8  Dart 3 native only: `sealed class`, records, pattern matching, switch
          expressions. No Freezed, no json_serializable, no build_runner. `fromJson` /
          `toJson` are written by hand in `data/models/`.
- ARCH-9  Immutability: fields are `final`, constructors are `const` where possible.
          Value equality: use `Equatable` only if it is already in `pubspec.yaml`;
          otherwise implement `==` / `hashCode` manually. Never add the package.
- ARCH-10 Constants: no string literal may be used as a key, path, or identifier, anywhere in `lib/`.
          No exceptions, no "just this once", no private `const` next to the usage.
          The only place such a literal may be written is inside a file in `core/constants/`.
          Covered: JSON/API field names (`ApiKeys`), request body/query/header names, endpoints and
          paths (`Endpoints`), route names and paths (`AppRoutes`), storage and cache keys,
          asset paths (`Assets`), analytics/event names, platform channel names, environment
          variable names, and any meaningful repeated string or number (`AppConsts`).
          Where: `core/constants/`, one file per purpose (`api_keys.dart`, `endpoints.dart`,
          `assets.dart`, `app_consts.dart`, ...). If no file fits, create a new one there.
          Use `abstract final class` with `static const` members (ARCH-7).
          Reference constants everywhere: models, datasources, repositories, router, storage.
          User-facing text is NOT a constant: it goes to i18n (UI-4). Developer-only diagnostic
          text (exception or log messages) is not a key or a path and is not covered here.
          Before adding a constant, check `docs/CORE_MAP.md` and the existing files. Reuse, don't duplicate.
