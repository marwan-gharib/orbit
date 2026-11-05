---
name: check
description: "Run the Definition of Done checks and the rules script on the current changes. Invoke with /check followed by the arguments; use only when the user asks for it."
---
`<arguments>` below means the text the user typed after `/check` in the chat message (it may be empty).

Run the checks in `.agents/rules/00-done.md` section G for the files changed now, in order:
format, analyze, tests of the affected path, slang if i18n changed, rules script, doc and release-note status.

Rules script output:
Run this in the terminal and read the output: `bash .agents/scripts/check_rules.sh 2>&1 | tail -n 60`

Open every lead, confirm it, and fix real violations (or justify them). Do not claim a step passed
unless you ran it. Finish with one line per step: ✅ / ❌ / skipped (reason). Extra focus: <arguments>
