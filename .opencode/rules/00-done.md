# 00 — Definition of Done and self-review (always loaded)

## G. Definition of Done (all required, run in this order)

- CORE-24 `dart format <changed files>` — format only files you changed.
- CORE-25 `flutter analyze` — zero issues in changed files. Pre-existing issues in
          untouched files are reported, not fixed.
- CORE-26 `flutter test <affected path>` — all pass. New behavior has tests (TEST-1).
- CORE-27 `dart run slang` — if any `assets/i18n/*.json` changed.
- CORE-28 Feature docs updated (DOC-2), the `docs/FEATURES_INDEX.md` row is accurate, and
          `docs/CORE_MAP.md` is updated when `core/` changed (DOC-6).
- CORE-29 Rules scan: `bash .opencode/scripts/check_rules.sh` (it scans your changed files: file
          size FILE-1, constants ARCH-10, core-first BASE-3, motion ANIM-2, responsive RESP-2,
          layers, hardcoded text). Every hit is a lead: open the line, fix it or justify it.
          No bash available → run `wc -l` on every changed file and the greps listed in the script.
- CORE-30 Tester release note: update `testers_release_note.txt` per NOTES-1..7, or report
          `Release note: none (no tester-visible change)`.
- CORE-31 Self-review (section H) completed.
- CORE-32 Feature-level or multi-layer change → run `@reviewer`, fix every violation,
          then re-run steps 24–26 and 29.
- CORE-33 If a step cannot run, say exactly which and why. Never claim a check passed
          without running it.

## H. Self-review checklist (confirm every group that your diff touches)

- Any code        → H-1..H-16, CORE-7..CORE-16, BASE-1..BASE-6, FILE-1..FILE-4
- Any new file    → ARCH-1, ARCH-6..ARCH-10, FILE-2
- Domain          → DOM-1..DOM-6, ERR-1
- Data            → DATA-1..DATA-9, ERR-2
- State           → STATE-1..STATE-8, ERR-3, ERR-4
- UI              → UI-1..UI-9, WIDGET-1..WIDGET-6, RESP-1..RESP-6, ANIM-1..ANIM-7, STATE-3, STATE-5
- DI / routes     → DI-1..DI-5, NAV-1..NAV-5
- Tests           → TEST-1..TEST-8
- Docs            → DOC-1..DOC-7
- Release note    → NOTES-1..NOTES-7
- Protected files untouched: `pubspec.yaml`, `analysis_options.yaml`, generated files,
  `android/`, `ios/`, env files, and no new package.
