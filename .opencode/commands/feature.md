---
description: Build a new feature end to end (core check, plan, implement, doc, release note, review)
---
New feature: $ARGUMENTS

Follow this exactly:
1. Read `AGENTS.md`, `docs/FEATURES_INDEX.md`, `docs/CORE_MAP.md`, and the reference feature. Load ALL
   rule files for the "New feature" row of the routing table, plus the skills `feature-scaffold`,
   `ui-from-core`, `clean-code`. Print `Rules loaded:`, `Skills loaded:`, and `Core reuse: ... | Core gap: ...` (CORE-5).
2. Write a short plan and STOP for my approval. The plan lists: entities, usecases (+ params),
   repository contract, endpoints/storage, constants to add or reuse (`core/constants/`), models,
   cubit vs bloc (with reason), states, screens, routes, i18n namespace, the core pieces reused
   (widgets, animations, responsive: BASE-1), any widget core lacks (built in the feature, WIDGET-2),
   the planned file split so no file passes 300 lines (FILE-1), and the test list.
   Ask at most one question if something blocks the plan.
3. After approval, implement in this order: constants → domain → data → presentation → DI → route →
   i18n (`dart run slang`) → tests → `FEATURE.md` + `docs/FEATURES_INDEX.md` row → `testers_release_note.txt`.
4. Run the Definition of Done (`00-done.md` section G), including the rules script.
5. Run `@reviewer`, fix every violation, re-run the checks.
6. Report with the format in CORE-23.
