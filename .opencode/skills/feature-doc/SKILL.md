---
name: feature-doc
description: Create, update, or repair a feature's FEATURE.md (the token-saving documentation of one feature) and its row in docs/FEATURES_INDEX.md. Use when creating a feature, after ANY change to a feature, when FEATURE.md is missing or outdated, or before reading a feature's source to understand it.
---

# Feature Doc (`FEATURE.md`)

Every feature has `lib/features/<feature>/FEATURE.md`. It lets the agent understand the
feature from about 100 lines instead of scanning its folder. Stale docs are worse than
none, so updating it is part of finishing any change (DOC-2).

Template: `.opencode/templates/FEATURE.template.md`. Rules: `.opencode/rules/feature-docs.md` (DOC-1..6).
Sections in the template: 1 Purpose, 2 Screens & routes, 3 File map, 4 Entities & models,
5 Use cases, 6 API & storage, 7 State, 8 Dependencies, 9 Localization, 10 Business rules,
11 Tests, 12 Known issues, 13 Changelog.

## When to use
- **Read mode:** starting any task on a feature. Read `docs/FEATURES_INDEX.md`, then this file, then only the source files you need.
- **Create mode:** new feature, or a feature with no `FEATURE.md`.
- **Update mode:** after any change to the feature.
- **Repair mode:** doc and code disagree. The code is the truth.

## Which section does my change touch?

| You changed | Update section |
|---|---|
| Added, removed, or renamed a file, or a new feature-only widget (name + one line) | 3 File map |
| Entity or model fields | 4 |
| Usecase or params | 5 |
| Endpoint, storage key, cache policy | 6 |
| Cubit/Bloc, states, transitions, pagination | 7 |
| Dependency on core or another feature | 8 (and the other feature's doc) |
| i18n keys | 9 |
| A business rule or edge case | 10 |
| Tests added or removed | 11 |
| Found a bug you did not fix | 12 |
| Anything at all | 13 Changelog + `Last verified` date |

## Procedure

1. **Gather facts from code, not memory.** Useful commands:
   ```bash
   find lib/features/<f> -name "*.dart" | sort                      # file map
   grep -rn "class .*UseCase" lib/features/<f>/domain               # usecases
   grep -rn "extends Cubit\|extends Bloc" lib/features/<f>          # state mgmt
   grep -n "<f>" lib/core/router/*.dart lib/core/di/*.dart          # routes and DI
   grep -rn "<f>:" assets/i18n/*.json | head                        # i18n namespace
   find test/features/<f> -name "*_test.dart" | sort                # tests
   ```
2. **Fill or edit only the affected sections.** Keep the whole file at 150 lines or fewer.
   No code dumps, no copied implementation. Describe and point to paths.
3. **Explain WHY only for non-obvious business rules.** Skip the obvious.
4. **Dependencies both ways.** If feature A uses feature B, record it in A's "Depends on" and B's "Used by".
5. **Changelog line:** `YYYY-MM-DD - what and why` (max two lines). Set `Last verified` to today.
6. **Index row** in `docs/FEATURES_INDEX.md`:
   `| feature | one-line purpose | path to FEATURE.md | routes | depends on |`
7. **Verify** with the bundled script:
   ```bash
   bash .opencode/skills/feature-doc/scripts/check_feature_doc.sh lib/features/<f>
   ```
   It checks that the file exists, stays at 150 lines or fewer, has `Last verified`, has all
   13 sections, and that every `.dart` path mentioned exists. Fix everything it reports.

## Quality bar
- Someone new to the feature can answer "what does it do, where is X, what does it depend on?" without opening code.
- Every path in the doc exists. Every table row is current.
- Endpoints and keys are listed by constant name (`Endpoints.product`), never as raw strings.
- No filler. Empty sections say `none`, not `TBD`.

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
