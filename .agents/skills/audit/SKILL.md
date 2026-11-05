---
name: audit
description: "Audit existing code against all rules (read-only, no edits). Invoke with /audit followed by the arguments; use only when the user asks for it."
---
`<arguments>` below means the text the user typed after `/audit` in the chat message (it may be empty).

Act as the `reviewer` skill: read `.agents/skills/reviewer/SKILL.md` and follow it exactly (read-only).

Audit these paths or this feature (audit mode: review the files themselves, not the diff): <arguments>
If it is a feature name, audit `lib/features/<name>/` and its tests. Use the format in your instructions.
Also include, under Violations, every file over 300 lines.
