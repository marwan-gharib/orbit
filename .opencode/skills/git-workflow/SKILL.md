---
name: git-workflow
description: Prepare clean commits, branch names, and pull request descriptions using Conventional Commits and small focused changes. Use ONLY when the user asks to commit, write a commit message, name a branch, or draft a PR description.
metadata:
  opencode/slash: "true"
---

# Git Workflow

The agent never runs `git commit` or `git push` (CORE-13); both are denied in `opencode.json`.
Use this skill only when the user explicitly asks for a commit message, a branch name, or a PR
description, and hand them the exact commands to run. Never suggest force-push or rewriting shared history.

## When to use
"Commit this", "write a commit message", "name the branch", "write the PR description".

## Branch names
`<type>/<short-kebab-description>`, e.g. `feat/product-details`, `fix/login-token-refresh`,
`refactor/orders-cubit-split`, `docs/auth-feature-doc`.

## Commits (Conventional Commits)
Format: `<type>(<scope>): <imperative summary, max 72 chars>`

| Type | Use for |
|---|---|
| `feat` | New behavior for users |
| `fix` | Bug fix |
| `refactor` | Structure change, no behavior change |
| `test` | Tests only |
| `docs` | Docs only (including `FEATURE.md`) |
| `chore` | Tooling, config, dependencies |
| `perf` | Performance improvement |
| `style` | Formatting only |

Scope is the feature or area: `feat(products): add product details screen`.
Body (optional): why, not what. Mention breaking changes with `BREAKING CHANGE:`.

## Procedure
1. `git status` and `git diff` to see exactly what changed. Never stage files you did not mean to (generated files, `.env`).
2. **One logical change per commit.** Split unrelated changes. A feature commit includes its tests and its `FEATURE.md` update.
3. Verify the Definition of Done passes before committing (CORE-24..33), including the rules script
   and the tester release note. Never run `git commit` or `git push` (CORE-13): prepare the text.
4. Give the user the exact `git add <files>` command for the specific files, not `git add .` blindly.
5. Write the message and give the final `git commit -m "..."` command for the user to run.

## Pull request description
```markdown
## What
<one or two sentences>

## Why
<problem or ticket>

## Changes
- <by layer or feature, short bullets>

## Testing
- <tests added, how verified, commands run>

## Docs
- FEATURE.md updated: <features>

## Notes for reviewer
- <risky areas, follow-ups, Noticed items>
```
Keep PRs small and focused. If a PR touches more than one feature or mixes refactor with behavior, suggest splitting.

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
