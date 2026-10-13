---
description: Fix a bug with a failing regression test first, then the smallest fix
---
Bug: $ARGUMENTS

Follow this exactly:
1. Read `AGENTS.md`, `docs/FEATURES_INDEX.md`, the feature's `FEATURE.md` (create it via the `/doc-sync` flow if missing).
2. Load the rule files for every layer the bug touches plus `testing` and `feature-docs`. Print `Rules loaded: ...`.
3. Locate the root cause. State it in one line before editing. If it cannot be located from the code, ask ONE question.
4. Write a regression test that fails for this bug (TEST-2) and run it to confirm it fails.
5. Apply the smallest fix. No unrelated changes.
6. Run the Definition of Done. The regression test must now pass.
7. Update `FEATURE.md` (business rules / known issues / changelog) per DOC-2.
8. Report with the format in CORE-23.
