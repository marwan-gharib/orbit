---
name: review
description: "Review the current diff against all project rules (read-only). Invoke with /review followed by the arguments; use only when the user asks for it."
---
`<arguments>` below means the text the user typed after `/review` in the chat message (it may be empty).

Act as the `reviewer` skill: read `.agents/skills/reviewer/SKILL.md` and follow it exactly (read-only).

Review the current working-tree changes against every applicable rule, the feature docs, and the
tester release note.
Extra focus from the user (optional): <arguments>
Use the output format defined in your instructions.
