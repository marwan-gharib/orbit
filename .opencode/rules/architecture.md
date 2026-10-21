# Architecture

Folder tree: `folder-structure.md`. Constants rule (ARCH-10): `constants.md`.

- ARCH-1  Layer flow is one-directional and never bypassed: Presentation → Domain → Data.

  | Layer        | Allowed                                    | Forbidden                              |
  |--------------|--------------------------------------------|----------------------------------------|
  | Presentation | Widgets, Cubit/Bloc, UI state, view models | Business logic, direct API/DB calls    |
  | Domain       | Usecases, entities, params, repo contracts | Any `package:flutter/...` import       |
  | Data         | API/DB calls, models, repo implementations | `BuildContext`, UI logic               |

  A feature may use another feature only through `core/` or through a domain
  usecase exposed for that purpose. It never imports another feature's data or presentation layer
  (a widget two features need is promoted to `core/widgets/`, WIDGET-3).

- ARCH-2  Business logic never lives in `initState`, `build()`, or a widget callback.
          Widgets call a Cubit method; the Cubit calls a usecase.
- ARCH-3  Domain entities are never used directly in widgets. Map them to a view model
          (`presentation/view_models/`, plain immutable Dart class) with a mapper in
          `presentation/mappers/`.
- ARCH-4  Code needed by 2+ features belongs in `core/`. A piece first needed by one feature
          lives in that feature; the moment a second feature needs it, promote it to `core/`
          (WIDGET-3 steps for widgets, the same steps for other code). Before writing anything
          that looks reusable, read `docs/CORE_MAP.md` and search `core/` (BASE-1). Reuse, never
          duplicate.
- ARCH-5  Everything in `core/` is built on an abstraction (api client, secure storage, cache
          storage, logger, analytics...). Only the implementation inside `core/network/` and its
          interceptors may import `dio` (plus the `Dio` error classifier in `core/errors/`).
          Every other package (shared_preferences, flutter_secure_storage, lottie, a scaling
          package...) is imported by its single implementation class only, and `HapticFeedback`
          is called only by `AppHaptics`. Each implementation owns its error handling so no
          caller can forget it.
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
