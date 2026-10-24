---
name: clean-architecture
description: Decide where code belongs and verify layer boundaries in this feature-first Clean Architecture (presentation, domain, data, core). Use when placing new code, creating a feature, reviewing dependencies between layers, or fixing a layering violation such as a Cubit calling a repository or an entity in a widget.
---

# Clean Architecture (feature-first)

The dependency rule: source code dependencies point inward only.
**Presentation -> Domain <- Data**, and `core/` serves all of them. Domain depends on nothing
but Dart. Full rules: `.opencode/rules/architecture.md` (ARCH-1..9). This skill is the
decision and verification procedure.

## When to use
Placing new code; creating a feature; reviewing imports; fixing a boundary violation; planning a refactor.

## Where does it go? (decision table)

| I need to... | Put it in |
|---|---|
| Represent a business concept | `domain/entities/` (pure Dart) |
| Express one business operation | `domain/usecases/` (plain class with `call()`, no base class; + `domain/params/` if more than one input) |
| Describe what data I need | `domain/repositories/` (abstract contract) |
| Parse or serialize JSON / DB rows, and convert to an entity | `data/models/` (hand-written `fromJson` / `toJson` / `toEntity()`, keys from `ApiKeys`) |
| Call the API or local storage | `data/datasources/remote/` or `local/` (concrete, via core abstractions) |
| Orchestrate sources, cache, map errors | `data/repositories/*RepositoryImpl` |
| Convert entity -> UI shape | `presentation/view_models/` + `presentation/mappers/` |
| Hold screen state | `presentation/cubits/<name>/` (cubit + sealed state) |
| Draw UI | `presentation/screens/`, `presentation/widgets/` |
| Reuse across 2+ features | `core/` (check `docs/CORE_MAP.md` first); a feature widget a 2nd feature needs is promoted to `core/widgets/` (WIDGET-3) |
| A widget core does not have | `features/<feature>/presentation/widgets/` (WIDGET-2), built from core pieces |
| Motion, loading placeholder, overlay | only `core/animations/` pieces (ANIM-1..3), never in a feature |
| A size, breakpoint, or scale | theme tokens or `core/responsive/` (RESP-2) |
| Name a key, endpoint, route, storage key, asset, or env variable | `core/constants/<purpose>.dart` (ARCH-10) |
| Wire dependencies | `core/di/<feature>_injection.dart` |
| Declare routes | `core/router/` (`AppRoute.create`; names and paths in `route_names.dart` and `route_paths.dart`) |

## Data flow for one request
Widget event -> Cubit method -> UseCase -> Repository contract -> RepositoryImpl ->
Datasource -> `BaseApiClient`. The result returns as `ApiResult<Entity>` -> Cubit maps it to
a sealed state -> Widget switches on the state, using view models.

## Typical violations and fixes

| Violation | Fix |
|---|---|
| Cubit calls a repository or datasource | Create a usecase and inject it (STATE-2) |
| Entity has `fromJson` or a Flutter import | Move JSON to a model, move the type to presentation (DOM-6) |
| Model or entity used directly in a widget | Map to a view model (ARCH-3) |
| Business rule inside `build()` or a callback | Move to a usecase (ARCH-2) |
| Usecase formats text for the UI | Return data. Format in the view model or presentation (DOM-6) |
| `RepositoryImpl` returns a model | Map to an entity first (DATA-5) |
| Feature A imports feature B's `data/` or `presentation/` | Move shared code to `core/`, or expose a domain usecase (ARCH-1) |
| Datasource imports `dio` | Go through `BaseApiClient` (DATA-1) |
| Cubit navigates or holds `BuildContext` | Emit a state, navigate in `BlocListener` (NAV-3, STATE-7) |
| String literal used as a key, endpoint, route, storage key, or asset path | Move it to `core/constants/` (ARCH-10) |
| Usecase extends or implements a base class | Make it a plain class with `call()` (DOM-1) |

## Verify (run from the project root)

```bash
# Domain must not import Flutter
grep -rn "package:flutter" lib/features/*/domain && echo "VIOLATION" || echo "domain ok"
# Presentation must not import data layer
grep -rEn "/data/" lib/features/*/presentation && echo "VIOLATION" || echo "presentation ok"
# Only the API client implementation may import dio
grep -rn "package:dio" lib --include=*.dart | grep -vE "lib/core/(network|errors)" && echo "VIOLATION" || echo "dio ok"
# No literal JSON keys or endpoint paths outside core/constants (ARCH-10)
grep -rnE "json\[['\"]" lib --include=*.dart | grep -v "lib/core/constants" && echo "VIOLATION" || echo "json keys ok"
grep -rnE "\.(get|post|put|patch|delete)\(\s*['\"]" lib --include=*.dart | grep -v "lib/core/constants" && echo "VIOLATION" || echo "endpoints ok"
# Rules script: file size, constants, raw widgets, raw animation, bare sizes, layers
bash .opencode/scripts/check_rules.sh
# Cubits must not import repositories or datasources
grep -rEn "(repositories|datasources)/" lib/features/*/presentation/cubits && echo "VIOLATION" || echo "cubits ok"
```

A grep hit is a lead, not proof. Open the file and confirm before fixing.

## Process for a new feature
1. Read the reference feature (see `AGENTS.md`) and mirror it.
2. Design inside-out: constants -> entities -> contract -> usecases -> models (with `toEntity()`) -> datasource -> repo impl -> cubit/states -> view models -> screens -> DI -> routes.
3. Run the verify commands. Fix findings.
4. Record the file map and dependencies in `FEATURE.md` (use the `feature-doc` skill).

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
