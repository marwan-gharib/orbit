---
name: refactoring
description: Safely restructure existing Dart/Flutter code without changing behavior - characterization tests first, small verified steps, a catalog of Flutter-specific refactorings. Use ONLY when the user explicitly asks to refactor, restructure, split, or simplify existing code.
---

# Refactoring

Refactoring changes structure, never behavior. This skill applies **only on explicit request**.
Without a request, the rule is no drive-by refactoring (CORE-8). Renaming, moving, or
deleting files needs explicit instruction (CORE-9).

## When to use
"Refactor X", "split this class", "this widget is too big", "clean up this feature".

## Procedure

1. **Define the goal and boundary.** What smell are we fixing, which files are in scope? Anything outside stays untouched.
2. **Propose the plan and wait for approval** when it involves renames, moves, deletes, or more than 3 files. List each step and each file path.
3. **Get a safety net.** Run the existing tests for the area. If behavior is not covered, write
   characterization tests that pin current behavior before changing anything (use `write-tests`). Commit nothing unless asked.
4. **Work in small steps.** After each step: `dart format` on changed files, `flutter analyze`,
   affected tests. All green before the next step. If red, undo the step, do not push through.
5. **Never mix** a refactor with a behavior change or bug fix. If you find a bug, report it and fix it separately (use `debugging`).
6. **Update docs.** `FEATURE.md` file map and changelog (DOC-2). Update `docs/CORE_MAP.md` if `core/` changed (DOC-6).
7. **Verify.** Definition of Done, then `@reviewer`.

## Catalog (Flutter / Dart)

| Smell | Refactoring |
|---|---|
| File over 300 lines (FILE-1, FILE-2) | Split by concern: one public widget per file, models/mappers/states/helpers in their own files, update imports, behavior unchanged |
| A feature widget needed by a 2nd feature | Promote to `core/widgets/` and generalize (WIDGET-3, `/promote-widget`) |
| Custom animation or raw `Animated*` in a feature | Replace with the core animation facade or widgets (ANIM-1, ANIM-2) |
| Bare numeric sizes | Theme tokens or `Responsive` (RESP-2) |
| Huge `build()` | Extract widget classes (not helper methods) with `const` constructors (UI-8) |
| Long function | Extract function by intent; one level of abstraction |
| Several positional primitives | Introduce a `Params` object (DOM-3) |
| Repeated `switch` on a type | Replace with a `sealed` hierarchy or strategy (see `solid-principles`) |
| Business logic in a widget or Cubit | Move to a usecase (ARCH-2, STATE-2) |
| Inline JSON or entity conversion | Move it into the model's `toEntity()` or a presentation mapper (DATA-5) |
| God Cubit with unrelated state | Split into focused Cubits per concern, each at route level |
| Duplicated code in 2+ features | Move to `core/` after checking `docs/CORE_MAP.md` (ARCH-4) |
| Boolean flag params | Split into two named functions |
| Deep nesting | Guard clauses, `switch` expressions |
| Hardcoded strings or colors | Move to i18n and theme extension (UI-1, UI-4) |
| String literal as a key, path, route, or asset | Move to `core/constants/` (ARCH-10) |

## Stop conditions
Stop and ask if: tests cannot be made green after a step, the scope keeps growing, a public
contract used by other features would change, or behavior is unclear and untestable.

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
