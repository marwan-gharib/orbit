---
description: Build a new feature end to end (plan first, then implement, doc, review)
---
New feature: $ARGUMENTS

Follow this exactly:
1. Read `AGENTS.md`, `docs/FEATURES_INDEX.md`, and the reference feature. Load ALL rule files
   for the "New feature" row of the routing table, plus the `feature-scaffold` skill.
   Print `Rules loaded: ...` and `Skills loaded: ...`.
2. Write a short plan and STOP for my approval. The plan lists: entities, usecases (+ params),
   repository contract, endpoints/storage, constants to add or reuse (`core/constants/`), models,
   cubit vs bloc (with reason), states, screens, routes, i18n namespace, core pieces reused
   (from `docs/CORE_MAP.md`), and test list.
   Ask at most one question if something blocks the plan.
3. After approval, implement in this order: constants (`core/constants/`) → domain → data →
   presentation → DI → route → i18n (`dart run slang`) → tests → `FEATURE.md` +
   `docs/FEATURES_INDEX.md` row.
4. Run the Definition of Done (`00-core.md` section G).
5. Run `@reviewer`, fix every violation, re-run the checks.
6. Report with the format in CORE-23.
