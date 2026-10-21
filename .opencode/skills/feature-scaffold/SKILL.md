---
name: feature-scaffold
description: Scaffold a new feature end to end in this project's architecture - constants, entity, params, repository contract, usecase, model with toEntity, datasource, repository impl, cubit with sealed states, view model, screen, DI, route, i18n, tests, and FEATURE.md - in the correct order by mirroring the reference feature. Use when creating a new feature or adding a new vertical slice.
---

# Feature Scaffold

Creates a feature in the right order with the right shapes. The skeletons in
`templates*.md` files (index in `templates.md`) show **structure only**. Names and signatures of project types
(`ApiResult`, `BaseApiClient`, `Failure`) MUST be copied from the reference feature and
`core/`, never invented (CORE-7).

## When to use
A new feature or screen group from scratch. For changes to an existing feature use the `/change` command instead.

## Procedure

1. **Prepare.** Read `AGENTS.md` (reference feature path), `docs/FEATURES_INDEX.md`,
   `docs/CORE_MAP.md`, and the reference feature's files. Load all rule files for "New feature"
   and the `ui-from-core` skill.
2. **Plan, then wait for approval.** List: entities, usecases (+ params), contract, endpoints
   or storage, constants to add or reuse, models, Cubit vs Bloc with reason (STATE-1), states,
   screens, routes, i18n namespace, core pieces reused (BASE-1), missing widgets, file split
   (FILE-1), test list.
3. **Build in this order** (each step compiles before the next):
   1. `core/constants/`: add or reuse every key, endpoint, route, and asset the feature needs
      (ARCH-10). No string literal as a key or path may appear in any later step.
   2. `domain/entities/`
   3. `domain/params/` (only for usecases with more than one input)
   4. `domain/repositories/` contract
   5. `domain/usecases/` (plain classes with a `call(...)` method, no base class, DOM-1)
   6. `data/models/` (hand-written `fromJson` / `toJson` / `toEntity()`, defensive parsing, keys from `ApiKeys`)
   7. `data/datasources/remote|local/` (concrete, through `BaseApiClient` and core storage abstractions, paths from `Endpoints`)
   8. `data/repositories/*_repository_impl.dart` (convert with `model.toEntity()`)
   9. `presentation/cubits/<name>/` (cubit + sealed states)
   10. `presentation/view_models/` + `presentation/mappers/` (entity to view model)
   11. `presentation/screens/` + `widgets/`: core widgets first, core animations only, every size
       through tokens or `Responsive`, a missing widget built in the feature (`ui-from-core` skill)
   12. `core/di/<feature>_injection.dart` and register it in the main container (read
       `lib/core/di/feature_module_registry.md` first, DI-1)
   13. Routes in `core/router/` through `AppRoute.create`, names and paths from `route_names.dart` and `route_paths.dart`
   14. i18n keys in every `assets/i18n/*.json`, then `dart run slang`
   15. Tests per TEST-1 (use the `write-tests` skill)
   16. `FEATURE.md` + index row (use the `feature-doc` skill)
   17. `testers_release_note.txt` (use the `tester-release-notes` skill)
4. **Verify.** Run the Definition of Done (CORE-24..33) and the boundary checks from the
   `clean-architecture` skill. Run `@reviewer`.

## File naming
`snake_case.dart`. Suffixes: `_entity`, `_params`, `_repository`, `_repository_impl`,
`_usecase`, `_model`, `_mapper` (presentation only), `_remote_data_source`,
`_local_data_source`, `_cubit`, `_state`, `_screen`, `_view_model`, `_injection`.
Constants files are named by purpose: `api_keys.dart`, `endpoints.dart`, `assets.dart` (route names and paths: `route_names.dart`, `route_paths.dart`).

## Checklist before reporting done
- [ ] Every file sits in the folder required by `architecture.md`.
- [ ] No string literal for a key, path, route, or asset outside `core/constants/` (ARCH-10).
- [ ] No base usecase class. No `package:flutter` in domain. No `dio` outside core/network. No `getIt` outside DI/route builders.
- [ ] Every list screen has loading, success, empty, error; every detail screen has loading, success, error (STATE-5).
- [ ] No hardcoded strings or colors in widgets; no bare sizes; no raw animation APIs (UI-1, UI-4, RESP-2, ANIM-2).
- [ ] Core widgets used wherever one exists; feature-only widgets listed in `FEATURE.md` section 3 (WIDGET-1, 2).
- [ ] No file over 300 lines (FILE-1).
- [ ] Tests exist for domain, data, cubit, and each screen.
- [ ] `FEATURE.md` is created and the index row added.
- [ ] `testers_release_note.txt` has an item for every new screen or flow (NOTES-1).

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
