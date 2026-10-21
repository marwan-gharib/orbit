---
description: Run the Definition of Done checks and the rules script on the current changes
---
Run the checks in `.opencode/rules/00-done.md` section G for the files changed now, in order:
format, analyze, tests of the affected path, slang if i18n changed, rules script, doc and release-note status.

Rules script output:
!`bash .opencode/scripts/check_rules.sh 2>&1 | tail -n 60`

Open every lead, confirm it, and fix real violations (or justify them). Do not claim a step passed
unless you ran it. Finish with one line per step: ✅ / ❌ / skipped (reason). Extra focus: $ARGUMENTS
