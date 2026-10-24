---
description: Create or repair a feature's FEATURE.md from its code, and update the features index
---
Feature: $ARGUMENTS

Docs-only task. Do not change any code.
1. Read `.opencode/rules/feature-docs.md` and `.opencode/templates/FEATURE.template.md`.
2. Read `docs/FEATURES_INDEX.md` and the existing `lib/features/$ARGUMENTS/FEATURE.md` if present.
3. Read the feature's source (domain, data, presentation), its DI file in `core/di/`, its routes in
   `core/router/`, its i18n keys, and its tests. Use the code as the source of truth.
4. Create or update `FEATURE.md` following the template. Keep it at 150 lines or fewer, no code dumps.
   List the feature's own widgets in section 3. Fill `Depends on` / `Used by` by checking imports and
   route usage (include `core/widgets`, `core/animations`, `core/responsive` when used). Set `Last verified` to today.
5. Add or correct this feature's row in `docs/FEATURES_INDEX.md`.
6. If `core/` pieces are used that are missing from `docs/CORE_MAP.md`, add them.
7. Report: sections created/changed, plus any code-vs-rules violations found under `Noticed:` (do not fix them).
