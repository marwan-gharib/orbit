---
name: clean-code
description: Apply pragmatic clean-code judgment to new or changed Dart/Flutter code - intent-revealing names, small focused functions, shallow nesting, no magic values, no dead code, Dart 3 idioms. Use when writing or editing code, or when asked to clean up, simplify, or improve readability. Covers what the linter cannot check.
---

# Clean Code (Dart / Flutter)

Scope: code you write or change in this task only (CORE-8). Never reformat, rename, or
restructure untouched code. Anything `flutter analyze` already enforces (casing, `const`,
import order, `print`) is out of scope here.

## When to use
Writing or editing any code; "clean this up"; "simplify"; "make it readable"; before self-review.

## The checklist

1. **Names reveal intent.**
   - Say what it is or does, not how: `activeSubscriptions`, not `list2`.
   - Booleans read as questions: `isLoading`, `hasMore`, `canSubmit`.
   - Ban vague names: `data`, `info`, `temp`, `manager`, `helper`, `util`, `handle`.
   - One word per concept across the codebase (do not mix `fetch` / `get` / `load` for the same idea).
   - Name length grows with scope: short in a 3-line closure, descriptive for a public member.
2. **Functions do one thing at one level of abstraction.**
   - Aim for about 20 lines or fewer. If you need a comment to label a block, extract it.
   - Three or more parameters, or two or more primitives of the same type: use named
     parameters or a `Params` object (DOM-3).
   - No boolean flag parameters that switch behavior. Split into two functions.
   - A function either changes state or returns a value, not both.
3. **Flat control flow.**
   - Guard clauses and early `return` instead of nested `if`/`else`.
   - Maximum two nesting levels. Beyond that, extract or use a `switch` expression.
4. **No duplication, no premature abstraction.**
   - Extract on the third occurrence. A wrong abstraction costs more than duplication.
   - Reusable across features: move to `core/` (ARCH-4, WIDGET-3 for widgets). Check `docs/CORE_MAP.md` first (BASE-1).
5. **No magic values.** Every key, path, route, asset, and meaningful repeated number or string
   becomes a constant in `core/constants/` (ARCH-10). No exceptions: never a literal at the
   usage, never a private `const` next to it. User-facing strings go to i18n (UI-4). UI sizes are
   not constants files: they are theme tokens or `Responsive` (RESP-2); durations and curves come
   from the animation tokens (ANIM-1).
6. **No dead code.** Delete it, never comment it out. No unused parameters, imports, or fields.
7. **Comments** follow CORE-14..16: explain why, never what.
8. **Nulls and errors.**
   - Avoid `!`. Model absence explicitly or check first.
   - Never swallow exceptions with an empty `catch`. Failures become `ApiResult` (ERR-2).
9. **Immutability.** `final` fields, `const` constructors, no mutation of parameters, no
   hidden shared mutable state (ARCH-9).
10. **Dart 3 idioms.** `switch` expressions, pattern matching, records for small ad-hoc
    tuples (at most 3 fields, else a class), collection `if`/`for`/spread, `sealed` for
    closed hierarchies, extensions for small helpers.
11. **Keep files under 300 lines (FILE-1).** One public widget or class per file; extract helpers,
    private widgets, and mappers into their own files before a file grows past the limit.
12. **Small, cohesive classes.** No god Cubit, no god widget. Avoid train wrecks like
    `a.b.c.d.value`; expose what callers need.

## Before / after

```dart
// Before: nested, flag param, vague name
Widget build(bool flag, List<int>? d) {
  if (d != null) {
    if (d.isNotEmpty) {
      if (flag) { /* ... */ }
    }
  }
}

// After: guard clauses, named intent, split by behavior
Widget buildOrdersList(List<OrderViewModel> orders) {
  if (orders.isEmpty) return const EmptyOrders();
  return OrdersListView(orders: orders);
}
```

## Process
1. Write the code to work.
2. Read your own diff as if reviewing someone else's. Walk the checklist.
3. Fix only what you touched. If you notice problems elsewhere, report one `Noticed:` line (CORE-18).

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
