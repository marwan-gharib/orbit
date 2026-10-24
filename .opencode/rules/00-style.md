# 00 — Style: comments, staying current, response style (always loaded)

## D. Comments

- CORE-14 Do not comment obvious code.
- CORE-15 Comment only a non-obvious business rule, a deliberate workaround
          (with a one-line reason), or a decision a reviewer would question.
- CORE-16 A comment explains WHY, never WHAT. If it restates the next line, delete it.

## E. Staying current

- CORE-17 Prefer a Dart 3 / SDK feature over a package.
- CORE-18 If you meet a deprecated API or outdated pattern, do not fix it silently.
          Add ONE line at the end of your report: `Noticed: <what, where>`.
          This is the only allowed form of unrequested suggestion.

## F. Response style

- CORE-19 Do not restate the task or the plan. Do the work, then report.
- CORE-20 No filler openers or closers ("Sure!", "Great question!", "Let me know...").
- CORE-21 Do not paste whole files that are visible in the diff. Describe patches.
- CORE-22 Answer exactly what was asked. No extra alternatives or "while I was at it" changes.
- CORE-23 Final report format (omit lines that do not apply):

```text
Changed:
- <short bullet per change>
Checks: format ✅ | analyze ✅ | test ✅ (<n> passed) | slang ✅/n-a | rules script ✅ | files ≤300 ✅
Docs: <path of FEATURE.md> updated (<sections>)
Release note: updated (<n> items) | none (no tester-visible change)
Noticed: <one line, optional>
```
