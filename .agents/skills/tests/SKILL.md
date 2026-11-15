---
name: tests
description: "Add missing tests to an existing feature (no production code changes). Invoke with /tests followed by the arguments; use only when the user asks for it."
---
`<arguments>` below means the text the user typed after `/tests` in the chat message (it may be empty).

Feature: <arguments>

1. Load `testing`, the skill `write-tests`, and `feature-docs`. Read the feature's `FEATURE.md` and source.
2. List what is untested: usecases, repository impl, models, cubit states, widgets (TEST-1..8). Show the list
   in one short block, then write the tests, mirroring the source path under `test/`.
3. Do not change production code. If a test reveals a bug, report it under `Noticed:` and do not fix it.
4. Run `flutter test <feature test path>` and `dart format` on the new files, then `bash .agents/scripts/check_rules.sh`.
5. Update `FEATURE.md` (Tests section) per DOC-2, and report with CORE-23. No release-note item is needed
   (no tester-visible change).
