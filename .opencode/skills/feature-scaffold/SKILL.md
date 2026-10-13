---
name: feature-scaffold
description: Scaffold a new feature end to end in this project's architecture - entity, params, repository contract, usecase, model, mapper, datasource, repository impl, cubit with sealed states, screen, DI, route, i18n, tests, and FEATURE.md - in the correct order by mirroring the reference feature. Use when creating a new feature or adding a new vertical slice.
---

# Feature Scaffold

Creates a feature in the right order with the right shapes. The skeletons in
`templates.md` show **structure only**. Names and signatures of project types
(`ApiResult`, `UseCase`, `BaseApiClient`, `Failure`) MUST be copied from the reference
feature and `core/`, never invented (CORE-7).

## When to use
A new feature or screen group from scratch. For changes to an existing feature use the `/change` command instead.

## Procedure

1. **Prepare.** Read `AGENTS.md` (reference feature path), `docs/FEATURES_INDEX.md`,
   `docs/CORE_MAP.md`, and the reference feature's files. Load all rule files for "New feature".
2. **Plan, then wait for approval.** List: entities, usecases (+ params), contract, endpoints
   or storage, models, Cubit vs Bloc with reason (STATE-1), states, screens, routes, i18n
   namespace, core pieces reused, test list.
3. **Build in this order** (each step compiles before the next):
   1. `domain/entities/`
   2. `domain/params/` (only for usecases with more than one input)
   3. `domain/repositories/` contract
   4. `domain/usecases/`
   5. `data/models/` (hand-written `fromJson` / `toJson`, defensive parsing)
   6. `data/mappers/`
   7. `data/datasources/remote|local/` (concrete, through `BaseApiClient` and core storage abstractions)
   8. `data/repositories/*_repository_impl.dart`
   9. `presentation/cubits/<name>/` (cubit + sealed states)
   10. `presentation/view_models/` + `presentation/mappers/`
   11. `presentation/screens/` + `widgets/`
   12. `core/di/<feature>_injection.dart` and register it in the main container
   13. Routes in `core/router/` (manual constants)
   14. i18n keys in every `assets/i18n/*.json`, then `dart run slang`
   15. Tests per TEST-1 (use the `write-tests` skill)
   16. `FEATURE.md` + index row (use the `feature-doc` skill)
4. **Verify.** Run the Definition of Done (CORE-24..31) and the boundary checks from the
   `clean-architecture` skill. Run `@reviewer`.

## File naming
`snake_case.dart`. Suffixes: `_entity`, `_params`, `_repository`, `_repository_impl`,
`_usecase`, `_model`, `_mapper`, `_remote_data_source`, `_local_data_source`, `_cubit`,
`_state`, `_screen`, `_view_model`, `_injection`.

## Checklist before reporting done
- [ ] Every file sits in the folder required by `architecture.md`.
- [ ] No `package:flutter` in domain. No `dio` outside core/network. No `getIt` outside DI/route builders.
- [ ] Every state has loading, success, empty, error (STATE-5).
- [ ] No hardcoded strings or colors in widgets.
- [ ] Tests exist for domain, data, cubit, and each screen.
- [ ] `FEATURE.md` is created and the index row added.

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
