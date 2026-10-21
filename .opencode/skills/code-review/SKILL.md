---
name: code-review
description: Perform a professional engineering review of a diff or file - correctness, architecture, error handling, security, performance, tests, readability - with severity-ranked findings and concrete fixes. Use when asked to review code, a PR, or a diff, or before merging a large change. Goes beyond rule compliance, which the reviewer agent covers.
metadata:
  opencode/slash: "true"
---

# Code Review

Difference from `/review` and `@reviewer`: those check rule compliance only. This skill
adds engineering judgment (bugs, design, risk). Use both on large changes.

## When to use
"Review this", a PR or diff before merge, a risky change, an unfamiliar area.

## Procedure

1. **Understand intent.** Read the task or PR description, then `FEATURE.md` for the feature.
   Get the change set: `git status`, `git diff` (include untracked files).
2. **Review in this order** (stop to flag blockers early):
   1. **Correctness:** logic errors, off-by-one, null handling, async races (state used after `await`),
      missing `isClosed` or `mounted` checks, wrong error mapping, edge cases (empty, huge, malformed, offline).
   2. **Core-first:** core widgets, animations, and responsive reused (BASE-1..6, WIDGET-1..6, RESP-1..6,
      ANIM-1..7); no file over 300 lines (FILE-1); run `bash .opencode/scripts/check_rules.sh`.
   3. **Architecture:** layer boundaries (use the `clean-architecture` verify commands), responsibilities (`solid-principles`), string literals used as keys, paths, or routes (ARCH-10).
   4. **Security:** secrets, tokens in logs, unvalidated input (see `security-review`).
   5. **Tests:** every new or changed behavior covered? Failure paths? Would the tests fail if the code were wrong?
   6. **Performance:** rebuild scope, work in `build()`, unbounded lists, repeated network calls (see `performance-audit`).
   7. **Readability:** names, size, duplication (see `clean-code`).
   8. **Docs and notes:** `FEATURE.md` matches the change; `testers_release_note.txt` is updated in tester language (NOTES-1..7).
3. **Verify claims.** Run `flutter analyze` and the affected tests instead of assuming.
4. **Report** in the format below.

## Severity
- **Blocker:** wrong behavior, data loss, crash, security hole, broken contract. Must fix.
- **Major:** likely bug later, missing tests for core behavior, boundary violation. Should fix.
- **Minor:** maintainability, naming, small duplication. Fix if cheap.
- **Nit:** taste. At most 3, and say they are optional.

## Output format
```text
Summary: <one sentence: what the change does and overall verdict>
Blockers:
- path/file.dart:LINE - problem - why it matters - suggested fix
Major:
- ...
Minor:
- ...
Nits (optional):
- ...
Tests: <what is covered, what is missing>
Verdict: APPROVE | APPROVE WITH CHANGES | REQUEST CHANGES
```

## Review etiquette
- Be specific: file, line, what is wrong, how to fix. No vague "this is bad".
- Explain the risk, not just the preference.
- Do not rewrite the code in the review. Do not edit files unless asked.
- If something is good and non-obvious, say so in one line.
- Never invent problems to fill sections. Empty sections say `none`.

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
