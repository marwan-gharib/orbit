---
description: Modify an existing feature with the smallest correct change and keep its doc in sync
---
Change request: $ARGUMENTS

Follow this exactly:
1. Read `AGENTS.md`, `docs/FEATURES_INDEX.md`, then the target feature's `FEATURE.md`.
   If `FEATURE.md` is missing, run the `/doc-sync` flow for that feature first (DOC-4).
2. Classify the change with the routing table, load the required rule files, print `Rules loaded: ...`.
3. Open only the source files you will edit or need to verify.
4. Apply the smallest correct change. No refactoring outside the request.
5. Update or add tests (TEST-1), then update `FEATURE.md` sections, `Last verified`, and the changelog (DOC-2).
6. Run the Definition of Done. If the change spans layers or adds behavior, run `@reviewer` and fix all violations.
7. Report with the format in CORE-23.
