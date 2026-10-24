---
description: Audit existing code against all rules (read-only, no edits)
agent: reviewer
subtask: true
---
Audit these paths or this feature (audit mode: review the files themselves, not the diff): $ARGUMENTS
If it is a feature name, audit `lib/features/<name>/` and its tests. Use the format in your instructions.
Also include, under Violations, every file over 300 lines.
