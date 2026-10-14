---
name: debugging
description: Systematically find the root cause of a bug or crash in a Flutter app - reproduce, isolate, hypothesize, verify, fix, and add a regression test - including common Flutter and Bloc bug classes. Use when something crashes, behaves wrongly, does not update, rebuilds too much, or a test fails unexpectedly.
---

# Debugging

Principle: find the cause, then change code. Guessing and trying edits wastes time and adds new bugs.

## When to use
Crashes, exceptions, wrong UI, state not updating, flaky or failing tests, "it works on my device".

## Procedure

1. **Reproduce.** Get exact steps, input, device or locale, and the actual vs expected result.
   If you cannot reproduce it, write down what is missing and ask ONE question.
2. **Read the evidence.** Full stack trace (first frame in `lib/` is usually the lead), logs,
   the failing test output. Do not skim.
3. **Isolate.** Narrow to one layer: UI, Cubit, usecase, repository, datasource, API payload.
   Bisect: which layer receives correct input and returns wrong output?
4. **Hypothesize.** Write 1 to 3 candidate causes. Rank by likelihood. Each must be falsifiable.
5. **Test each hypothesis** with the cheapest probe: a unit test, `debugPrint`, a breakpoint,
   `flutter test --plain-name "<name>"`, DevTools. Remove temporary probes afterward.
6. **State the root cause in one line before editing.**
7. **Write a failing regression test** (TEST-2), then apply the smallest fix, then confirm it passes.
8. **Check for siblings.** The same mistake may exist in similar code. Report it as `Noticed:`, do not fix it unasked.
9. **Update `FEATURE.md`** (business rules or known issues) when the cause was a non-obvious rule.

## Common Flutter and Bloc bug classes

| Symptom | Likely cause |
|---|---|
| "emit after close" / setState after dispose | Missing `isClosed` check after `await`, or an uncancelled subscription or timer (STATE-6) |
| `BuildContext` used across async gap | Missing `context.mounted` check (UI-9) |
| UI does not update after state change | State not a new instance, mutated list inside the same state, equality makes states equal (ARCH-9, STATE-8) |
| UI rebuilds too often or loops | Creating objects or Cubits inside `build()`, `BlocBuilder` with no `buildWhen`, emitting in a listener that retriggers itself |
| Null or type error from the API | Unvalidated payload (DATA-3), server contract changed, model parses optional as required |
| Works first time, breaks on revisit | Cubit registered as singleton, or state held in a shared instance (DI-3) |
| Overflow stripes | Fixed sizes, long text, large font scale or RTL (UI-6) |
| Wrong text direction or misplaced icons | `left`/`right` instead of directional APIs (UI-5) |
| Flaky test | Real time, real async race, shared mutable state between tests, missing `await` |
| 401 loops or logout surprises | Interceptor refresh logic, race between parallel requests (ERR-5) |
| Stale data shown | Cache policy in repository (DATA-8), missing invalidation |

## Anti-patterns
- Shotgun edits: changing several things and keeping the one that "worked".
- Fixing the symptom: catching the exception or adding a null check without knowing why it is null.
- Leaving `print` / `debugPrint` probes in the final diff.
- "Fixing" by deleting or loosening a test.

## Output
Report: root cause (one line), the fix (short), the regression test name, and any `Noticed:` line.

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
