# Skeletons index (structure only)

Replace `Product` with the real name. Anything marked `// ADAPT` must be copied from the reference
feature or `core/` (CORE-7). Equality follows ARCH-9 (`Equatable` only if already in `pubspec.yaml`).
Every key, path, route, and asset is a constant (ARCH-10). Each skeleton file stays under 300 lines (FILE-1).

| File | Contains |
|---|---|
| `templates-domain.md` | constants, route files, entity, repository contract, usecases, params |
| `templates-data.md` | model with `toEntity()`, remote datasource, repository impl |
| `templates-presentation.md` | view model + mapper, sealed states, cubit |
| `templates-ui.md` | screen built from core widgets, animations, responsive, i18n; a feature-only widget |
| `templates-wiring.md` | route with `AppRoute.create`, DI module |

Tests: see the `write-tests` skill (usecase, repository, cubit, and widget tests with `ResponsiveScope`).
