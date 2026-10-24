# Feature Docs (token-saving memory)

Every feature has one `FEATURE.md` at `lib/features/<feature>/FEATURE.md`.
`docs/FEATURES_INDEX.md` lists all features. `docs/CORE_MAP.md` lists reusable core pieces.
Template: `.opencode/templates/FEATURE.template.md`.

Purpose: the agent learns what a feature does, where everything is, and how it connects by
reading ~100 lines instead of scanning dozens of files.

- DOC-1  Reading order for any feature task: `docs/FEATURES_INDEX.md` → the feature's
         `FEATURE.md` → only the source files you will edit or need to verify.
         Do not scan a whole feature folder when `FEATURE.md` already answers the question.
         If code and doc disagree, the code is right: fix the doc in the same task.
- DOC-2  After ANY change to a feature, update its `FEATURE.md` in the same task. A change
         is not done until the doc matches. Update only the affected sections, set
         `Last verified` to today's date, and add one changelog line
         (`YYYY-MM-DD — what and why`, max two lines). Triggers: files added/removed/renamed,
         endpoints, models/entities, states or transitions, routes, DI, i18n keys,
         business rules, dependencies, tests, known issues.
- DOC-3  New feature: create `FEATURE.md` from the template AND add its row to
         `docs/FEATURES_INDEX.md` before reporting done.
- DOC-4  Missing `FEATURE.md` for an existing feature: create it from the code once (use the
         `/doc-sync` flow), then continue the task. Do not skip it.
- DOC-5  Keep it small and factual: target 150 lines or fewer, no code dumps, no copied
         implementation. Describe and point to file paths. Explain WHY only for non-obvious
         business rules.
- DOC-6  Changes inside `core/` that add, remove, or change a reusable piece update
         `docs/CORE_MAP.md`. Cross-feature dependencies are recorded in BOTH features'
         `FEATURE.md` (Depends on / Used by).

- DOC-7  Docs obey FILE-1 too: `FEATURE.md` stays at 150 lines or fewer (DOC-5); `docs/CORE_MAP.md`,
         `docs/FEATURES_INDEX.md`, and any README stay at 300 or fewer. When one nears the limit,
         split it by area (e.g. `docs/core-map/<area>.md`) and keep the original file as the index.
         Feature-only widgets are listed in `FEATURE.md` section 3 (WIDGET-2); a promoted widget moves
         to `docs/CORE_MAP.md` (WIDGET-3).

## Index row format (`docs/FEATURES_INDEX.md`)

`| <feature> | <one-line purpose> | <path to FEATURE.md> | <routes> | <depends on> |`
