# 00 — Core Rules (always loaded)

Rule IDs are stable. Cite them (e.g. `ARCH-3`) when explaining a decision or
flagging a conflict.

## A. Task start protocol (mandatory, in this order)

- CORE-1  Classify the task with the routing table in `AGENTS.md`.
- CORE-2  Read `docs/FEATURES_INDEX.md`, then the target feature's `FEATURE.md`.
          Read source files only after that, and only the ones you need.
- CORE-3  Read every rule file the routing table requires. Never work from memory.
- CORE-4  When creating anything new, read the reference feature and mirror it.
- CORE-5  Print one line before the first edit: `Rules loaded: <file names>`.
          Several task types apply → load the union.

## B. Working agreement

- CORE-6  Ambiguity that blocks correct work → ask ONE focused question before
          coding. Ambiguity that does not block → choose the conservative option
          and state it as a single `Assumption:` line. No assumptions → print nothing.
- CORE-7  Never guess a file path, class name, or API. Search or ask.
- CORE-8  Smallest change that solves the problem. No drive-by refactor, rename,
          or reformat of untouched code.
- CORE-9  Never rename, move, or delete files without explicit instruction.
- CORE-10 Never modify `pubspec.yaml`, `analysis_options.yaml`, generated files,
          `android/`, `ios/`, or env files without explicit approval. A new package
          is never added; propose it and wait.
- CORE-11 If a request conflicts with a rule, name the rule ID and ask. Do not
          silently override it and do not silently comply.
- CORE-12 Legacy code that violates these rules: follow the rules in new and
          changed code only, leave the rest alone, report it under `Noticed:`.
- CORE-13 No `git commit` / `git push` unless explicitly asked.

## C. Workflow per change

1. Task start protocol (section A).
2. Read the code you will touch.
3. Apply the smallest correct change, layer by layer in this order:
   domain → data → presentation → DI → route → i18n → tests → docs.
4. Run the Definition of Done (section G).
5. Run the self-review checklist (section H).
6. Report using the format in section F.

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
- CORE-23 Final report format (omit empty lines):

```text
Changed:
- <short bullet per change>
Checks: format ✅ | analyze ✅ | test ✅ (<n> passed) | slang ✅/n-a
Docs: <path of FEATURE.md> updated (<sections>)
Noticed: <one line, optional>
```

## G. Definition of Done (all required, run in this order)

- CORE-24 `dart format <changed files>` — format only files you changed.
- CORE-25 `flutter analyze` — zero issues in changed files. Pre-existing issues in
          untouched files are reported, not fixed.
- CORE-26 `flutter test <affected path>` — all pass. New behavior has tests (TEST-1).
- CORE-27 `dart run slang` — if any `assets/i18n/*.json` changed.
- CORE-28 Feature docs updated (DOC-2) and `docs/FEATURES_INDEX.md` row accurate.
- CORE-29 Self-review (section H) completed.
- CORE-30 Feature-level or multi-layer change → run `@reviewer`, fix every violation,
          re-run steps 24–26.
- CORE-31 If a step cannot run, say exactly which and why. Never claim a check passed
          without running it.

## H. Self-review checklist (confirm every group that your diff touches)

- Any code        → H-1..H-9, CORE-7..CORE-16
- Any new file    → ARCH-1, ARCH-6, ARCH-7, ARCH-8, ARCH-9
- Domain          → DOM-1..DOM-6, ERR-1
- Data            → DATA-1..DATA-9, ERR-2
- State           → STATE-1..STATE-8, ERR-3, ERR-4
- UI              → UI-1..UI-9, STATE-3, STATE-5
- DI / routes     → DI-1..DI-4, NAV-1..NAV-4
- Tests           → TEST-1..TEST-6
- Docs            → DOC-1..DOC-6
- Protected files untouched: `pubspec.yaml`, `analysis_options.yaml`, generated files,
  `android/`, `ios/`, env files, and no new package.
