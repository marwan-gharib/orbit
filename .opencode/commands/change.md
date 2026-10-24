---
description: Modify an existing feature with the smallest correct change; keep docs and the tester note in sync
---
Change request: $ARGUMENTS

Follow this exactly:
1. Read `AGENTS.md`, `docs/FEATURES_INDEX.md`, then the target feature's `FEATURE.md`.
   If `FEATURE.md` is missing, run the `/doc-sync` flow for that feature first (DOC-4).
2. Classify the change with the routing table, load the required rule files and skills, read
   `docs/CORE_MAP.md` and the core files you will use. Print `Rules loaded:`, `Skills loaded:`, `Core reuse:` (CORE-5).
3. Open only the source files you will edit or need to verify.
4. Apply the smallest correct change. No refactoring outside the request. Any new key, endpoint,
   route, or asset goes into `core/constants/` first (ARCH-10). UI uses core widgets, animations,
   and responsive only. A file that would pass 300 lines is split (FILE-2).
5. Update or add tests (TEST-1), then update `FEATURE.md` sections, `Last verified`, and the changelog (DOC-2).
6. Update `testers_release_note.txt` if a tester can see the change (NOTES-1..7).
7. Run the Definition of Done. If the change spans layers or adds behavior, run `@reviewer` and fix all violations.
8. Report with the format in CORE-23.
