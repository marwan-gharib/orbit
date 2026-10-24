# Dependency Injection & Navigation

## Dependency injection

- DI-1  Before adding or changing any DI registration, read `lib/core/di/feature_module_registry.md` first.
- DI-2  `get_it` only. All registrations live in `core/di/`.
- DI-3  Lifetimes:
        - Cubit/Bloc → `registerFactory`.
        - Usecases, repositories, datasources → `registerLazySingleton`.
- DI-4  `getIt<T>()` may be called ONLY in: files under `core/di/`, and the route builder /
        `BlocProvider(create: ...)` in `core/router/`. Never inside a widget's `build`, a Cubit,
        a usecase, a repository, or a datasource. Everything else receives its dependencies
        through the constructor.
- DI-5  One injection file per feature: `core/di/<feature>_injection.dart`, called from the
        main injection container. Register in dependency order: datasource → repository →
        usecases → cubit.

## Navigation

- NAV-1  `go_router` only. No `Navigator.push` / `pop` / `showDialog`-based flows that
         bypass the router for screens.
- NAV-2  Routes are declared in `core/router/` through `AppRoute.create` (ANIM-7). Route names and
         paths are manual constants in `core/router/route_names.dart` and `route_paths.dart`
         (ARCH-10); typed routes need build_runner and are not allowed.
- NAV-3  A Cubit never navigates. It emits a state (e.g. `LoginSuccess`); a `BlocListener`
         in the widget reacts and calls `context.go` / `context.push` through the `BuildContext`
         extension. Use `listenWhen` so only the intended state triggers navigation.
- NAV-4  Pass only IDs and primitives between routes (path/query params). Never pass an
         entity, model, or view model as `extra`. The destination loads its own data.
- NAV-5  Guards and redirects live in `core/router/route_guards.dart`. A feature never
         re-implements a redirect or an auth check inline in a screen.
