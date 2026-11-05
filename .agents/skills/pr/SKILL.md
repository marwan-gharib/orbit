---
name: pr
description: "Write the branch name, commit message, and PR text for the current diff (does not run git commit or push). Invoke with /pr followed by the arguments; use only when the user asks for it."
---
`<arguments>` below means the text the user typed after `/pr` in the chat message (it may be empty).

Extra context (optional): <arguments>

Load the skill `git-workflow`.

Status:
Run this in the terminal and read the output: `git status --short 2>/dev/null | head -60`

Diff summary:
Run this in the terminal and read the output: `git diff --stat HEAD 2>/dev/null | tail -n 40`

Write: branch name, Conventional Commit message, and PR description (what, why, how to test, the
feature docs touched). In "how to test", reuse the Try / Expect lines from `testers_release_note.txt`.
Never run `git commit` or `git push`; the user runs git.
